// lib/screens/auth/register_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';

/// Register Screen with form validation and location detection
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _locationDetected = false;
  String? _selectedLocation;

  // Controllers
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  static const List<String> _locations = [
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

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _loading = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final lat = pos.latitude;
      final lon = pos.longitude;

      // Reverse geocode via Nominatim
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon');
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;
        final detected = address?['city'] ??
            address?['town'] ??
            address?['village'] ??
            data['display_name'];
        if (detected is String) {
          setState(() {
            _selectedLocation = detected;
            _locationDetected = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location detected: $detected')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to detect location')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final payload = {
      'username': _usernameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'role': 'viewer',
      'location': _selectedLocation
    };

    try {
      final res = await http.post(
        Uri.parse('http://localhost:3000/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registered successfully!')),
        );
        context.go('/login');
      } else {
        final err = jsonDecode(res.body)['error'] ?? 'Registration failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.toString())),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting registration')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => v == null || v.length < 3
                    ? 'Username must be at least 3 characters'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  final emailRegex =
                      RegExp(r"^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}");
                  return v == null || !emailRegex.hasMatch(v)
                      ? 'Enter a valid email'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration:
                    const InputDecoration(labelText: 'Phone (+2547...)'),
                keyboardType: TextInputType.phone,
                validator: (v) {
                  final phoneRegex = RegExp(r'^\+2547\d{8}\$');
                  return v == null || !phoneRegex.hasMatch(v)
                      ? 'Enter valid Kenyan phone'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) {
                  if (v == null || v.length < 12) {
                    return 'Password must be at least 12 chars';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(v)) {
                    return 'Include at least one uppercase';
                  }
                  if (!RegExp(r'[a-z]').hasMatch(v)) {
                    return 'Include at least one lowercase';
                  }
                  if (!RegExp(r'\d').hasMatch(v)) {
                    return 'Include at least one number';
                  }
                  if (!RegExp(r'[^A-Za-z0-9]').hasMatch(v)) {
                    return 'Include at least one special char';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (v) {
                  if (v != _passwordCtrl.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Location'),
                      value: _selectedLocation,
                      items: _locations
                          .map((loc) => DropdownMenuItem(
                                value: loc,
                                child: Text(loc),
                              ))
                          .toList(),
                      onChanged: _locationDetected
                          ? null
                          : (v) => setState(() => _selectedLocation = v),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Select or detect location'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _detectLocation,
                    child: const Text('Detect'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                      : const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
