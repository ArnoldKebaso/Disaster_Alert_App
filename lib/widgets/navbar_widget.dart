import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.blue[800],
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo on the left
          GestureDetector(
            onTap: () => context.go('/'),
            child: Image.asset(
              'assets/images/Logo.png',
              height: 40,
            ),
          ),

          // (A) Navigation buttons on the right
          Row(
            children: [
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text(
                  'Home',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(width: 16),

              // <— Update this “About Us” button:
              TextButton(
                onPressed: () => context.go('/about'),  // ← newly added
                child: const Text(
                  'About Us',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(width: 16),

              TextButton(
                onPressed: () => context.go('/contact'),
                child: const Text(
                  'Contact Us',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(width: 16),

              TextButton(
                onPressed: () => context.go('/faq'),
                child: const Text(
                  'FAQ',
                  style: TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(width: 16),

              TextButton(
                onPressed: () => context.go('/donate'),
                child: const Text(
                  'Donate',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
