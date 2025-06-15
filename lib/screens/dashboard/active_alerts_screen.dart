// lib/screens/dashboard/active_alerts_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod state management
import 'package:http/http.dart' as http; // HTTP client
import 'package:intl/intl.dart'; // Date formatting

// ---------------------------------------------
// MODEL
// ---------------------------------------------
class AlertModel {
  final int id;
  final String type;
  final String severity;
  final String location;
  final String description;
  final DateTime createdAt;

  AlertModel({
    required this.id,
    required this.type,
    required this.severity,
    required this.location,
    required this.description,
    required this.createdAt,
  });

  // JSON ↔ Model
  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
        id: json['alert_id'] as int,
        type: json['alert_type'] as String,
        severity: json['severity'] as String,
        location: json['location'] as String,
        description: json['description'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

// ---------------------------------------------
// PROVIDERS
// ---------------------------------------------

/// Fetch list of available locations from backend
final locationsProvider = FutureProvider<List<String>>((ref) async {
  final res = await http.get(
    Uri.parse('http://localhost:3000/alerts/locales'),
    headers: {'Accept': 'application/json'},
  );
  if (res.statusCode != 200) throw Exception('Failed to load locations');
  final List data = jsonDecode(res.body) as List;
  return data.map((e) => e as String).toList();
});

/// Fetch alerts, optionally filtered by location
final alertsProvider =
    FutureProvider.family<List<AlertModel>, String?>((ref, location) async {
  var uri = Uri.parse('http://localhost:3000/alerts');
  if (location != null) {
    uri = uri.replace(queryParameters: {'location': location});
  }
  final res = await http.get(uri, headers: {'Accept': 'application/json'});
  if (res.statusCode != 200) throw Exception('Failed to load alerts');
  final List data = jsonDecode(res.body) as List;
  return data
      .map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
});

// ---------------------------------------------
// SCREEN
// ---------------------------------------------
class ActiveAlertsScreen extends ConsumerStatefulWidget {
  const ActiveAlertsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ActiveAlertsScreen> createState() => _ActiveAlertsScreenState();
}

class _ActiveAlertsScreenState extends ConsumerState<ActiveAlertsScreen> {
  // Local UI state for filters
  String? _selectedLocation;
  String _search = '';
  String _typeFilter = 'All';
  String _severityFilter = 'All';

  // Month & time filters could be added similarly…

  @override
  Widget build(BuildContext context) {
    // Watch providers
    final locAsync = ref.watch(locationsProvider);
    final alertsAsync = ref.watch(alertsProvider(_selectedLocation));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Flood Alerts'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== LOCATION DROPDOWN =====
            locAsync.when(
              data: (locs) => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Location',
                  border: OutlineInputBorder(),
                ),
                value: _selectedLocation,
                items: [null, ...locs]
                    .map((l) => DropdownMenuItem(
                          value: l,
                          child: Text(l ?? 'All Locations'),
                        ))
                    .toList(),
                onChanged: (v) => setState(() {
                  _selectedLocation = v;
                }),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error loading locations: $e')),
            ),

            const SizedBox(height: 12),

            // ===== FILTERS ROW =====
            Row(
              children: [
                // Search box
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: 8),
                // Type filter
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    value: _typeFilter,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(
                          value: 'RiverFlood', child: Text('RiverFlood')),
                      DropdownMenuItem(
                          value: 'FlashFlood', child: Text('FlashFlood')),
                      // …add as needed
                    ],
                    onChanged: (v) => setState(() => _typeFilter = v!),
                  ),
                ),
                const SizedBox(width: 8),
                // Severity filter
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Severity',
                      border: OutlineInputBorder(),
                    ),
                    value: _severityFilter,
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Low', child: Text('Low')),
                      DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'High', child: Text('High')),
                    ],
                    onChanged: (v) => setState(() => _severityFilter = v!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ===== ALERT LIST =====
            Expanded(
              child: alertsAsync.when(
                data: (alerts) {
                  // Apply client-side filtering
                  final filtered = alerts.where((a) {
                    final matchesSearch = a.location
                        .toLowerCase()
                        .contains(_search.toLowerCase());
                    final matchesType =
                        _typeFilter == 'All' || a.type == _typeFilter;
                    final matchesSev = _severityFilter == 'All' ||
                        a.severity == _severityFilter;
                    return matchesSearch && matchesType && matchesSev;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No alerts found.'));
                  }

                  // Grid of cards
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final a = filtered[i];
                      return GestureDetector(
                        onTap: () => _showDetails(context, a),
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.type,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(a.location),
                                const Spacer(),
                                Text(
                                  DateFormat.yMMMd()
                                      .add_Hm()
                                      .format(a.createdAt),
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Error loading alerts: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom‐sheet to show full details
  void _showDetails(BuildContext ctx, AlertModel a) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16) + MediaQuery.of(ctx).viewInsets,
        child: Wrap(
          children: [
            ListTile(
              title: Text(a.type,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              subtitle: Text(a.location),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(a.description),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Reported at ${DateFormat.yMMMd().add_Hm().format(a.createdAt)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
