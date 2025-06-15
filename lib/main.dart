// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';

// Public screens
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/about/about_screen.dart';
import 'screens/contact/contact_screen.dart';
import 'screens/faq/faq_screen.dart';
import 'screens/donate/donate_screen.dart';
import 'screens/resources/resources_screen.dart';

// User‐only screens (wrapped in AppShell)
import 'screens/dashboard/user_dashboard.dart';
import 'screens/alerts/active_alerts_screen.dart';
import 'screens/dashboard/community_reporting_screen.dart';
import 'screens/dashboard/safety_maps_screen.dart';
import 'screens/dashboard/agencies_screen.dart';
import 'screens/profile/user_profile_screen.dart';

// Admin‐only screens
import 'screens/dashboard/admin_dashboard.dart';
import 'screens/dashboard/admin_alerts_screen.dart';
import 'screens/dashboard/create_alert_screen.dart';
import 'screens/dashboard/subscription_list_screen.dart';
import 'screens/dashboard/admin_community_reports_screen.dart';
import 'screens/dashboard/admin_reports_screen.dart';
import 'screens/dashboard/subscription_report_screen.dart';

//import 'screens/dashboard/admin_resources_screen.dart';
import 'screens/dashboard/alerts_management_screen.dart';

//import 'screens/dashboard/floods_screen.dart';
//import 'screens/dashboard/demographics_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final loggedIn = auth.isAuthenticated;
    final role = auth.user?.role;

    final router = GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final loc = state.uri.path;

        // 1) If not authenticated, only allow public paths:
        const publicPaths = [
          '/',
          '/login',
          '/register',
          '/forgot-password',
          '/reset-password',
          '/about',
          '/contact',
          '/faq',
          '/donate',
          '/resources',
        ];
        if (!loggedIn && !publicPaths.contains(loc)) {
          return '/login';
        }

        // 2) If authenticated, prevent going to auth‐only pages:
        const authPages = ['/login', '/register'];
        if (loggedIn && authPages.contains(loc)) {
          return '/';
        }

        // 3) Admin‐only guard:
        const adminPaths = [
          '/admin',
          '/adminAlerts',
          '/createAlert',
          '/subscriptions',
          '/adminCommunityReports',
          '/adminReport',
          '/subscriptionReport',
          '/adminResources',
          '/alertsManagement',
          '/floods',
          '/demographics',
        ];
        if (adminPaths.contains(loc) && role != 'admin') {
          return '/dashboard';
        }

        // otherwise no redirection
        return null;
      },
      routes: [
        // Public
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(
            path: '/forgot-password',
            builder: (_, __) => const ForgotPasswordScreen()),
        GoRoute(
            path: '/reset-password',
            builder: (_, __) => const ResetPasswordScreen()),
        GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
        GoRoute(path: '/contact', builder: (_, __) => const ContactScreen()),
        GoRoute(path: '/faq', builder: (_, __) => const FAQScreen()),
        GoRoute(path: '/donate', builder: (_, __) => const DonateScreen()),
        GoRoute(
            path: '/resources', builder: (_, __) => const ResourcesScreen()),

        // User area
        GoRoute(path: '/dashboard', builder: (_, __) => const UserDashboard()),
        GoRoute(path: '/alerts', builder: (_, __) => const ActiveAlertsPage()),
        GoRoute(
            path: '/report',
            builder: (_, __) => const CommunityReportingScreen()),
        GoRoute(path: '/maps', builder: (_, __) => const SafetyMapsScreen()),
        GoRoute(path: '/agencies', builder: (_, __) => const AgenciesScreen()),
        GoRoute(
            path: '/userProfile',
            builder: (_, __) => const UserProfileScreen()),

        // Admin area
        GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),
        GoRoute(
            path: '/adminAlerts',
            builder: (_, __) => const AdminAlertsScreen()),
        GoRoute(
            path: '/createAlert',
            builder: (_, __) => const CreateAlertScreen()),
        GoRoute(
            path: '/subscriptions',
            builder: (_, __) => const SubscriptionListScreen()),
        GoRoute(
            path: '/adminCommunityReports',
            builder: (_, __) => const AdminCommunityReportsScreen()),
        GoRoute(
            path: '/adminReport',
            builder: (_, __) => const AdminReportsScreen()),
        GoRoute(
            path: '/subscriptionReport',
            builder: (_, __) => const SubscriptionReportScreen()),
        // GoRoute(path: '/adminResources',          builder: (_, __) => const AdminResourcesScreen()),
        GoRoute(
            path: '/alertsManagement',
            builder: (_, __) => const AlertsManagementScreen()),
        // GoRoute(path: '/floods',                  builder: (_, __) => const FloodsScreen()),
        // GoRoute(path: '/demographics',            builder: (_, __) => const DemographicsScreen()),
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
