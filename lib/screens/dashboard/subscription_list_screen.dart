// lib/screens/dashboard/subscription_list_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../widgets/app_shell.dart';

/// Model for a single subscription
class Subscription {
  final int id;
  final String method; // "email" or "sms"
  final String contact;

  Subscription({
    required this.id,
    required this.method,
    required this.contact,
  });

  factory Subscription.fromJson(Map<String, dynamic> j) => Subscription(
        id: j['id'] as int,
        method: j['method'] as String,
        contact: j['contact'] as String,
      );
}

/// Tracks which messages have been sent at a location
class SentAlert {
  final bool email;
  final bool sms;
  final String? timestamp;

  SentAlert({this.email = false, this.sms = false, this.timestamp});

  SentAlert copyWith({
    bool? email,
    bool? sms,
    String? timestamp,
  }) {
    return SentAlert(
      email: email ?? this.email,
      sms: sms ?? this.sms,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// ───────────────────────────────────────────────────────────
/// State & Providers
/// ───────────────────────────────────────────────────────────

const _itemsPerPage = 5;

/// 1) Fetch subscriptions grouped by location
final subscriptionsByLocationProvider =
    FutureProvider<Map<String, List<Subscription>>>((ref) async {
  final res = await http
      .get(Uri.parse('http://localhost:3000/subscriptions/by-location'));
  if (res.statusCode != 200) {
    throw Exception('Failed to load subscriptions');
  }
  final data = jsonDecode(res.body) as Map<String, dynamic>;
  return data.map((loc, list) => MapEntry(
        loc,
        (list as List<dynamic>)
            .map((j) => Subscription.fromJson(j as Map<String, dynamic>))
            .toList(),
      ));
});

/// UI state providers
final searchQueryProvider = StateProvider<String>((_) => '');
final darkModeProvider = StateProvider<bool>((_) => false);
final currentPageProvider = StateProvider<int>((_) => 0);
final emailLoadingProvider = StateProvider<Map<String, bool>>((_) => {});
final smsLoadingProvider = StateProvider<Map<String, bool>>((_) => {});
final sentAlertsProvider = StateProvider<Map<String, SentAlert>>((_) => {});

/// Derive a filtered list of locations
final filteredLocationsProvider = Provider<List<String>>((ref) {
  final byLoc = ref.watch(subscriptionsByLocationProvider).value ?? {};
  final query = ref.watch(searchQueryProvider).toLowerCase();
  return byLoc.keys.where((loc) => loc.toLowerCase().contains(query)).toList();
});

/// ───────────────────────────────────────────────────────────
/// UI
/// ───────────────────────────────────────────────────────────

class SubscriptionListScreen extends ConsumerStatefulWidget {
  const SubscriptionListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SubscriptionListScreen> createState() =>
      _SubscriptionListScreenState();
}

class _SubscriptionListScreenState
    extends ConsumerState<SubscriptionListScreen> {
  @override
  Widget build(BuildContext context) {
    final subsAsync = ref.watch(subscriptionsByLocationProvider);
    final filtered = ref.watch(filteredLocationsProvider);
    final darkMode = ref.watch(darkModeProvider);
    final page = ref.watch(currentPageProvider);
    final emailLoading = ref.watch(emailLoadingProvider);
    final smsLoading = ref.watch(smsLoadingProvider);
    final sentAlerts = ref.watch(sentAlertsProvider);

    final totalPages = (filtered.length / _itemsPerPage).ceil();
    final start = page * _itemsPerPage;
    final slice = filtered.skip(start).take(_itemsPerPage).toList();

    return AppShell(
      isAdmin: true,
      child: subsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (byLoc) => Container(
          color: darkMode ? Colors.grey[900] : Colors.grey[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search & theme toggle
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search locations...',
                        ),
                        onChanged: (v) {
                          ref.read(searchQueryProvider.notifier).state = v;
                          ref.read(currentPageProvider.notifier).state = 0;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Switch(
                      value: darkMode,
                      onChanged: (b) =>
                          ref.read(darkModeProvider.notifier).state = b,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Paginated list of location cards
                Expanded(
                  child: ListView.builder(
                    itemCount: slice.length,
                    itemBuilder: (_, i) {
                      final loc = slice[i];
                      final subs = byLoc[loc]!;
                      return Card(
                        color: darkMode ? Colors.grey[800] : Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Location header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(loc,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    'Last sent: ${sentAlerts[loc]?.timestamp ?? 'Never'}',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Email subscriptions section
                              if (subs.any((s) => s.method == 'email'))
                                _SubscriptionSection(
                                  title: 'Email',
                                  subscribers:
                                      subs.where((s) => s.method == 'email'),
                                  loading: emailLoading[loc] == true,
                                  sent: sentAlerts[loc]?.email ?? false,
                                  timestamp: sentAlerts[loc]?.timestamp,
                                  darkMode: darkMode,
                                  onSend: () => _sendAlerts(loc, 'email'),
                                ),

                              // SMS subscriptions section
                              if (subs.any((s) => s.method == 'sms'))
                                _SubscriptionSection(
                                  title: 'SMS',
                                  subscribers:
                                      subs.where((s) => s.method == 'sms'),
                                  loading: smsLoading[loc] == true,
                                  sent: sentAlerts[loc]?.sms ?? false,
                                  timestamp: sentAlerts[loc]?.timestamp,
                                  darkMode: darkMode,
                                  onSend: () => _sendAlerts(loc, 'sms'),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Pagination controls
                if (totalPages > 1)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: page > 0
                            ? () =>
                                ref.read(currentPageProvider.notifier).state--
                            : null,
                      ),
                      Text('${page + 1} / $totalPages'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: page < totalPages - 1
                            ? () =>
                                ref.read(currentPageProvider.notifier).state++
                            : null,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Fetch the latest alert detail for [location]
  Future<Map<String, dynamic>?> _fetchLatestAlert(String location) async {
    final res = await http.get(Uri.parse(
        'http://localhost:3000/alerts?location=${Uri.encodeComponent(location)}'));
    if (res.statusCode != 200) return null;
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.isNotEmpty ? list.first as Map<String, dynamic> : null;
  }

  /// Send alerts (email or sms) to all subscribers at [location]
  Future<void> _sendAlerts(String location, String method) async {
    final loadingNotifier =
        method == 'email' ? emailLoadingProvider : smsLoadingProvider;
    ref.read(loadingNotifier.notifier).state = {
      ...ref.read(loadingNotifier),
      location: true
    };

    final alert = await _fetchLatestAlert(location);
    if (alert == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No active alert for $location')));
      ref.read(loadingNotifier.notifier).state = {
        ...ref.read(loadingNotifier),
        location: false
      };
      return;
    }

    final byLoc = ref.read(subscriptionsByLocationProvider).value!;
    final subs = byLoc[location]!.where((s) => s.method == method).toList();

    final sentNotifier = ref.read(sentAlertsProvider.notifier);

    for (final sub in subs) {
      final uri = method == 'email'
          ? Uri.parse('http://localhost:3000/subscriptions/send-email')
          : Uri.parse('http://localhost:3000/api/send-sms');
      final body = method == 'email'
          ? {
              'to': sub.contact,
              'subject': 'Flood Alert for $location',
              'text': alert['description'],
            }
          : {
              'to': sub.contact,
              'message': alert['description'],
            };

      bool success = false;
      try {
        final resp = await http.post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body));
        success = resp.statusCode == 200;
      } catch (_) {
        success = false;
      }

      final prev = ref.read(sentAlertsProvider)[location] ?? SentAlert();
      final updated = method == 'email'
          ? prev.copyWith(
              email: success,
              timestamp: DateFormat.yMd().add_jm().format(DateTime.now()),
            )
          : prev.copyWith(
              sms: success,
              timestamp: DateFormat.yMd().add_jm().format(DateTime.now()),
            );
      sentNotifier.state = {...sentNotifier.state, location: updated};
    }

    ref.read(loadingNotifier.notifier).state = {
      ...ref.read(loadingNotifier),
      location: false
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${method.toUpperCase()} alerts sent for $location')),
    );
  }
}

/// A reusable section for email or SMS subscriptions
class _SubscriptionSection extends StatelessWidget {
  final String title;
  final Iterable<Subscription> subscribers;
  final bool loading;
  final bool sent;
  final String? timestamp;
  final bool darkMode;
  final VoidCallback onSend;

  const _SubscriptionSection({
    required this.title,
    required this.subscribers,
    required this.loading,
    required this.sent,
    required this.timestamp,
    required this.darkMode,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$title Subscriptions',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${subscribers.length} subscribers'),
            ElevatedButton.icon(
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(title == 'Email' ? Icons.email : Icons.sms),
              label: Text('Send $title'),
              onPressed: loading ? null : onSend,
            ),
          ],
        ),
        const SizedBox(height: 4),
        DataTable(
          headingRowColor: MaterialStatePropertyAll(
              darkMode ? Colors.grey[700] : Colors.grey[200]),
          columns: const [
            DataColumn(label: Text('Contact')),
            DataColumn(label: Text('Sent?')),
            DataColumn(label: Text('Last Sent')),
          ],
          rows: subscribers
              .map((s) => DataRow(cells: [
                    DataCell(Text(s.contact)),
                    DataCell(Icon(
                      sent ? Icons.check_circle : Icons.cancel,
                      color: sent ? Colors.green : Colors.red,
                    )),
                    DataCell(Text(timestamp ?? 'Never')),
                  ]))
              .toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
