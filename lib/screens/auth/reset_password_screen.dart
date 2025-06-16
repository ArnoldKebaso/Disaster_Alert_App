// lib/screens/auth/reset_password_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../api/fmas_api.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newCtl = TextEditingController();
  final _confirmCtl = TextEditingController();
  bool _loading = false;
  bool _showNew = false;
  bool _showConfirm = false;

  String? get _email => Uri.base.queryParameters['email'];

  String? get _token => Uri.base.queryParameters['token'];

  String? _validatePassword(String? v) {
    if (v == null || v.length < 12) {
      return 'At least 12 chars';
    }
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return 'Need uppercase';
    }
    if (!RegExp(r'[a-z]').hasMatch(v)) {
      return 'Need lowercase';
    }
    if (!RegExp(r'\d').hasMatch(v)) {
      return 'Need number';
    }
    if (!RegExp(r'[^A-Za-z0-9]').hasMatch(v)) {
      return 'Need special char';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_email == null || _token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing link parameters')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final msg = await FmasApi.instance.resetPassword(
        email: _email!,
        token: _token!,
        newPassword: _newCtl.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      context.go('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reset failed')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _newCtl.dispose();
    _confirmCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Set your new password',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _newCtl,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                            _showNew ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _showNew = !_showNew),
                      ),
                    ),
                    obscureText: !_showNew,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmCtl,
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
                    validator: (v) =>
                        v == _newCtl.text ? null : 'Passwords do not match',
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Reset Password'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
