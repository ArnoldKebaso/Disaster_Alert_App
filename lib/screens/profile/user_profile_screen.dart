// lib/screens/profile/user_profile_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../widgets/app_shell.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';

/// ───────────────────────────────────────────────────────────
/// UserModel
/// ───────────────────────────────────────────────────────────
class UserModel {
  final String id; // note: your User model holds id as a String
  final String username;
  final String email;
  final String phone;
  final String location;
  final String profilePhoto;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.location,
    required this.profilePhoto,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        id: j['user_id'].toString(),
        username: j['username'] as String,
        email: j['email'] as String,
        phone: j['phone'] as String,
        location: j['location'] as String,
        profilePhoto: j['profilePhoto'] as String,
      );
}

/// ───────────────────────────────────────────────────────────
/// Profile fetcher
/// ───────────────────────────────────────────────────────────
final userProfileProvider = FutureProvider<UserModel>((ref) async {
  final authState = ref.watch(authProvider);
  final uid = authState.user?.id;
  if (uid == null) throw Exception('Not logged in');
  final res = await http.get(
    Uri.parse('http://localhost:3000/user/$uid'),
    // we rely on your http-only cookie for auth
  );
  if (res.statusCode != 200) {
    throw Exception('Failed to load profile (${res.statusCode})');
  }
  return UserModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
});

/// ───────────────────────────────────────────────────────────
/// UI
/// ───────────────────────────────────────────────────────────
class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _phoneCtrl = TextEditingController();
  String? _location;
  String? _profilePhotoUrl;
  XFile? _pickedImage;

  final _currentPwd = TextEditingController();
  final _newPwd = TextEditingController();
  final _confirmPwd = TextEditingController();
  bool _showCurrent = false, _showNew = false, _showConfirm = false;
  bool _isLoading = false;
  bool _inited = false;

  static const _locOptions = [
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

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _currentPwd.dispose();
    _newPwd.dispose();
    _confirmPwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profileAsync = ref.watch(userProfileProvider);

    return AppShell(
      isAdmin: false,
      child: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          // init fields once
          if (!_inited) {
            _phoneCtrl.text = profile.phone;
            _location = profile.location;
            _profilePhotoUrl =
                profile.profilePhoto.isNotEmpty ? profile.profilePhoto : null;
            _inited = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo + basic info
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: _pickedImage != null
                              ? FileImage(File(_pickedImage!.path))
                              : _profilePhotoUrl != null
                                  ? NetworkImage(_profilePhotoUrl!)
                                  : null as ImageProvider<Object>?,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickAndUploadPhoto,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.username,
                              style: Theme.of(context).textTheme.titleMedium),
                          Text(profile.email),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
                const Text('Edit Contact Info',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                TextField(
                  controller: _phoneCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Phone Number', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                Row(children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _location,
                      decoration: const InputDecoration(
                          labelText: 'Location', border: OutlineInputBorder()),
                      items: _locOptions
                          .map(
                              (l) => DropdownMenuItem(value: l, child: Text(l)))
                          .toList(),
                      onChanged: (v) => setState(() => _location = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _detectLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Detect'),
                  ),
                ]),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed:
                      _isLoading ? null : () => _updateProfile(profile.id),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Changes'),
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),

                const Text('Change Password',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                _buildPwdField('Current Password', _currentPwd, _showCurrent,
                    () {
                  setState(() => _showCurrent = !_showCurrent);
                }),
                const SizedBox(height: 12),
                _buildPwdField('New Password', _newPwd, _showNew, () {
                  setState(() => _showNew = !_showNew);
                }),
                const SizedBox(height: 12),
                _buildPwdField('Confirm Password', _confirmPwd, _showConfirm,
                    () {
                  setState(() => _showConfirm = !_showConfirm);
                }),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _isLoading ? null : () => _changePassword(),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Update Password'),
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPwdField(String label, TextEditingController ctl, bool visible,
          VoidCallback toggle) =>
      TextField(
        controller: ctl,
        obscureText: !visible,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
            onPressed: toggle,
          ),
        ),
      );

  Future<void> _pickAndUploadPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _pickedImage = file);

    // upload
    final req = http.MultipartRequest(
        'POST', Uri.parse('http://localhost:3000/user/profile-photo'));
    req.files.add(await http.MultipartFile.fromPath('profilePhoto', file.path));
    final rsp = await req.send();
    if (rsp.statusCode == 200) {
      final body = await rsp.stream.bytesToString();
      final data = jsonDecode(body);
      setState(() => _profilePhotoUrl = data['profilePhoto'] as String);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Photo updated')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Upload failed')));
    }
  }

  Future<void> _detectLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final res = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}'));
      final json = jsonDecode(res.body);
      final addr = json['address'] ?? {};
      final place = addr['city'] ??
          addr['town'] ??
          addr['village'] ??
          json['display_name'] ??
          '';
      setState(() => _location = place);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Detected: $place')));
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Location failed')));
    }
  }

  Future<void> _updateProfile(String id) async {
    setState(() => _isLoading = true);
    final res = await http.put(
      Uri.parse('http://localhost:3000/user/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': _phoneCtrl.text,
        'location': _location,
      }),
    );
    if (res.statusCode == 200) {
      ref.invalidate(userProfileProvider);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile updated')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Update failed')));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _changePassword() async {
    if (_newPwd.text != _confirmPwd.text ||
        _newPwd.text.isEmpty ||
        _currentPwd.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Passwords invalid')));
      return;
    }
    setState(() => _isLoading = true);
    final res = await http.put(
      Uri.parse('http://localhost:3000/user/change-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
          {'currentPassword': _currentPwd.text, 'newPassword': _newPwd.text}),
    );
    if (res.statusCode == 200) {
      ref.read(authProvider.notifier).logout();
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${res.body}')));
    }
    setState(() => _isLoading = false);
  }
}
