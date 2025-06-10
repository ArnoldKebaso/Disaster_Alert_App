import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../api/fmas_api.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '', _email = '', _password = '', _confirm = '';
  String _phone = '', _location = '';
  bool _submitting = false, _showPassword = false, _showConfirm = false;

  Future<void> _detectLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _location = '${pos.latitude}, ${pos.longitude}';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _submitting = true);
    try {
      final data = await FmasApi.instance.register(
        username: _username,
        email: _email,
        password: _password,
        phone: _phone,
        location: _location,
      );
      final user = User.fromJson(data);
      ref.read(authProvider.notifier).state =
          AuthState.authenticated(user);
    } catch (e) {
      // show Snackbar
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(children: [
              // Username
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                onSaved: (v) => _username = v!.trim(),
                validator: (v) =>
                (v != null && v.isNotEmpty) ? null : 'Enter username',
              ),
              const SizedBox(height: 12),
              // Email
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (v) => _email = v!.trim(),
                validator: (v) =>
                (v != null && v.contains('@')) ? null : 'Invalid email',
              ),
              const SizedBox(height: 12),
              // Password
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_showPassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
                obscureText: !_showPassword,
                onSaved: (v) => _password = v!,
                validator: (v) =>
                (v != null && v.length >= 6) ? null : 'Min 6 chars',
              ),
              const SizedBox(height: 12),
              // Confirm Password
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirm
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _showConfirm = !_showConfirm),
                  ),
                ),
                obscureText: !_showConfirm,
                validator: (v) => (v == _password)
                    ? null
                    : 'Passwords do not match',
              ),
              const SizedBox(height: 12),
              // Phone Number
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+254712345678',
                ),
                keyboardType: TextInputType.phone,
                onSaved: (v) => _phone = v!.trim(),
                validator: (v) =>
                (v != null && v.startsWith('+')) ? null : 'Include country code',
              ),
              const SizedBox(height: 12),
              // Location field + detect button
              Row(children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Location'),
                    readOnly: true,
                    controller:
                    TextEditingController(text: _location),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _detectLocation,
                  child: const Text('Detect'),
                )
              ]),
              const SizedBox(height: 24),
              // Submit
              _submitting
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Register'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/login'),
                child: const Text('Already have an account? Login'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
