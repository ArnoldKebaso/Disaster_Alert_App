// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    // Trigger the login flow in AuthNotifier
    await ref.read(authProvider.notifier).login(_email, _password);
    // On success, GoRouter’s redirect will send us to '/'
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email input
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => _email = val!.trim(),
                validator: (val) =>
                (val?.contains('@') ?? false) ? null : 'Invalid email',
              ),
              const SizedBox(height: 16),

              // Password input
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (val) => _password = val!,
                validator: (val) =>
                (val != null && val.length >= 6)
                    ? null
                    : 'Min 6 characters',
              ),
              const SizedBox(height: 24),

              // Error message
              if (auth.error != null)
                Text(auth.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),

              // Submit button or loading spinner
              auth.loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
