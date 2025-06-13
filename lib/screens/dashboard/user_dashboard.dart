// lib/screens/dashboard/user_dashboard.dart

import 'package:flutter/material.dart';
import '../../widgets/app_shell.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch alerts via provider if needed...

    return const AppShell(
      child: Center(
        child:
            Text('Welcome to your Dashboard!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
