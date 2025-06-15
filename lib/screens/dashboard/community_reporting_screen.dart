// lib/screens/community/community_reporting_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../widgets/app_shell.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Model
/// ─────────────────────────────────────────────────────────────────────────────
class Report {
  final int id;
  final String type;
  final String location;
  final DateTime createdAt;
  final String status;
  final String user;
  final String description;

  Report({
    required this.id,
    required this.type,
    required this.location,
    required this.createdAt,
    required this.status,
    required this.user,
    required this.description,
  });

  factory Report.fromJson(Map<String, dynamic> j) {
    return Report(
      id: j['id'] as int,
      type: j['type'] as String,
      location: j['location'] as String,
      createdAt: DateTime.parse(j['createdAt'] as String),
      status: j['status'] as String,
      user: j['user'] as String,
      description: j['description'] as String,
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Providers & State
/// ─────────────────────────────────────────────────────────────────────────────

// Form fields
final reportTypeProvider = StateProvider<String>((_) => '');
final selectedLocationProvider = StateProvider<String?>((_) => null);
final descriptionProvider = StateProvider<String>((_) => '');
final imageFileProvider = StateProvider<XFile?>((_) => null);
final imagePreviewProvider = StateProvider<String?>((_) => null);
final locationSourceProvider = StateProvider<String?>((_) => null);
final isSubmittingProvider = StateProvider<bool>((_) => false);

// Fetch reports list
final reportsProvider = FutureProvider<List<Report>>((ref) async {
  final res = await http.get(
    Uri.parse('http://localhost:3000/community-reports'),
    headers: {'Accept': 'application/json'},
  );
  if (res.statusCode != 200) throw Exception('Failed to load reports');
  final data = jsonDecode(res.body) as List<dynamic>;
  return data.map((e) => Report.fromJson(e as Map<String, dynamic>)).toList();
});

// Filters
final statusFilterProvider = StateProvider<String>((_) => 'All');
final searchQueryProvider2 = StateProvider<String>((_) => '');

// Computed filtered list
final filteredReportsProvider2 = Provider<List<Report>>((ref) {
  final reports = ref.watch(reportsProvider).maybeWhen(
        data: (list) => list,
        orElse: () => <Report>[],
      );
  final status = ref.watch(statusFilterProvider).toLowerCase();
  final query = ref.watch(searchQueryProvider2).toLowerCase();

  return reports.where((r) {
    final matchStatus = status == 'all' || r.status.toLowerCase() == status;
    final matchSearch = r.location.toLowerCase().contains(query) ||
        r.description.toLowerCase().contains(query);
    return matchStatus && matchSearch;
  }).toList();
});

// Static options
const hazardTypeOptions = [
  {'value': 'FlashFlood', 'label': '⚡ Flash Flood'},
  {'value': 'RiverFlood', 'label': '🌊 River Flood'},
  {'value': 'CoastalFlood', 'label': '🌴 Coastal Flood'},
  {'value': 'UrbanFlood', 'label': '🏙️ Urban Flood'},
  {'value': 'ElNinoFlooding', 'label': '🌧️ El Niño Flooding'},
];

const locationOptions = [
  'Bumadeya',
  'Budalangi Central',
  'Budubusi',
  'Mundere',
  'Musoma',
  'Sibuka',
  'Sio Port',
  'Rukala',
  'Mukhweya',
  'Sigulu Island',
  'Siyaya',
  'Nambuku',
  'West Bunyala',
  'East Bunyala',
  'South Bunyala',
];

const statusTabs = ['All', 'Verified', 'Pending', 'Rejected'];

/// ─────────────────────────────────────────────────────────────────────────────
/// CommunityReportingScreen
/// ─────────────────────────────────────────────────────────────────────────────
class CommunityReportingScreen extends ConsumerWidget {
  const CommunityReportingScreen({Key? key}) : super(key: key);

  String _formatDate(DateTime dt) => DateFormat.yMMMd().format(dt);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = ref.watch(isSubmittingProvider);
    final reportsAsync = ref.watch(reportsProvider);
    final filtered = ref.watch(filteredReportsProvider2);
    final statusFilter = ref.watch(statusFilterProvider);
    final searchQuery = ref.watch(searchQueryProvider2);

    return AppShell(
      isAdmin: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Title
            Text(
              'Community Flood Reporting',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Report and track flood incidents in real-time',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Submission form
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Hazard type
                    DropdownButtonFormField<String>(
                      value: ref.watch(reportTypeProvider),
                      decoration:
                          const InputDecoration(labelText: 'Flood Type *'),
                      items: hazardTypeOptions
                          .map((h) => DropdownMenuItem(
                                value: h['value'],
                                child: Text(h['label']!),
                              ))
                          .toList(),
                      onChanged: (v) =>
                          ref.read(reportTypeProvider.notifier).state = v ?? '',
                    ),
                    const SizedBox(height: 12),

                    // Location + detect button
                    Row(children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: ref.watch(selectedLocationProvider),
                          decoration:
                              const InputDecoration(labelText: 'Location *'),
                          items: locationOptions
                              .map((loc) => DropdownMenuItem(
                                  value: loc, child: Text(loc)))
                              .toList(),
                          onChanged: (v) => ref
                              .read(selectedLocationProvider.notifier)
                              .state = v,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.my_location),
                        label: const Text('Detect'),
                        onPressed: () async {
                          try {
                            final pos = await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high);
                            final resp = await http.get(Uri.parse(
                                'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}&zoom=18&addressdetails=1'));
                            final data = jsonDecode(resp.body);
                            final addr = data['address'] ?? {};
                            final place = addr['village'] ??
                                addr['town'] ??
                                addr['city'] ??
                                addr['display_name'] ??
                                '';
                            ref.read(selectedLocationProvider.notifier).state =
                                place;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Detected: $place'),
                            ));
                          } catch (e) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Location error'),
                            ));
                          }
                        },
                      ),
                    ]),
                    const SizedBox(height: 12),

                    // Description
                    TextFormField(
                      maxLines: 3,
                      decoration:
                          const InputDecoration(labelText: 'Description *'),
                      onChanged: (v) =>
                          ref.read(descriptionProvider.notifier).state = v,
                    ),
                    const SizedBox(height: 12),

                    // Image upload
                    Consumer(builder: (ctx, ref, _) {
                      final preview = ref.watch(imagePreviewProvider);
                      return GestureDetector(
                        onTap: () async {
                          final pick = ImagePicker();
                          final file =
                              await pick.pickImage(source: ImageSource.gallery);
                          if (file != null) {
                            ref.read(imageFileProvider.notifier).state = file;
                            ref.read(imagePreviewProvider.notifier).state =
                                file.path;
                          }
                        },
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                            image: preview != null
                                ? DecorationImage(
                                    image: FileImage(File(preview)),
                                    fit: BoxFit.cover)
                                : null,
                          ),
                          child: preview == null
                              ? const Center(
                                  child: Icon(Icons.upload_file,
                                      size: 40, color: Colors.grey))
                              : null,
                        ),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Submit
                    ElevatedButton(
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              ref.read(isSubmittingProvider.notifier).state =
                                  true;

                              final type = ref.read(reportTypeProvider);
                              final loc = ref.read(selectedLocationProvider);
                              final desc = ref.read(descriptionProvider);
                              final img = ref.read(imageFileProvider);

                              if (type.isEmpty ||
                                  loc == null ||
                                  desc.isEmpty ||
                                  img == null) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content:
                                      Text('Please fill all required fields'),
                                ));
                                ref.read(isSubmittingProvider.notifier).state =
                                    false;
                                return;
                              }

                              final req = http.MultipartRequest(
                                  'POST',
                                  Uri.parse(
                                      'http://localhost:3000/community-reports'))
                                ..fields['report_type'] = type
                                ..fields['location'] = loc
                                ..fields['description'] = desc
                                ..fields['status'] = 'pending'
                                ..files.add(await http.MultipartFile.fromPath(
                                    'image', img.path));

                              try {
                                final resp = await req.send();
                                if (resp.statusCode == 200) {
                                  ref.invalidate(reportsProvider);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content:
                                        Text('Report submitted successfully'),
                                  ));
                                } else {
                                  throw Exception('Failed');
                                }
                              } catch (_) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Submission failed'),
                                ));
                              } finally {
                                ref.read(isSubmittingProvider.notifier).state =
                                    false;
                              }
                            },
                      child: isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Submit Report'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Filters for recent reports
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Status tabs
                    for (final tab in statusTabs)
                      ChoiceChip(
                        label: Text(tab),
                        selected: statusFilter == tab,
                        onSelected: (_) =>
                            ref.read(statusFilterProvider.notifier).state = tab,
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
                            ref.read(searchQueryProvider2.notifier).state = v,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Recent reports list
            reportsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error loading reports')),
              data: (_) => ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final r = filtered[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(
                        r.status.toLowerCase() == 'verified'
                            ? Icons.check_circle
                            : r.status.toLowerCase() == 'pending'
                                ? Icons.hourglass_top
                                : Icons.cancel,
                        color: r.status.toLowerCase() == 'verified'
                            ? Colors.green
                            : r.status.toLowerCase() == 'pending'
                                ? Colors.orange
                                : Colors.red,
                      ),
                      title: Text(r.type),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.location),
                          Text(
                            _formatDate(r.createdAt),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: Text(
                        r.user,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () {
                        // could navigate to detail if needed
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
