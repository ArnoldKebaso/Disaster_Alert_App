// lib/pages/active_alerts_page.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// ————————————————————————
/// Data Model
/// ————————————————————————
class AlertModel {
  final int alertId;
  final String alertType;
  final String severity;
  final String location;
  final DateTime createdAt;

  AlertModel({
    required this.alertId,
    required this.alertType,
    required this.severity,
    required this.location,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      alertId: json['alert_id'] as int,
      alertType: json['alert_type'] as String,
      severity: json['severity'] as String,
      location: json['location'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// ————————————————————————
/// Riverpod Providers
/// ————————————————————————

/// 1) Fetch available locations
final locationsProvider = FutureProvider<List<String>>((ref) async {
  final res = await http.get(Uri.parse('http://localhost:3000/alerts/locales'));
  if (res.statusCode != 200) {
    throw Exception('Failed to load locations');
  }
  return (jsonDecode(res.body) as List).cast<String>();
});

/// 2) Track which location is selected (null → “all”)
final selectedLocationProvider = StateProvider<String?>((ref) => null);

/// 3) Fetch alerts (all or by location)
final alertsProvider = FutureProvider<List<AlertModel>>((ref) async {
  final loc = ref.watch(selectedLocationProvider);
  final uri = loc == null
      ? Uri.parse('http://localhost:3000/alerts')
      : Uri.parse(
          'http://localhost:3000/alerts?location=${Uri.encodeComponent(loc)}');
  final res = await http.get(uri);
  if (res.statusCode != 200) {
    throw Exception('Failed to load alerts');
  }
  return (jsonDecode(res.body) as List)
      .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// 4) Client‐side filter state
final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedTypeProvider = StateProvider<String>((ref) => 'All Types');
final selectedSeverityProvider =
    StateProvider<String>((ref) => 'All Severities');

/// 5) Compute the filtered list
final filteredAlertsProvider = Provider<List<AlertModel>>((ref) {
  final allAlerts = ref.watch(alertsProvider).maybeWhen(
        data: (list) => list,
        orElse: () => <AlertModel>[],
      );
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final type = ref.watch(selectedTypeProvider);
  final severity = ref.watch(selectedSeverityProvider);

  return allAlerts.where((a) {
    final matchesSearch = a.alertType.toLowerCase().contains(query) ||
        a.location.toLowerCase().contains(query);
    final matchesType = type == 'All Types' || a.alertType == type;
    final matchesSeverity =
        severity == 'All Severities' || a.severity == severity;
    return matchesSearch && matchesType && matchesSeverity;
  }).toList();
});

/// ————————————————————————
/// UI
/// ————————————————————————
class ActiveAlertsPage extends ConsumerWidget {
  const ActiveAlertsPage({Key? key}) : super(key: key);

  static const _alertTypes = <String>[
    'All Types',
    'RiverFlood',
    'FlashFlood',
    'UrbanFlood',
    'CoastalFlood',
    'ElNinoFlooding',
  ];

  static const _severities = <String>[
    'All Severities',
    'Low',
    'Medium',
    'High',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locsAsync = ref.watch(locationsProvider);
    final alertsAsync = ref.watch(alertsProvider);

    // current filter values
    final selectedLoc = ref.watch(selectedLocationProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedType = ref.watch(selectedTypeProvider);
    final selectedSeverity = ref.watch(selectedSeverityProvider);
    final filtered = ref.watch(filteredAlertsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Active Alerts')),
      body: locsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (locations) {
          return alertsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (_) => Column(
              children: [
                // ─── Filters ─────────────────────────
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Location dropdown
                      DropdownButton<String?>(
                        value: selectedLoc,
                        hint: const Text('Location'),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Locations'),
                          ),
                          ...locations.map((loc) => DropdownMenuItem(
                                value: loc,
                                child: Text(loc),
                              ))
                        ],
                        onChanged: (loc) => ref
                            .read(selectedLocationProvider.notifier)
                            .state = loc,
                      ),

                      // Search field
                      SizedBox(
                        width: 200,
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search...',
                          ),
                          onChanged: (v) =>
                              ref.read(searchQueryProvider.notifier).state = v,
                        ),
                      ),

                      // Type dropdown
                      DropdownButton<String>(
                        value: selectedType,
                        items: _alertTypes
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.replaceAll('Flood', '')),
                                ))
                            .toList(),
                        onChanged: (t) =>
                            ref.read(selectedTypeProvider.notifier).state = t!,
                      ),

                      // Severity dropdown
                      DropdownButton<String>(
                        value: selectedSeverity,
                        items: _severities
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s),
                                ))
                            .toList(),
                        onChanged: (s) => ref
                            .read(selectedSeverityProvider.notifier)
                            .state = s!,
                      ),
                    ],
                  ),
                ),

                // ─── Alerts Grid ────────────────────────
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 3 / 2,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final a = filtered[i];
                      return Card(
                        elevation: 3,
                        child: InkWell(
                          onTap: () => _showDetailsSheet(context, a),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.alertType,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${a.severity} • ${DateFormat.yMMMd().format(a.createdAt)}',
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        _showDetailsSheet(context, a),
                                    child: const Text('Details'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDetailsSheet(BuildContext context, AlertModel a) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          children: [
            ListTile(
              title: Text(
                a.alertType,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('ID: ${a.alertId}'),
            ),
            ListTile(title: Text('Severity: ${a.severity}')),
            ListTile(title: Text('Location: ${a.location}')),
            ListTile(
              title: Text(
                  'Created: ${DateFormat.yMMMMd().add_jm().format(a.createdAt)}'),
            ),
            // add any other fields here...
          ],
        ),
      ),
    );
  }
}
