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
class SubscriptionModel {
  final int id;
  final String method;
  final String contact;
  final List<String> locations;
  final DateTime createdAt;

  SubscriptionModel({
    required this.id,
    required this.method,
    required this.contact,
    required this.locations,
    required this.createdAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> j) {
    return SubscriptionModel(
      id: j['id'] as int,
      method: j['method'] as String,
      contact: j['contact'] as String,
      locations: List<String>.from(j['locations'] as List<dynamic>),
      createdAt: DateTime.parse(j['createdAt'] as String),
    );
  }
}

class AnalyticsData {
  final String label;
  final int count;

  AnalyticsData(this.label, this.count);
}

/// ───────────────────────────────────────────────────────────
/// Riverpod Providers & State
/// ───────────────────────────────────────────────────────────

// Month in format "yyyy-MM"
final selectedMonthProvider = StateProvider<String>((_) => '');

// Location filter
final selectedLocationProvider = StateProvider<String>((_) => '');

// Analytics: method counts
final methodCountsProvider = FutureProvider<List<AnalyticsData>>((ref) async {
  final res = await http.get(
      Uri.parse('http://localhost:3000/subscriptions/analytics/method-counts'));
  if (res.statusCode != 200) throw Exception('API error');
  final arr = jsonDecode(res.body) as List<dynamic>;
  return arr
      .map((e) =>
          AnalyticsData(e['label'] as String, (e['count'] as num).toInt()))
      .toList();
});

// Analytics: location counts
final locationCountsProvider = FutureProvider<List<AnalyticsData>>((ref) async {
  final res = await http.get(Uri.parse(
      'http://localhost:3000/subscriptions/analytics/location-counts'));
  if (res.statusCode != 200) throw Exception('API error');
  final arr = jsonDecode(res.body) as List<dynamic>;
  return arr
      .map((e) =>
          AnalyticsData(e['label'] as String, (e['count'] as num).toInt()))
      .toList();
});

// Filtered subscriptions
final filteredSubsProvider =
    FutureProvider<List<SubscriptionModel>>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  final loc = ref.watch(selectedLocationProvider);

  if (month.isNotEmpty) {
    final parts = month.split('-');
    final year = parts[0], m = parts[1];
    final res = await http.get(Uri.parse(
        'http://localhost:3000/subscriptions/filter/month?year=$year&month=$m'));
    if (res.statusCode != 200) throw Exception('API error');
    final arr = jsonDecode(res.body) as List<dynamic>;
    return arr
        .map((j) => SubscriptionModel.fromJson(j as Map<String, dynamic>))
        .toList();
  } else if (loc.isNotEmpty) {
    final res = await http.get(Uri.parse(
        'http://localhost:3000/subscriptions/by-location?location=${Uri.encodeComponent(loc)}'));
    if (res.statusCode != 200) throw Exception('API error');
    final arr = jsonDecode(res.body) as List<dynamic>;
    return arr
        .map((j) => SubscriptionModel.fromJson(j as Map<String, dynamic>))
        .toList();
  } else {
    return <SubscriptionModel>[];
  }
});

/// ───────────────────────────────────────────────────────────
/// UI: SubscriptionReportScreen
/// ───────────────────────────────────────────────────────────
class SubscriptionReportScreen extends ConsumerStatefulWidget {
  const SubscriptionReportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionReportScreen> createState() =>
      _SubscriptionReportScreenState();
}

class _SubscriptionReportScreenState
    extends ConsumerState<SubscriptionReportScreen> {
  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final dt = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
      helpText: 'Select month',
      fieldLabelText: 'Month',
      initialDatePickerMode: DatePickerMode.year,
    );
    if (dt != null) {
      final s = DateFormat('yyyy-MM').format(dt);
      ref.read(selectedMonthProvider.notifier).state = s;
      ref.read(selectedLocationProvider.notifier).state = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(selectedMonthProvider);
    final loc = ref.watch(selectedLocationProvider);

    final methods = ref.watch(methodCountsProvider);
    final locations = ref.watch(locationCountsProvider);
    final subs = ref.watch(filteredSubsProvider);

    return AppShell(
      isAdmin: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── FILTERS ────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickMonth,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(month.isEmpty ? 'Pick month' : month),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: loc.isEmpty ? null : loc,
                    decoration: const InputDecoration(labelText: 'Location'),
                    items: locations.when(
                      data: (list) => list
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

            // ── CHARTS ─────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: methods.when(
                        data: (data) => _buildBarChart(data, Colors.blue),
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
                      child: locations.when(
                        data: (data) => _buildBarChart(data, Colors.green),
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

            // ── TABLE ──────────────────────────────
            subs.when(
              data: (list) {
                return DataTable(
                  columns: const [
                    DataColumn(label: Text('Method')),
                    DataColumn(label: Text('Contact')),
                    DataColumn(label: Text('Locations')),
                    DataColumn(label: Text('Created')),
                  ],
                  rows: list
                      .map((s) => DataRow(cells: [
                            DataCell(Text(_capitalize(s.method))),
                            DataCell(Text(s.contact)),
                            DataCell(Wrap(
                              spacing: 4,
                              children: s.locations
                                  .map((l) => Chip(label: Text(l)))
                                  .toList(),
                            )),
                            DataCell(
                                Text(DateFormat.yMd().format(s.createdAt))),
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

  String _capitalize(String s) =>
      s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);

  Widget _buildBarChart(List<AnalyticsData> data, Color barColor) {
    final spots = <BarChartGroupData>[];
    for (var i = 0; i < data.length; i++) {
      spots.add(BarChartGroupData(x: i, barsSpace: 4, barRods: [
        BarChartRodData(
          toY: data[i].count.toDouble(),
          color: barColor,
        )
      ]));
    }

    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(data[v.toInt()].label,
                      style: const TextStyle(fontSize: 10))),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: spots,
      ),
    );
  }
}
