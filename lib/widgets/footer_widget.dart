import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({Key? key}) : super(key: key);   // ← must be const if you call it with `const`

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[900],
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '© 2025 FMAS. All rights reserved.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/privacy'),
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/terms'),
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
