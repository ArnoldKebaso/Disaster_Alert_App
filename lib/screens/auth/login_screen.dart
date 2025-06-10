import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../api/fmas_api.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '', _password = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    await ref.read(authProvider.notifier).login(_email, _password);
  }

  Future<void> _googleSignIn() async {
    final account = await GoogleSignIn().signIn();
    if (account == null) return; // user cancelled
    final auth = await account.authentication;
    final data = await FmasApi.instance.loginWithGoogle(auth.idToken!);
    final user = User.fromJson(data);
    ref.read(authProvider.notifier).state =
        AuthState.authenticated(user);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome Back')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      onPressed: () => setState(() {}),
                    ),
                  ),
                  obscureText: true,
                  onSaved: (v) => _password = v!,
                  validator: (v) =>
                  (v != null && v.length >= 6) ? null : 'Min 6 chars',
                ),
                const SizedBox(height: 24),
                auth.error != null
                    ? Text(auth.error!, style: const TextStyle(color: Colors.red))
                    : const SizedBox.shrink(),
                const SizedBox(height: 12),
                auth.loading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.push('/forgot-password'),
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
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Don\'t have an account? '),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: const Text('Register'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
