// lib/screens/dashboard/alerts_management_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../widgets/app_shell.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AlertModel
/// ─────────────────────────────────────────────────────────────────────────────
class AlertModel {
  final int alertId;
  String alertType;
  String severity;
  String location;
  String description;
  String waterCurrent;
  String waterPredicted;
  List<String> evacuationRoutes;
  List<String> emergencyContacts;
  List<String> precautionaryMeasures;
  String forecast24h;
  String forecast48h;
  String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  AlertModel({
    required this.alertId,
    required this.alertType,
    required this.severity,
    required this.location,
    required this.description,
    required this.waterCurrent,
    required this.waterPredicted,
    required this.evacuationRoutes,
    required this.emergencyContacts,
    required this.precautionaryMeasures,
    required this.forecast24h,
    required this.forecast48h,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> j) => AlertModel(
        alertId: j['alert_id'] as int,
        alertType: j['alert_type'] as String,
        severity: j['severity'] as String,
        location: j['location'] as String,
        description: j['description'] as String,
        waterCurrent: j['water_levels']['current'] as String,
        waterPredicted: j['water_levels']['predicted'] as String,
        evacuationRoutes:
            List<String>.from(j['evacuation_routes'] as List<dynamic>),
        emergencyContacts:
            List<String>.from(j['emergency_contacts'] as List<dynamic>),
        precautionaryMeasures:
            List<String>.from(j['precautionary_measures'] as List<dynamic>),
        forecast24h: j['weather_forecast']['next_24_hours'] as String,
        forecast48h: j['weather_forecast']['next_48_hours'] as String,
        status: j['status'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );

  AlertModel copyWith({
    String? alertType,
    String? severity,
    String? location,
    String? description,
    String? status,
  }) {
    return AlertModel(
      alertId: alertId,
      alertType: alertType ?? this.alertType,
      severity: severity ?? this.severity,
      location: location ?? this.location,
      description: description ?? this.description,
      waterCurrent: waterCurrent,
      waterPredicted: waterPredicted,
      evacuationRoutes: evacuationRoutes,
      emergencyContacts: emergencyContacts,
      precautionaryMeasures: precautionaryMeasures,
      forecast24h: forecast24h,
      forecast48h: forecast48h,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Riverpod Providers & State
/// ─────────────────────────────────────────────────────────────────────────────

// Filter options
const alertTypes = [
  'All Types',
  'RiverFlood',
  'FlashFlood',
  'UrbanFlood',
  'CoastalFlood',
  'ElNinoFlooding'
];
const severities = ['All Severities', 'Low', 'Medium', 'High'];
const timeFilters = ['All Time', '24h', '48h', '7d'];
const statusOptions = ['active', 'resolved', 'archived'];

// 1) available locations
final locationsProvider = FutureProvider<List<String>>((ref) async {
  final res = await http.get(Uri.parse('http://localhost:3000/alerts/locales'));
  if (res.statusCode != 200) throw Exception('Failed to load locations');
  return List<String>.from(jsonDecode(res.body) as List<dynamic>);
});

// 2) selected location (null = all)
final selectedLocationProvider = StateProvider<String?>((_) => null);

// 3) include archived?
final showArchivedProvider = StateProvider<bool>((_) => false);

// 4) raw alerts fetch
final alertsProvider = FutureProvider<List<AlertModel>>((ref) async {
  final loc = ref.watch(selectedLocationProvider);
  final archived = ref.watch(showArchivedProvider);
  final uri = Uri.parse('http://localhost:3000/alerts').replace(
    queryParameters: {
      if (loc != null) 'location': loc,
      if (archived) 'includeArchived': 'true',
    },
  );
  final res = await http.get(uri);
  if (res.statusCode != 200) throw Exception('Failed to load alerts');
  return (jsonDecode(res.body) as List<dynamic>)
      .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

// 5) filter state
final searchQueryProvider = StateProvider<String>((_) => '');
final activeTypeProvider = StateProvider<String>((_) => 'All Types');
final activeSeverityProvider = StateProvider<String>((_) => 'All Severities');
final selectedMonthProvider = StateProvider<String>((_) => 'All Months');
final selectedTimeProvider = StateProvider<String>((_) => 'All Time');

// 6) filtered list
final filteredAlertsProvider = Provider<List<AlertModel>>((ref) {
  final all = ref.watch(alertsProvider).maybeWhen(
        data: (list) => list,
        orElse: () => <AlertModel>[],
      );
  final q = ref.watch(searchQueryProvider).toLowerCase();
  final type = ref.watch(activeTypeProvider);
  final sev = ref.watch(activeSeverityProvider);
  final mon = ref.watch(selectedMonthProvider);
  final tim = ref.watch(selectedTimeProvider);

  const timeMap = {
    '24h': Duration(hours: 24),
    '48h': Duration(hours: 48),
    '7d': Duration(days: 7),
  };

  return all.where((a) {
    final ms = a.location.toLowerCase().contains(q) ||
        a.description.toLowerCase().contains(q);
    final mt = type == 'All Types' || a.alertType == type;
    final msx = sev == 'All Severities' || a.severity == sev;
    final monthName = DateFormat.MMMM().format(a.createdAt);
    final mm = mon == 'All Months' || mon == monthName;
    final tt = tim == 'All Time' ||
        DateTime.now().difference(a.createdAt) <= timeMap[tim]!;
    return ms && mt && msx && mm && tt;
  }).toList();
});

/// ─────────────────────────────────────────────────────────────────────────────
/// AlertsManagementScreen
/// ─────────────────────────────────────────────────────────────────────────────
class AlertsManagementScreen extends ConsumerWidget {
  const AlertsManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locsAsync = ref.watch(locationsProvider);
    final alertsAsync = ref.watch(alertsProvider);
    final selectedLoc = ref.watch(selectedLocationProvider);
    final showArchived = ref.watch(showArchivedProvider);
    final filtered = ref.watch(filteredAlertsProvider);

    return AppShell(
      isAdmin: true,
      child: locsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (locs) {
          // If no location chosen, show selector
          if (selectedLoc == null) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 2,
              ),
              itemCount: locs.length,
              itemBuilder: (_, i) {
                final loc = locs[i];
                final count = alertsAsync.maybeWhen(
                    data: (all) => all.where((a) => a.location == loc).length,
                    orElse: () => 0);
                return GestureDetector(
                  onTap: () =>
                      ref.read(selectedLocationProvider.notifier).state = loc,
                  child: Card(
                    elevation: 3,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(loc,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('$count alerts'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          // Main admin alerts view
          return Stack(
            children: [
              Column(
                children: [
                  // ── Header ───────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Alerts for $selectedLoc',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Locations'),
                          onPressed: () => ref
                              .read(selectedLocationProvider.notifier)
                              .state = null,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),

                  // ── Filters ─────────────────────────
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Search
                        SizedBox(
                          width: 200,
                          child: TextField(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Search…',
                            ),
                            onChanged: (v) => ref
                                .read(searchQueryProvider.notifier)
                                .state = v,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Type
                        _buildDropdown<String>(
                          value: ref.watch(activeTypeProvider),
                          items: alertTypes,
                          onChanged: (v) =>
                              ref.read(activeTypeProvider.notifier).state = v!,
                        ),

                        const SizedBox(width: 16),
                        // Severity
                        _buildDropdown<String>(
                          value: ref.watch(activeSeverityProvider),
                          items: severities,
                          onChanged: (v) => ref
                              .read(activeSeverityProvider.notifier)
                              .state = v!,
                        ),

                        const SizedBox(width: 16),
                        // Month
                        _buildDropdown<String>(
                          value: ref.watch(selectedMonthProvider),
                          items: ['All Months'] +
                              List.generate(
                                  12,
                                  (i) => DateFormat.MMMM()
                                      .format(DateTime(0, i + 1))),
                          onChanged: (v) => ref
                              .read(selectedMonthProvider.notifier)
                              .state = v!,
                        ),

                        const SizedBox(width: 16),
                        // Time
                        _buildDropdown<String>(
                          value: ref.watch(selectedTimeProvider),
                          items: timeFilters,
                          onChanged: (v) => ref
                              .read(selectedTimeProvider.notifier)
                              .state = v!,
                        ),

                        const SizedBox(width: 16),
                        // Archived toggle
                        Row(
                          children: [
                            const Text('Archived'),
                            Switch(
                              value: showArchived,
                              onChanged: (b) => ref
                                  .read(showArchivedProvider.notifier)
                                  .state = b,
                            ),
                          ],
                        ),

                        const SizedBox(width: 16),
                        // Clear filters
                        OutlinedButton(
                          onPressed: () {
                            ref.read(searchQueryProvider.notifier).state = '';
                            ref.read(activeTypeProvider.notifier).state =
                                'All Types';
                            ref.read(activeSeverityProvider.notifier).state =
                                'All Severities';
                            ref.read(selectedMonthProvider.notifier).state =
                                'All Months';
                            ref.read(selectedTimeProvider.notifier).state =
                                'All Time';
                            ref.read(showArchivedProvider.notifier).state =
                                false;
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Alerts Grid ─────────────────────
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 3 / 2,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final a = filtered[i];
                        return Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // header + actions
                                Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        a.alertType,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () {
                                        /* TODO: edit flow */
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(a.status == 'archived'
                                          ? Icons.unarchive
                                          : Icons.archive),
                                      onPressed: () =>
                                          _toggleArchive(context, ref, a),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () =>
                                          _deleteAlert(context, ref, a),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(a.location),
                                Text(
                                  DateFormat.yMMMd()
                                      .add_jm()
                                      .format(a.createdAt),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                const Spacer(),
                                Center(
                                  child: TextButton(
                                    onPressed: () => _showDetails(context, a),
                                    child: const Text('Details'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // ── Floating “+” Create ─────────────────
              Positioned(
                bottom: 24,
                right: 24,
                child: FloatingActionButton(
                  onPressed: () => context.go('/createAlert'),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButton<T>(
      value: value,
      items: items
          .map((it) => DropdownMenuItem(value: it, child: Text(it.toString())))
          .toList(),
      onChanged: onChanged,
    );
  }

  static Future<void> _deleteAlert(
      BuildContext ctx, WidgetRef ref, AlertModel a) async {
    await http.delete(Uri.parse('http://localhost:3000/alerts/${a.alertId}'));
    ref.invalidate(alertsProvider);
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx)
          .showSnackBar(const SnackBar(content: Text('Alert deleted')));
    }
  }

  static Future<void> _toggleArchive(
      BuildContext ctx, WidgetRef ref, AlertModel a) async {
    final target = a.status == 'archived' ? 'unarchive' : 'archive';
    await http
        .put(Uri.parse('http://localhost:3000/alerts/${a.alertId}/$target'));
    ref.invalidate(alertsProvider);
  }

  static void _showDetails(BuildContext ctx, AlertModel a) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              title: Text(a.alertType,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text('Status: ${a.status}'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            const Divider(),
            _detailRow('Description', a.description),
            _detailRow('Current Water', a.waterCurrent),
            _detailRow('Predicted Water', a.waterPredicted),
            _detailRow('Evacuation', a.evacuationRoutes.join(', ')),
            _detailRow('Contacts', a.emergencyContacts.join(', ')),
            _detailRow('Measures', a.precautionaryMeasures.join(', ')),
            _detailRow('Forecast 24h', a.forecast24h),
            _detailRow('Forecast 48h', a.forecast48h),
            _detailRow(
                'Created', DateFormat.yMMMMd().add_jm().format(a.createdAt)),
            _detailRow(
                'Updated', DateFormat.yMMMMd().add_jm().format(a.updatedAt)),
            const SizedBox(height: 16),
            Center(
              child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close')),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _detailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87),
            children: [
              TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(text: value),
            ],
          ),
        ),
      );
}
