import 'package:flutter/material.dart';
import '../../widgets/app_shell.dart';

/// Your “User Dashboard” landing page.
/// Wrap any child in AppShell to get the drawer/nav.
class UserDashboard extends StatelessWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AppShell(
      child: Center(
        child: Text(
          'Welcome to your Dashboard!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
