// lib/main.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/home/home_screen.dart';
import 'screens/about/about_screen.dart';
import 'screens/contact/contact_screen.dart';
import 'screens/faq/faq_screen.dart';         // ← new FAQ import
import 'screens/donate/donate_screen.dart';   // ← new Donate import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: '/contact',
          builder: (context, state) => const ContactScreen(),
        ),
        GoRoute(
          path: '/faq',
          builder: (context, state) => const FAQScreen(),
        ),
        GoRoute(
          path: '/donate',
          builder: (context, state) => const DonateScreen(),
        ),
        // Add additional routes here (e.g. /userResources, /alerts, etc.)
      ],
    );

    return MaterialApp.router(
      title: 'FMAS Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
