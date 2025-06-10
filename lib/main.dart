// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';   // Riverpod core
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';                     // Auth state
import 'screens/auth/login_screen.dart';                   // Login flow
import 'screens/home/home_screen.dart';
import 'screens/about/about_screen.dart';
import 'screens/contact/contact_screen.dart';
import 'screens/faq/faq_screen.dart';
import 'screens/donate/donate_screen.dart';
import 'screens/resources/resources_screen.dart';

void main() {
  // Wrap the entire app in ProviderScope to enable Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state (isAuthenticated flag)
    final authState = ref.watch(authProvider);

    // Configure GoRouter with an auth-guard
    final router = GoRouter(
      initialLocation: '/',
      // Called on every navigation attempt
      redirect: (BuildContext context, GoRouterState state) {
        final loggingIn = state.uri.toString() == '/login';
        // If not authenticated and not heading to /login, redirect to /login
        if (!authState.isAuthenticated && !loggingIn) return '/login';
        // If authenticated and trying to go to /login, send to home
        if (authState.isAuthenticated && loggingIn) return '/';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),

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

        GoRoute(
          path: '/resources',
          builder: (context, state) => const ResourcesScreen(),
        ),

        // TODO: add protected dashboard routes here (e.g. /dashboard, /alerts, etc.)
      ],
    );

    return MaterialApp.router(
      title: 'FMAS Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}


// // lib/main.dart
//
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// import 'screens/home/home_screen.dart';
// import 'screens/about/about_screen.dart';
// import 'screens/contact/contact_screen.dart';
// import 'screens/faq/faq_screen.dart';         // ← new FAQ import
// import 'screens/donate/donate_screen.dart';
// import 'screens/resources/resources_screen.dart';  // ← new Resources import// ← new Donate import
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final GoRouter _router = GoRouter(
//       initialLocation: '/',
//       routes: [
//         GoRoute(
//           path: '/',
//           builder: (context, state) => const HomeScreen(),
//         ),
//         GoRoute(
//           path: '/about',
//           builder: (context, state) => const AboutScreen(),
//         ),
//         GoRoute(
//           path: '/contact',
//           builder: (context, state) => const ContactScreen(),
//         ),
//         GoRoute(
//           path: '/faq',
//           builder: (context, state) => const FAQScreen(),
//         ),
//         GoRoute(
//           path: '/donate',
//           builder: (context, state) => const DonateScreen(),
//         ),
//             GoRoute(
//               path: '/resources',                     // ← route path
//               builder: (context, state) => const ResourcesScreen(),
//             ),
//         // Add additional routes here (e.g. /userResources, /alerts, etc.)
//       ],
//     );
//
//     return MaterialApp.router(
//       title: 'FMAS Flutter App',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       routerConfig: _router,
//     );
//   }
// }
