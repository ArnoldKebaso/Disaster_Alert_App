// lib/screens/dashboard/admin_community_reports_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../widgets/app_shell.dart';

/// ───────────────────────────────────────────────────────────
/// Model
/// ───────────────────────────────────────────────────────────
class CommunityReport {
  final int reportId;
  final String reportType;
  final String location;
  final String description;
  final String? imageUrl;
  String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? username;

  CommunityReport({
    required this.reportId,
    required this.reportType,
    required this.location,
    required this.description,
    this.imageUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.username,
  });

  factory CommunityReport.fromJson(Map<String, dynamic> j) {
    return CommunityReport(
      reportId: j['report_id'] as int,
      reportType: j['report_type'] as String,
      location: j['location'] as String,
      description: j['description'] as String,
      imageUrl: j['image_url'] as String?,
      status: j['status'] as String,
      createdAt: DateTime.parse(j['createdAt'] as String),
      updatedAt: DateTime.parse(j['updatedAt'] as String),
      username: j['User'] != null ? (j['User']['username'] as String) : null,
    );
  }
}

/// ───────────────────────────────────────────────────────────
/// State & Providers
/// ───────────────────────────────────────────────────────────

const _itemsPerPage = 6;
const _statusOptions = ['all', 'pending', 'verified', 'rejected'];

final reportsProvider = FutureProvider<List<CommunityReport>>((ref) async {
  final res = await http.get(
    Uri.parse('http://localhost:3000/admin/community-reports'),
    // credentials: include cookie auth
  );
  if (res.statusCode != 200) {
    throw Exception('Failed to load reports');
  }
  final list = jsonDecode(res.body) as List<dynamic>;
  return list
      .map((e) => CommunityReport.fromJson(e as Map<String, dynamic>))
      .toList();
});

final searchQueryProvider = StateProvider<String>((_) => '');
final statusFilterProvider = StateProvider<String>((_) => 'all');
final currentPageProvider = StateProvider<int>((_) => 0);

final filteredReportsProvider = Provider<List<CommunityReport>>((ref) {
  final all = ref.watch(reportsProvider).maybeWhen(
        data: (list) => list,
        orElse: () => <CommunityReport>[],
      );
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final status = ref.watch(statusFilterProvider);
  return all.where((r) {
    final matchesSearch = r.location.toLowerCase().contains(query) ||
        r.description.toLowerCase().contains(query);
    final matchesStatus = status == 'all' || r.status == status;
    return matchesSearch && matchesStatus;
  }).toList();
});

/// ───────────────────────────────────────────────────────────
/// UI
/// ───────────────────────────────────────────────────────────

class AdminCommunityReportsScreen extends ConsumerWidget {
  const AdminCommunityReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(reportsProvider);
    final filtered = ref.watch(filteredReportsProvider);
    final page = ref.watch(currentPageProvider);
    final pageCount = (filtered.length / _itemsPerPage).ceil();
    final start = page * _itemsPerPage;
    final slice = filtered.skip(start).take(_itemsPerPage).toList();

    return AppShell(
      isAdmin: true,
      child: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (_) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Filters row
              Row(
                children: [
                  // Search
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search reports…'),
                      onChanged: (v) {
                        ref.read(searchQueryProvider.notifier).state = v;
                        ref.read(currentPageProvider.notifier).state = 0;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Status dropdown
                  DropdownButton<String>(
                    value: ref.watch(statusFilterProvider),
                    items: _statusOptions
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(
                                  s == 'all' ? 'All Statuses' : s.capitalize()),
                            ))
                        .toList(),
                    onChanged: (v) {
                      ref.read(statusFilterProvider.notifier).state = v!;
                      ref.read(currentPageProvider.notifier).state = 0;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Grid of cards
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3 / 4,
                  ),
                  itemCount: slice.length,
                  itemBuilder: (_, i) {
                    final r = slice[i];
                    return _ReportCard(report: r);
                  },
                ),
              ),

              // Pagination controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: page > 0
                        ? () => ref.read(currentPageProvider.notifier).state--
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('${page + 1} / $pageCount'),
                  IconButton(
                    onPressed: page < pageCount - 1
                        ? () => ref.read(currentPageProvider.notifier).state++
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  final CommunityReport report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> updateStatus(String newStatus) async {
      final res = await http.put(
        Uri.parse(
            'http://localhost:3000/admin/community-reports/${report.reportId}/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': newStatus}),
      );
      if (res.statusCode == 200) {
        report.status = newStatus;
        ref.invalidate(reportsProvider);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Status updated')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Update failed')));
      }
    }

    Future<void> deleteReport() async {
      final res = await http.delete(
        Uri.parse(
            'http://localhost:3000/admin/community-reports/${report.reportId}'),
      );
      if (res.statusCode == 204) {
        ref.invalidate(reportsProvider);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Report deleted')));
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Delete failed')));
      }
    }

    final dateFmt = DateFormat.yMMMd().format(report.createdAt);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                const Icon(Icons.report, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    report.reportType,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) => updateStatus(v),
                  itemBuilder: (_) => ['pending', 'verified', 'rejected']
                      .map((s) => PopupMenuItem(
                            value: s,
                            child: Text(s.capitalize()),
                          ))
                      .toList(),
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (report.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  report.imageUrl!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              report.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Text(
              '${report.location} • $dateFmt',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: deleteReport,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() =>
      this.isEmpty ? '' : this[0].toUpperCase() + substring(1);
}
