// lib/screens/dashboard/admin_alerts_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../widgets/app_shell.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Model
/// ─────────────────────────────────────────────────────────────────────────────
class AdminAlertModel {
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

  AdminAlertModel({
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

  factory AdminAlertModel.fromJson(Map<String, dynamic> j) {
    return AdminAlertModel(
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
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Riverpod Providers & State
/// ─────────────────────────────────────────────────────────────────────────────

// 1) fetch available locations
final locationsProvider = FutureProvider<List<String>>((ref) async {
  final res = await http.get(Uri.parse('http://localhost:3000/alerts/locales'));
  if (res.statusCode != 200) throw Exception('Failed to load locations');
  return List<String>.from(jsonDecode(res.body) as List<dynamic>);
});

// 2) currently selected location (null => show location chooser)
final selectedLocationProvider = StateProvider<String?>((_) => null);

// 3) include archived?
final showArchivedProvider = StateProvider<bool>((_) => false);

// 4) fetch alerts for that location & archive flag
final alertsProvider = FutureProvider<List<AdminAlertModel>>((ref) async {
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
      .map((e) => AdminAlertModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

// 5) filter controls
final searchQueryProvider = StateProvider<String>((_) => '');
final activeTypeProvider = StateProvider<String>((_) => 'All Types');
final activeSeverityProvider = StateProvider<String>((_) => 'All Severities');
final selectedMonthProvider = StateProvider<String>((_) => 'All Months');
final selectedTimeProvider = StateProvider<String>((_) => 'All Time');

// 6) computed filtered list
final filteredAlertsProvider = Provider<List<AdminAlertModel>>((ref) {
  final all = ref.watch(alertsProvider).maybeWhen(
        data: (list) => list,
        orElse: () => <AdminAlertModel>[],
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
    final matchesSearch = a.location.toLowerCase().contains(q);
    final matchesType = type == 'All Types' || a.alertType == type;
    final matchesSev = sev == 'All Severities' || a.severity == sev;
    final monthName = DateFormat.MMMM().format(a.createdAt);
    final matchesMon = mon == 'All Months' || mon == monthName;
    final matchesTime = tim == 'All Time' ||
        DateTime.now().difference(a.createdAt) <=
            (timeMap[tim] ?? Duration.zero);
    return matchesSearch &&
        matchesType &&
        matchesSev &&
        matchesMon &&
        matchesTime;
  }).toList();
});

/// ─────────────────────────────────────────────────────────────────────────────
/// UI
/// ─────────────────────────────────────────────────────────────────────────────

class AdminAlertsScreen extends ConsumerStatefulWidget {
  const AdminAlertsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminAlertsScreen> createState() => _AdminAlertsScreenState();
}

class _AdminAlertsScreenState extends ConsumerState<AdminAlertsScreen> {
  AdminAlertModel? selectedAlert;
  AdminAlertModel? editingAlert;

  static const List<String> alertTypes = [
    'All Types',
    'RiverFlood',
    'FlashFlood',
    'UrbanFlood',
    'CoastalFlood',
    'ElNinoFlooding'
  ];
  static const List<String> severities = [
    'All Severities',
    'Low',
    'Medium',
    'High'
  ];
  static const List<String> timeFilters = ['All Time', '24h', '48h', '7d'];

  @override
  Widget build(BuildContext context) {
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
          if (selectedLoc == null) {
            // LOCATION SELECTION
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
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            loc,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('$count active alerts'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          // MAIN ALERTS SCREEN
          return Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_alert),
                      label: const Text('Create Alert'),
                      onPressed: () => context.go('/createAlert'),
                    ),
                  ],
                ),
              ),

              // Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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
                          onChanged: (v) =>
                              ref.read(searchQueryProvider.notifier).state = v,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Archived
                      Row(
                        children: [
                          const Text('Show Archived'),
                          Switch(
                            value: showArchived,
                            onChanged: (b) => ref
                                .read(showArchivedProvider.notifier)
                                .state = b,
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Month
                      DropdownButton<String>(
                        value: ref.watch(selectedMonthProvider),
                        items: [
                          'All Months',
                          ...List.generate(
                            12,
                            (i) => DateFormat.MMMM().format(DateTime(0, i + 1)),
                          )
                        ]
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m),
                                ))
                            .toList(),
                        onChanged: (m) =>
                            ref.read(selectedMonthProvider.notifier).state = m!,
                      ),
                      const SizedBox(width: 16),
                      // Time
                      DropdownButton<String>(
                        value: ref.watch(selectedTimeProvider),
                        items: timeFilters
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t),
                                ))
                            .toList(),
                        onChanged: (t) =>
                            ref.read(selectedTimeProvider.notifier).state = t!,
                      ),
                      const SizedBox(width: 16),
                      // Clear
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
                          ref.read(showArchivedProvider.notifier).state = false;
                        },
                        child: const Text('Clear Filters'),
                      ),
                    ],
                  ),
                ),
              ),

              // Type chips
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Wrap(
                  spacing: 8,
                  children: alertTypes.map((t) {
                    final sel = ref.watch(activeTypeProvider) == t;
                    return ChoiceChip(
                      label: Text(t.replaceAll('Flood', '')),
                      selected: sel,
                      onSelected: (_) =>
                          ref.read(activeTypeProvider.notifier).state = t,
                    );
                  }).toList(),
                ),
              ),

              // Severity chips
              Wrap(
                spacing: 8,
                children: severities.map((s) {
                  final sel = ref.watch(activeSeverityProvider) == s;
                  return ChoiceChip(
                    label: Text(s),
                    selected: sel,
                    onSelected: (_) =>
                        ref.read(activeSeverityProvider.notifier).state = s,
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),

              // Alerts grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3 / 2,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final a = filtered[i];
                    return Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // header row
                            Row(
                              children: [
                                const Icon(
                                  Icons.warning_amber_rounded,
                                  size: 28,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    a.alertType,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                // Delete
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _delete(a),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(a.location),
                            Text(
                              DateFormat.yMMMd().add_jm().format(a.createdAt),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            const Spacer(),
                            Center(
                              child: ElevatedButton(
                                onPressed: () => _showDetails(a),
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
          );
        },
      ),
    );
  }

  Future<void> _delete(AdminAlertModel a) async {
    await http.delete(Uri.parse('http://localhost:3000/alerts/${a.alertId}'));
    ref.invalidate(alertsProvider);
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Deleted'),
      ));
  }

  void _showDetails(AdminAlertModel a) {
    showModalBottomSheet(
      context: context,
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
            ),
            const Divider(),
            _detailRow('Description', a.description),
            _detailRow('Water (Current)', a.waterCurrent),
            _detailRow('Water (Predicted)', a.waterPredicted),
            _detailRow('Evacuation', a.evacuationRoutes.join(', ')),
            _detailRow('Contacts', a.emergencyContacts.join(', ')),
            _detailRow('Forecast 24h', a.forecast24h),
            _detailRow('Forecast 48h', a.forecast48h),
            _detailRow(
                'Created', DateFormat.yMMMMd().add_jm().format(a.createdAt)),
            _detailRow(
                'Updated', DateFormat.yMMMMd().add_jm().format(a.updatedAt)),
            const SizedBox(height: 16),
            Center(
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) => Padding(
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
