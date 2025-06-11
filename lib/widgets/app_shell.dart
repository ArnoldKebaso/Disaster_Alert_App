// lib/widgets/app_shell.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({required this.child, Key? key}) : super(key: key);

  static const _navItems = [
    _NavData('Dashboard', Icons.dashboard, '/dashboard'),
    _NavData('Alerts', Icons.warning, '/dashboard/alerts'),
    _NavData('Reports', Icons.folder_open, '/dashboard/reports'),
    _NavData('Profile', Icons.person, '/dashboard/profile'),
    // Add more user routes...
  ];

  static const _adminExtra = [
    _NavData('Manage Alerts', Icons.admin_panel_settings, '/admin/alerts'),
    _NavData('Subscriptions', Icons.list_alt, '/admin/subscriptions'),
    // Add more admin routes...
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isAdmin = auth.user?.email == 'admin@example.com'; // or by role

    final items = [
      ..._navItems,
      if (isAdmin) ..._adminExtra,
      _NavData('Logout', Icons.logout, '/logout'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FMAS Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: items.map((item) {
            return ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              onTap: () {
                Navigator.pop(context);
                if (item.route == '/logout') {
                  ref.read(authProvider.notifier).logout();
                  context.go('/login');
                } else {
                  context.go(item.route);
                }
              },
            );
          }).toList(),
        ),
      ),
      body: child,
    );
  }
}

class _NavData {
  final String label;
  final IconData icon;
  final String route;

  const _NavData(this.label, this.icon, this.route);
}
