import 'package:flutter/material.dart';
import '../../widgets/app_shell.dart';

/// Your “Admin Dashboard” landing page.
/// Set isAdmin:true to get the admin menu items.
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AppShell(
      isAdmin: true,
      child: Center(
        child: Text(
          'Welcome, Admin!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
