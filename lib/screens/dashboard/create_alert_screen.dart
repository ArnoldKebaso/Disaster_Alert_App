// lib/screens/dashboard/create_alert_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

import '../../widgets/app_shell.dart';

/// ───────────────────────────────────────────────────────────
/// Models for dropdown options
/// ───────────────────────────────────────────────────────────
class AlertType {
  final String value;
  final String label;
  final String description;

  const AlertType(this.value, this.label, this.description);
}

const _alertTypes = <AlertType>[
  AlertType('FlashFlood', '⚡ Flash Flood', 'Sudden, intense flooding.'),
  AlertType('RiverFlood', '🌊 River Flood', 'Overflowing rivers and streams.'),
  AlertType('CoastalFlood', '🌴 Coastal Flood', 'Flooding along coastlines.'),
  AlertType('UrbanFlood', '🏙️ Urban Flood', 'Flooding in cities and towns.'),
  AlertType('ElNinoFlooding', '🌧️ El Niño Flooding',
      'Flooding due to El Niño effects.'),
];

const _locations = <String>[
  "Bumadeya",
  "Budalangi Central",
  "Budubusi",
  "Mundere",
  "Musoma",
  "Sibuka",
  "Sio Port",
  "Rukala",
  "Mukhweya",
  "Sigulu Island",
  "Siyaya",
  "Nambuku",
  "West Bunyala",
  "East Bunyala",
  "South Bunyala",
];

const _severities = <String>['Low', 'Medium', 'High'];

/// ───────────────────────────────────────────────────────────
/// Screen
/// ───────────────────────────────────────────────────────────
class CreateAlertScreen extends ConsumerStatefulWidget {
  const CreateAlertScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateAlertScreen> createState() => _CreateAlertScreenState();
}

class _CreateAlertScreenState extends ConsumerState<CreateAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  AlertType? _selectedType;
  String? _selectedSeverity;
  String? _selectedLocation;

  final _descriptionCtl = TextEditingController();
  final _currentWaterCtl = TextEditingController();
  final _predictedWaterCtl = TextEditingController();
  final _evacRoutesCtl = TextEditingController();
  final _contactsCtl = TextEditingController();
  final _precautionsCtl = TextEditingController();
  final _forecast24Ctl = TextEditingController();
  final _forecast48Ctl = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final payload = {
      'alert_type': _selectedType!.value,
      'severity': _selectedSeverity,
      'location': _selectedLocation,
      'description': _descriptionCtl.text.trim(),
      'water_levels': {
        'current': _currentWaterCtl.text.trim(),
        'predicted': _predictedWaterCtl.text.trim(),
      },
      'evacuation_routes': _evacRoutesCtl.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      'emergency_contacts': _contactsCtl.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      'precautionary_measures': _precautionsCtl.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      'weather_forecast': {
        'next_24_hours': _forecast24Ctl.text.trim(),
        'next_48_hours': _forecast48Ctl.text.trim(),
      },
      'status': 'active',
    };

    try {
      final res = await http.post(
        Uri.parse('http://localhost:3000/alerts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (res.statusCode == 201 || res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert created successfully!')),
        );
        _formKey.currentState!.reset();
        _descriptionCtl.clear();
        _currentWaterCtl.clear();
        _predictedWaterCtl.clear();
        _evacRoutesCtl.clear();
        _contactsCtl.clear();
        _precautionsCtl.clear();
        _forecast24Ctl.clear();
        _forecast48Ctl.clear();
        setState(() {
          _selectedType = null;
          _selectedSeverity = null;
          _selectedLocation = null;
        });
      } else {
        throw Exception('Failed to create');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create the alert.')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _descriptionCtl.dispose();
    _currentWaterCtl.dispose();
    _predictedWaterCtl.dispose();
    _evacRoutesCtl.dispose();
    _contactsCtl.dispose();
    _precautionsCtl.dispose();
    _forecast24Ctl.dispose();
    _forecast48Ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      isAdmin: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Create a New Alert',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Alert Type
              DropdownButtonFormField<AlertType>(
                decoration: const InputDecoration(labelText: 'Alert Type'),
                items: _alertTypes
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text('${t.label} — ${t.description}'),
                        ))
                    .toList(),
                value: _selectedType,
                validator: (v) =>
                    v == null ? 'Please select an alert type' : null,
                onChanged:
                    _loading ? null : (v) => setState(() => _selectedType = v),
              ),
              const SizedBox(height: 16),

              // Severity
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Severity'),
                items: _severities
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s),
                        ))
                    .toList(),
                value: _selectedSeverity,
                validator: (v) => v == null ? 'Please select severity' : null,
                onChanged: _loading
                    ? null
                    : (v) => setState(() => _selectedSeverity = v),
              ),
              const SizedBox(height: 16),

              // Location
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Location'),
                items: _locations
                    .map((l) => DropdownMenuItem(
                          value: l,
                          child: Text(l),
                        ))
                    .toList(),
                value: _selectedLocation,
                validator: (v) => v == null ? 'Please select location' : null,
                onChanged: _loading
                    ? null
                    : (v) => setState(() => _selectedLocation = v),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionCtl,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                enabled: !_loading,
              ),
              const SizedBox(height: 16),

              // Water levels
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _currentWaterCtl,
                      decoration: const InputDecoration(
                        labelText: 'Current Water Level',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
                      enabled: !_loading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _predictedWaterCtl,
                      decoration: const InputDecoration(
                        labelText: 'Predicted Water Level',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
                      enabled: !_loading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Evacuation Routes
              TextFormField(
                controller: _evacRoutesCtl,
                decoration: const InputDecoration(
                  labelText: 'Evacuation Routes (one per line)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                enabled: !_loading,
              ),
              const SizedBox(height: 16),

              // Emergency Contacts
              TextFormField(
                controller: _contactsCtl,
                decoration: const InputDecoration(
                  labelText: 'Emergency Contacts (one per line)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                enabled: !_loading,
              ),
              const SizedBox(height: 16),

              // Precautionary Measures
              TextFormField(
                controller: _precautionsCtl,
                decoration: const InputDecoration(
                  labelText: 'Precautionary Measures (one per line)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) => (v ?? '').trim().isEmpty ? 'Required' : null,
                enabled: !_loading,
              ),
              const SizedBox(height: 16),

              // Weather Forecast
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _forecast24Ctl,
                      decoration: const InputDecoration(
                        labelText: 'Forecast Next 24h',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
                      enabled: !_loading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _forecast48Ctl,
                      decoration: const InputDecoration(
                        labelText: 'Forecast Next 48h',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v ?? '').isEmpty ? 'Required' : null,
                      enabled: !_loading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Alert'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
