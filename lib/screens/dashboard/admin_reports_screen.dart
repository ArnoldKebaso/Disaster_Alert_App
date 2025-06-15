import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_shell.dart';

/// ───────────────────────────────────────────────────────────
/// Models
/// ───────────────────────────────────────────────────────────
class ReportModel {
  final int id;
  final String type;
  final String location;
  final String description;
  final String status;
  final DateTime createdAt;
  final String? username;

  ReportModel({
    required this.id,
    required this.type,
    required this.location,
    required this.description,
    required this.status,
    required this.createdAt,
    this.username,
  });

  factory ReportModel.fromJson(Map<String, dynamic> j) => ReportModel(
        id: j['report_id'] as int,
        type: j['report_type'] as String,
        location: j['location'] as String,
        description: j['description'] as String,
        status: j['status'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        username: j['User'] != null ? j['User']['username'] as String : null,
      );
}

class AnalyticsData {
  final String label;
  final int count;

  AnalyticsData(this.label, this.count);
}

/// ───────────────────────────────────────────────────────────
/// Riverpod Providers & State
/// ───────────────────────────────────────────────────────────

// 1) Selected month filter ("yyyy-MM")
final selectedMonthProvider = StateProvider<String>((_) => '');

// 2) Selected location filter
final selectedLocationProvider = StateProvider<String>((_) => '');

// 3) Analytics: report‐type counts
final typeCountsProvider = FutureProvider<List<AnalyticsData>>((ref) async {
  final res = await http.get(Uri.parse(
      'http://localhost:3000/community-reports/analytics/frequent-types'));
  if (res.statusCode != 200) throw Exception('Failed to load');
  final list = jsonDecode(res.body) as List<dynamic>;
  return list
      .map((j) => AnalyticsData(
          j['report_type'] as String, (j['count'] as num).toInt()))
      .toList();
});

// 4) Analytics: location counts
final locationCountsProvider = FutureProvider<List<AnalyticsData>>((ref) async {
  final res = await http.get(Uri.parse(
      'http://localhost:3000/community-reports/analytics/frequent-locations'));
  if (res.statusCode != 200) throw Exception('Failed to load');
  final list = jsonDecode(res.body) as List<dynamic>;
  return list
      .map((j) =>
          AnalyticsData(j['location'] as String, (j['count'] as num).toInt()))
      .toList();
});

// 5) Filtered reports
final filteredReportsProvider = FutureProvider<List<ReportModel>>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  final loc = ref.watch(selectedLocationProvider);

  if (month.isNotEmpty) {
    // month filter
    final parts = month.split('-');
    final year = parts[0], m = parts[1];
    final res = await http.get(Uri.parse(
        'http://localhost:3000/community-reports/filter/month?year=$year&month=$m'));
    if (res.statusCode != 200) throw Exception('Failed to filter');
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((j) => ReportModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }
  if (loc.isNotEmpty) {
    // location filter
    final res = await http.get(Uri.parse(
        'http://localhost:3000/community-reports/filter/location?location=${Uri.encodeComponent(loc)}'));
    if (res.statusCode != 200) throw Exception('Failed to filter');
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((j) => ReportModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }
  return <ReportModel>[];
});

/// ───────────────────────────────────────────────────────────
/// UI
/// ───────────────────────────────────────────────────────────
class AdminReportsScreen extends ConsumerStatefulWidget {
  const AdminReportsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends ConsumerState<AdminReportsScreen> {
  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final dt = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select Month',
      fieldLabelText: 'Month',
    );
    if (dt != null) {
      ref.read(selectedMonthProvider.notifier).state =
          DateFormat('yyyy-MM').format(dt);
      ref.read(selectedLocationProvider.notifier).state = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(selectedMonthProvider);
    final loc = ref.watch(selectedLocationProvider);

    final typesAsync = ref.watch(typeCountsProvider);
    final locsAsync = ref.watch(locationCountsProvider);
    final rptAsync = ref.watch(filteredReportsProvider);

    return AppShell(
      isAdmin: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Filters ─────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_month),
                    label: Text(month.isEmpty ? 'Pick Month' : month),
                    onPressed: _pickMonth,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Location'),
                    value: loc.isEmpty ? null : loc,
                    items: locsAsync.when(
                      data: (alist) => alist
                          .map((d) => DropdownMenuItem(
                                value: d.label,
                                child: Text(d.label),
                              ))
                          .toList(),
                      loading: () => const [],
                      error: (_, __) => const [],
                    ),
                    onChanged: (v) {
                      ref.read(selectedLocationProvider.notifier).state =
                          v ?? '';
                      ref.read(selectedMonthProvider.notifier).state = '';
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.read(selectedMonthProvider.notifier).state = '';
                    ref.read(selectedLocationProvider.notifier).state = '';
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Charts ─────────────────────────
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: typesAsync.when(
                        data: (data) =>
                            _buildBarChart(data, Colors.blue, 'Types'),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: locsAsync.when(
                        data: (data) =>
                            _buildBarChart(data, Colors.green, 'Locations'),
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Error: $e'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Table ──────────────────────────
            rptAsync.when(
              data: (list) {
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('By')),
                  ],
                  rows: list
                      .map((r) => DataRow(cells: [
                            DataCell(Text(r.type)),
                            DataCell(Text(r.location)),
                            DataCell(
                                Text(DateFormat.yMd().format(r.createdAt))),
                            DataCell(Text(r.status)),
                            DataCell(Text(r.username ?? 'Anon')),
                          ]))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(
      List<AnalyticsData> data, Color color, String keyLabel) {
    final spots = <BarChartGroupData>[];
    for (var i = 0; i < data.length; i++) {
      spots.add(BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: data[i].count.toDouble(), color: color)
      ]));
    }

    return BarChart(BarChartData(
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (val, _) => Text(data[val.toInt()].label,
                style: const TextStyle(fontSize: 10)),
          ),
        ),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: spots,
    ));
  }
}
