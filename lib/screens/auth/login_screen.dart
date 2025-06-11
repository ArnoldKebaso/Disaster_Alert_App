// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '',
      _password = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    await ref.read(authProvider.notifier).login(_email, _password);
    if (ref
        .read(authProvider)
        .isAuthenticated) context.go('/');
  }

  Future<void> _googleSignIn() async {
    final acct = await GoogleSignIn().signIn();
    if (acct == null) return;
    final auth = await acct.authentication;
    await ref.read(authProvider.notifier).loginWithGoogle(auth.idToken!);
    if (ref
        .read(authProvider)
        .isAuthenticated) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome Back')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onSaved: (v) => _email = v!.trim(),
                validator: (v) =>
                (v != null && v.contains('@')) ? null : 'Invalid email',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                onSaved: (v) => _password = v!,
                validator: (v) =>
                (v != null && v.length >= 6) ? null : 'Min 6 chars',
              ),
              const SizedBox(height: 24),
              if (auth.error != null)
                Text(auth.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              auth.loading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.go('/forgot-password'),
            child: const Text('Forgot Password?'),
          ),
          const Divider(height: 32),
          const Text('Or continue with', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: Image.asset('assets/images/google_logo.png', height: 24),
            label: const Text('Sign in with Google'),
            onPressed: _googleSignIn,
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account? "),
              TextButton(
                onPressed: () => GoRouter.of(context).go('/register'),
                child: const Text('Register'),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
