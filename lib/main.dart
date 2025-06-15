import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Your screens:
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/user_dashboard.dart';
import 'screens/dashboard/admin_dashboard.dart';
import 'screens/alerts/active_alerts_screen.dart'; // ← implement next
// …plus any other pages (contact, about, etc.)
import 'providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider); // your auth state

    final router = GoRouter(
      initialLocation: '/dashboard', // start here
      // redirect: (ctx, state) {
      //   final loggingIn =
      //       state.uri.path == '/login' || state.uri.path == '/register';
      //   if (!auth.isAuthenticated && !loggingIn) return '/login';
      //   if (auth.isAuthenticated && loggingIn) return '/dashboard';
      //   return null;
      // },
      routes: [
        /// Public
        // GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        // GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

        /// User Dashboard & sub‐routes
        GoRoute(path: '/dashboard', builder: (_, __) => const UserDashboard()),
        GoRoute(path: '/alerts', builder: (_, __) => const ActiveAlertsPage()),
        // …add /report, /maps, /agencies, etc. here

        /// Admin Dashboard & sub‐routes
        GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),
        // …add /adminAlerts, /createAlert, etc. here
      ],
    );

    return MaterialApp.router(
      title: 'FMAS Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

// // lib/main.dart
//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod core
// import 'package:go_router/go_router.dart'; // GoRouter
//
// import 'providers/auth_provider.dart';
// import 'screens/auth/login_screen.dart';
// import 'screens/auth/register_screen.dart';
// import 'screens/home/home_screen.dart';
// import 'screens/about/about_screen.dart';
// import 'screens/contact/contact_screen.dart';
// import 'screens/faq/faq_screen.dart';
// import 'screens/donate/donate_screen.dart';
// import 'screens/resources/resources_screen.dart';
//
// void main() {
//   runApp(const ProviderScope(child: MyApp()));
// }
//
// class MyApp extends ConsumerWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authProvider);
//
//     final router = GoRouter(
//       initialLocation: '/',
//       redirect: (BuildContext context, GoRouterState state) {
//         // Use state.uri.path to match exactly
//         final path = state.uri.path;
//         final isAuthRoute = path == '/login' || path == '/register';
//         if (!authState.isAuthenticated && !isAuthRoute) {
//           return '/login';
//         }
//         if (authState.isAuthenticated && isAuthRoute) {
//           return '/';
//         }
//         return null;
//       },
//       routes: [
//         GoRoute(
//           path: '/login',
//           builder: (ctx, s) => const LoginScreen(),
//         ),
//         GoRoute(
//           path: '/register',
//           builder: (ctx, s) => const RegisterScreen(), // must point here
//         ),
//         GoRoute(
//           path: '/',
//           builder: (ctx, s) => const HomeScreen(),
//         ),
//         GoRoute(
//           path: '/about',
//           builder: (ctx, s) => const AboutScreen(),
//         ),
//         GoRoute(
//           path: '/contact',
//           builder: (ctx, s) => const ContactScreen(),
//         ),
//         GoRoute(
//           path: '/faq',
//           builder: (ctx, s) => const FAQScreen(),
//         ),
//         GoRoute(
//           path: '/donate',
//           builder: (ctx, s) => const DonateScreen(),
//         ),
//         GoRoute(
//           path: '/resources',
//           builder: (ctx, s) => const ResourcesScreen(),
//         ),
//       ],
//     );
//
//     return MaterialApp.router(
//       title: 'FMAS Flutter App',
//       debugShowCheckedModeBanner: false,
//       routerConfig: router,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//     );
//   }
// }
