// lib/widgets/navbar_widget.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Responsive Navbar using a standard AppBar + Drawer approach.
/// - On narrow screens (<600px), AppBar shows a working hamburger automatically.
/// - On wide screens (>=600px), we hide the default leading and show inline buttons.
class NavbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const NavbarWidget({Key? key}) : super(key: key);

  // Height of the AppBar
  @override
  Size get preferredSize => const Size.fromHeight(56);

  // Navigation items (label + route)
  static const List<_NavItemData> _navItems = [
    _NavItemData(label: 'Home', route: '/'),
    _NavItemData(label: 'About Us', route: '/about'),
    _NavItemData(label: 'Contact Us', route: '/contact'),
    _NavItemData(label: 'FAQ', route: '/faq'),
    _NavItemData(label: 'Donate', route: '/donate'),
  ];

  @override
  Widget build(BuildContext context) {
    // Check screen width to decide layout
    final bool isWide = MediaQuery.of(context).size.width >= 600;

    return AppBar(
      backgroundColor: Colors.blue[800],
      elevation: 2,
      automaticallyImplyLeading: !isWide,
      // When isWide == true, hide the default leading (hamburger).
      // When isWide == false, AppBar will show the hamburger automatically
      // because we have a Drawer attached to the Scaffold.

      title: Row(
        children: [
          // ===== LOGO =====
          SizedBox(
            height: 32,
            child: GestureDetector(
              onTap: () => context.go('/'),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) {
                  // Placeholder if logo fails to load
                  return const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 32,
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Optional: App name text next to logo (uncomment if you want)
          // Text(
          //   'FMAS',
          //   style: TextStyle(
          //     color: Colors.white,
          //     fontSize: isWide ? 20 : 18,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
        ],
      ),

      // If wide, show inline menu buttons as actions
      // If narrow, do not supply actions (so only the hamburger shows).
      actions: isWide
          ? _navItems
          .map((item) => TextButton(
        onPressed: () => context.go(item.route),
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        child: Text(item.label),
      ))
          .toList()
          : null,
    );
  }
}

/// A Scaffold wrapper that attaches our NavbarWidget as the AppBar
/// and provides a Drawer that automatically works when the screen is narrow.
class NavbarScaffold extends StatelessWidget {
  /// The primary content of the page (below the AppBar)
  final Widget body;

  /// Optional: if you want a footer, simply include it inside the `body`
  /// (e.g. wrap your page content and footer in a Column before passing in).
  const NavbarScaffold({required this.body, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Attach our responsive NavbarWidget here
      appBar: const NavbarWidget(),

      // Provide the Drawer. On narrow screens, NavbarWidget's AppBar
      // will automatically show the hamburger to open this Drawer.
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // You can customize this header as you like
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[800]),
              child: Center(
                child: Text(
                  'FMAS Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:
                    MediaQuery.of(context).size.width >= 600 ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Create a ListTile for each nav item
            ...NavbarWidget._navItems.map((item) {
              return ListTile(
                title: Text(
                  item.label,
                  style: const TextStyle(fontSize: 18),
                ),
                onTap: () {
                  Navigator.of(context).pop(); // Close the drawer
                  context.go(item.route);
                },
              );
            }).toList(),
          ],
        ),
      ),

      body: body,
    );
  }
}

/// Simple class to hold label + route
class _NavItemData {
  final String label;
  final String route;

  const _NavItemData({required this.label, required this.route});
}
