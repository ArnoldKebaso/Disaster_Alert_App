// lib/widgets/navbar_widget.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A responsive Navbar that puts the logo on the left (leading),
/// and the hamburger or inline menu on the right (actions).
class NavbarWidget extends StatelessWidget implements PreferredSizeWidget {
  const NavbarWidget({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  static const List<_NavItemData> _navItems = [
    _NavItemData(label: 'Home', route: '/'),
    _NavItemData(label: 'About Us', route: '/about'),
    _NavItemData(label: 'Contact Us', route: '/contact'),
    _NavItemData(label: 'FAQ', route: '/faq'),
    _NavItemData(label: 'Donate', route: '/donate'),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width >= 600;

    return AppBar(
      backgroundColor: Colors.blue[800],
      elevation: 2,

      // Put the logo as the leading widget
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: GestureDetector(
          onTap: () => context.go('/'),
          child: SizedBox(
            height: 32,
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.fitHeight,
              errorBuilder: (ctx, err, st) =>
              const Icon(Icons.home, color: Colors.white),
            ),
          ),
        ),
      ),

      // No default hamburger on the left
      automaticallyImplyLeading: false,

      // Title can be empty (or you could center a Text here if desired)
      title: const SizedBox.shrink(),

      // On the right: either inline menu or a single hamburger icon
      actions: isWide
          ? _navItems.map((item) {
        return TextButton(
          onPressed: () => context.go(item.route),
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: Text(item.label),
        );
      }).toList()
          : [
        Builder(
          builder: (innerCtx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () =>
                Scaffold.of(innerCtx).openDrawer(), // opens the Drawer
          ),
        )
      ],
    );
  }
}

/// A Scaffold that wires in NavbarWidget as the AppBar plus a Drawer.
/// Use this instead of `Scaffold` in your screens.
class NavbarScaffold extends StatelessWidget {
  final Widget body;
  const NavbarScaffold({required this.body, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavbarWidget(),

      // This Drawer will be opened by the hamburger in actions
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[800]),
              child: Center(
                child: Text(
                  'FMAS Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize:
                    MediaQuery.of(context).size.width >= 600 ? 24 : 20,
                  ),
                ),
              ),
            ),
            ...NavbarWidget._navItems.map((item) {
              return ListTile(
                title: Text(item.label),
                onTap: () {
                  Navigator.of(context).pop();
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

class _NavItemData {
  final String label, route;
  const _NavItemData({required this.label, required this.route});
}
