import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Simple data class for each side‐menu item.
class _MenuItem {
  final String label;
  final String route;
  final IconData icon;

  const _MenuItem({
    required this.label,
    required this.route,
    required this.icon,
  });
}

/// A reusable “shell” that wraps dashboard screens with
/// an AppBar + Drawer (i.e. your React Layout.tsx → Flutter).
/// Pass `isAdmin: true` to swap in the admin menu.
class AppShell extends StatelessWidget {
  final Widget child;
  final bool isAdmin;

  const AppShell({
    required this.child,
    this.isAdmin = false,
    Key? key,
  }) : super(key: key);

  // Define the user‐side menu
  static const List<_MenuItem> _userMenu = [
    _MenuItem(label: 'Home', route: '/dashboard', icon: Icons.home),
    _MenuItem(label: 'Alerts', route: '/alerts', icon: Icons.notifications),
    _MenuItem(label: 'Community Report', route: '/report', icon: Icons.report),
    _MenuItem(label: 'Safety Map', route: '/maps', icon: Icons.map),
    _MenuItem(label: 'Agencies', route: '/agencies', icon: Icons.people),
    _MenuItem(label: 'Resources', route: '/userReSources', icon: Icons.book),
    _MenuItem(label: 'My Profile', route: '/userProfile', icon: Icons.person),
  ];

  // Define the admin‐side menu
  static const List<_MenuItem> _adminMenu = [
    _MenuItem(
        label: 'Subscription', route: '/subscriptions', icon: Icons.people),
    _MenuItem(label: 'Modify Alerts', route: '/adminAlerts', icon: Icons.edit),
    _MenuItem(
        label: 'Create Alert', route: '/createAlert', icon: Icons.add_alert),
    _MenuItem(
        label: 'Community Reports',
        route: '/adminCommunityReports',
        icon: Icons.group),
    _MenuItem(label: 'Flood Reports', route: '/adminReport', icon: Icons.cloud),
    _MenuItem(
        label: 'Subscribed Users',
        route: '/subscriptionReport',
        icon: Icons.person_add),
    _MenuItem(
        label: 'Flood Analytics', route: '/floods', icon: Icons.bar_chart),
    _MenuItem(
        label: 'Demographics',
        route: '/demographics',
        icon: Icons.insert_chart),
    _MenuItem(
        label: 'Manage Resources', route: '/adminResources', icon: Icons.build),
  ];

  @override
  Widget build(BuildContext context) {
    final menuItems = isAdmin ? _adminMenu : _userMenu;

    return Scaffold(
      // AppBar with a hamburger that opens the Drawer
      appBar: AppBar(
        title: Text('FMAS Dashboard'),
        backgroundColor: Colors.blue[800],
      ),

      // Drawer that holds all the routes
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer header
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[800]),
              child: Center(
                child: Text(
                  'FMAS Menu',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
            // One ListTile per route
            for (var item in menuItems)
              ListTile(
                leading: Icon(item.icon, color: Colors.black54),
                title: Text(item.label),
                onTap: () {
                  Navigator.of(context).pop(); // close drawer
                  context.go(item.route); // navigate
                },
              ),
            const Divider(),
            // Common logout button (implement your own logic)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Logout',
                  style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                // TODO: call your sign-out/provider method
                context.go('/login');
              },
            ),
          ],
        ),
      ),

      // Main content
      body: child,
    );
  }
}
