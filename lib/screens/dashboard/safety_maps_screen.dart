// lib/screens/maps/safety_maps_screen.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../../widgets/app_shell.dart';

/// ───────────────────────────────────────────────────────────
/// Model
/// ───────────────────────────────────────────────────────────
class FloodAlert {
  final int alertId;
  final String alertType;
  final String location;
  final String severity;

  FloodAlert({
    required this.alertId,
    required this.alertType,
    required this.location,
    required this.severity,
  });

  factory FloodAlert.fromJson(Map<String, dynamic> j) => FloodAlert(
        alertId: j['alert_id'] as int,
        alertType: j['alert_type'] as String,
        location: j['location'] as String,
        severity: j['severity'] as String,
      );
}

/// ───────────────────────────────────────────────────────────
/// Riverpod Providers & State
/// ───────────────────────────────────────────────────────────

// 1) Fetch all alerts
final floodAlertsProvider = FutureProvider<List<FloodAlert>>((ref) async {
  final resp = await http.get(Uri.parse('http://localhost:3000/alerts'));
  if (resp.statusCode != 200) throw Exception('Failed to load alerts');
  final list = jsonDecode(resp.body) as List<dynamic>;
  return list
      .map((e) => FloodAlert.fromJson(e as Map<String, dynamic>))
      .toList();
});

// 2) Search text
final searchQueryProvider = StateProvider<String>((_) => '');

// 3) User’s current LatLng
final userLocationProvider = StateProvider<LatLng?>((_) => null);

// 4) Route polyline points
final routePolylineProvider = StateProvider<List<LatLng>>((_) => []);

// 5) Loading flag
final isLoadingProvider = StateProvider<bool>((_) => false);

/// ───────────────────────────────────────────────────────────
/// SafetyMapsScreen
/// ───────────────────────────────────────────────────────────
class SafetyMapsScreen extends ConsumerStatefulWidget {
  const SafetyMapsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SafetyMapsScreen> createState() => _SafetyMapsScreenState();
}

class _SafetyMapsScreenState extends ConsumerState<SafetyMapsScreen> {
  final Completer<GoogleMapController> _mapCtrler =
      Completer<GoogleMapController>();

  static final _initialCamera = CameraPosition(
    target: LatLng(0.1667, 34.1667),
    zoom: 10,
  );

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(floodAlertsProvider);
    final query = ref.watch(searchQueryProvider);
    final userLoc = ref.watch(userLocationProvider);
    final polylinePts = ref.watch(routePolylineProvider);
    final loading = ref.watch(isLoadingProvider);

    return AppShell(
      isAdmin: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== Header =====
            Row(
              children: const [
                Icon(Icons.explore, size: 28, color: Colors.blue),
                SizedBox(width: 8),
                Text('Flood Safety Navigation Map',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),

            // ===== Search & Locate =====
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search address…',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) =>
                        ref.read(searchQueryProvider.notifier).state = v,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: loading ? null : _onSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Search'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: loading ? null : _locateMe,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Locate Me'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== Map & Legend =====
            Expanded(
              child: Row(
                children: [
                  // Map panel
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: _initialCamera,
                          markers: _buildMarkers(alertsAsync, userLoc),
                          polylines: {
                            if (polylinePts.isNotEmpty)
                              Polyline(
                                polylineId: const PolylineId('route'),
                                points: polylinePts,
                                color: Colors.red,
                                width: 4,
                                patterns: [
                                  PatternItem.dash(10),
                                  PatternItem.gap(10)
                                ],
                              ),
                          },
                          onMapCreated: (c) => _mapCtrler.complete(c),
                        ),
                        if (loading)
                          const Positioned.fill(
                            child: ColoredBox(
                              color: Colors.white70,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Legend & Actions panel
                  Expanded(
                    flex: 1,
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Map Legend',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _legendItem(
                                'Flood Alert Zone', Icons.warning_amber),
                            _legendItem(
                                'Your Location', Icons.person_pin_circle),
                            const Divider(),
                            const Text('Quick Actions',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/report'),
                              icon: const Icon(Icons.report),
                              label: const Text('Report Flood'),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/shelters'),
                              icon: const Icon(Icons.home),
                              label: const Text('Find Shelter'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build markers for alerts and user
  Set<Marker> _buildMarkers(
      AsyncValue<List<FloodAlert>> alertsAsync, LatLng? userLoc) {
    final Set<Marker> markers = {};

    alertsAsync.when(
      data: (alerts) {
        for (var a in alerts) {
          final coord = _coords[a.location];
          if (coord != null) {
            markers.add(Marker(
              markerId: MarkerId('alert_${a.alertId}'),
              position: coord,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueAzure),
              onTap: () => _showRouteTo(coord),
            ));
          }
        }
      },
      loading: () {},
      error: (_, __) {},
    );

    if (userLoc != null) {
      markers.add(Marker(
        markerId: const MarkerId('user_loc'),
        position: userLoc,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    return markers;
  }

  Widget _legendItem(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(icon, size: 24),
        const SizedBox(width: 8),
        Text(label),
      ]),
    );
  }

  /// Geocode search query via Nominatim, then animate camera
  Future<void> _onSearch() async {
    final q = ref.read(searchQueryProvider).trim();
    if (q.isEmpty) return;
    ref.read(isLoadingProvider.notifier).state = true;
    try {
      final resp = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(q)}'));
      final list = jsonDecode(resp.body) as List<dynamic>;
      if (list.isNotEmpty) {
        final lat = double.parse(list[0]['lat'] as String);
        final lon = double.parse(list[0]['lon'] as String);
        final ctrl = await _mapCtrler.future;
        await ctrl.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lon), 13),
        );
      }
    } catch (_) {
      // ignore
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  /// Use Geolocator to get device position
  Future<void> _locateMe() async {
    ref.read(isLoadingProvider.notifier).state = true;
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final pt = LatLng(pos.latitude, pos.longitude);
      ref.read(userLocationProvider.notifier).state = pt;
      final ctrl = await _mapCtrler.future;
      await ctrl.animateCamera(CameraUpdate.newLatLngZoom(pt, 13));
    } catch (_) {
      // ignore
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  /// Draw straight‐line route from user to [dest]
  Future<void> _showRouteTo(LatLng dest) async {
    final userPt = ref.read(userLocationProvider);
    if (userPt == null) return;
    ref.read(isLoadingProvider.notifier).state = true;
    try {
      ref.read(routePolylineProvider.notifier).state = [userPt, dest];
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  /// Hardcoded coords for your known locations
  static const Map<String, LatLng> _coords = {
    'Bumadeya': LatLng(-0.1667, 34.1667),
    'Budalangi Central': LatLng(0.1667, 34.1667),
    'Budubusi': LatLng(0.1667, 34.1667),
    'Mundere': LatLng(0.1667, 34.1667),
    'Musoma': LatLng(0.1667, 34.1667),
    'Sibuka': LatLng(0.1667, 34.1667),
    'Sio Port': LatLng(0.1667, 34.1667),
    'Rukala': LatLng(0.1667, 34.1667),
    'Mukhweya': LatLng(0.1667, 34.1667),
    'Sigulu Island': LatLng(0.1667, 34.1667),
    'Siyaya': LatLng(0.1667, 34.1667),
    'Nambuku': LatLng(0.1667, 34.1667),
    'West Bunyala': LatLng(0.1667, 34.1667),
    'East Bunyala': LatLng(0.1667, 34.1667),
    'South Bunyala': LatLng(0.1667, 34.1667),
  };
}
