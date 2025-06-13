// lib/screens/dashboard/admin_dashboard.dart

import 'package:flutter/material.dart';
import '../../widgets/app_shell.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch admin metrics via provider...

    return const AppShell(
      child: Center(
        child: Text('Admin Control Panel', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
