// lib/widgets/navbar_widget.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({Key? key}) : super(key: key);

  // The list of menu entries to display
  static const List<_NavItemData> _navItems = [
    _NavItemData(label: 'Home', route: '/'),
    _NavItemData(label: 'About Us', route: '/about'),
    _NavItemData(label: 'Contact Us', route: '/contact'),
    _NavItemData(label: 'FAQ', route: '/faq'),
    _NavItemData(label: 'Donate', route: '/donate'),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If width is >= 600, show inline menu; otherwise show hamburger.
        final bool isWide = constraints.maxWidth >= 600;

        return Container(
          color: Colors.blue[800],
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // ===== LOGO =====
                  // You can remove this Container entirely if the logo is causing issues.
                  // Just comment out or delete the entire SizedBox(...) block below.
                  SizedBox(
                    height: 32,
                    child: GestureDetector(
                      onTap: () => context.go('/'),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.fitHeight,
                        errorBuilder: (context, error, stackTrace) {
                          // If the logo fails to load, simply show a placeholder icon
                          return const Icon(Icons.home, color: Colors.white, size: 32);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // ===== TITLE (OPTIONAL) =====
                  // You could also put a Text( 'FMAS', style: ... ) next to the logo here.
                  // For now, we omit extra text to keep things compact.

                  // Spacer pushes menu items or hamburger to the right
                  const Spacer(),

                  if (isWide)
                  // ===== INLINE MENU ITEMS =====
                    Row(
                      children: _navItems.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: TextButton(
                            onPressed: () => context.go(item.route),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: Text(item.label),
                          ),
                        );
                      }).toList(),
                    )
                  else
                  // ===== HAMBURGER ICON =====
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Required to wrap your Scaffold around a Drawer when using the above Navbar.
/// See instructions below.
class NavbarScaffold extends StatelessWidget {
  /// The main body of the page
  final Widget body;

  const NavbarScaffold({required this.body, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Attach our responsive AppBar from above
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: NavbarWidget(),
      ),
      // Define the Drawer that opens on small screens
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Optional: Drawer header
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[800]),
              child: Center(
                child: Text(
                  'FMAS Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width >= 600 ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Drawer items (same as navbar links)
            ...NavbarWidget._navItems.map((item) {
              return ListTile(
                title: Text(item.label,
                    style: const TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.of(context).pop(); // close the drawer
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

/// Simple data class for navbar items
class _NavItemData {
  final String label;
  final String route;

  const _NavItemData({required this.label, required this.route});
}
