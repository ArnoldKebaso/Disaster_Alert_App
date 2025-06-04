// lib/screens/donate/donate_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // ← New package
import '../../widgets/navbar_widget.dart';
import '../../widgets/footer_widget.dart';

class DonateScreen extends StatelessWidget {
  const DonateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    // Helper to build each donation option card
    Widget _buildOptionCard({
      required IconData iconData,
      required String title,
      required String description,
      required VoidCallback onPressed,
    }) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(iconData, size: 36, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Learn More'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      // ===== NAVBAR =====
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: NavbarWidget(),
      ),

      // ===== BODY =====
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== HEADER =====
            Container(
              width: double.infinity,
              color: Colors.blue[800],
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Empower Disaster Response',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width > 800 ? 36 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your generosity fuels our mission to provide immediate relief and build resilient communities.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: width > 800 ? 18 : 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ===== DONATION OPTIONS GRID =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GridView.count(
                crossAxisCount: width > 1000
                    ? 3
                    : width > 600
                    ? 2
                    : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // 1) Monetary Donations
                  _buildOptionCard(
                    iconData: FontAwesomeIcons.donate,
                    title: 'Monetary Donations',
                    description:
                    'Give a one-time or recurring financial gift to support sensor maintenance, staff salaries, and rapid response operations.',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Redirecting to Monetary Donation gateway…'),
                        ),
                      );
                    },
                  ),

                  // 2) Supplies & Relief Kits
                  _buildOptionCard(
                    iconData: FontAwesomeIcons.boxesPacking,
                    title: 'Supplies & Relief Kits',
                    description:
                    'Contribute essential goods—food, water, blankets, first-aid kits—for immediate distribution to affected families.',
                    onPressed: () {
                      context.go('/contact');
                    },
                  ),

                  // 3) Volunteer Sign-ups
                  _buildOptionCard(
                    iconData: FontAwesomeIcons.handsHelping,
                    title: 'Volunteer Sign-ups',
                    description:
                    'Join our network of 5,000+ volunteers. Provide on-ground support during flood emergencies and help communities recover.',
                    onPressed: () {
                      context.go('/contact');
                    },
                  ),

                  // 4) Corporate Partnerships
                  _buildOptionCard(
                    iconData: FontAwesomeIcons.handshake,
                    title: 'Corporate Partnerships',
                    description:
                    'Partner with FMAS at the organizational level—sponsor equipment, underwriting, and community outreach programs.',
                    onPressed: () {
                      context.go('/contact');
                    },
                  ),

                  // 5) In-Kind Services (Tech, Logistics)
                  _buildOptionCard(
                    iconData: FontAwesomeIcons.tools,
                    title: 'In-Kind Services',
                    description:
                    'Offer professional services (e.g., GIS mapping, software development, logistics) to strengthen our platform.',
                    onPressed: () {
                      context.go('/contact');
                    },
                  ),

                  // 6) Become a Partner
                  _buildOptionCard(
                    iconData: FontAwesomeIcons.gift,
                    title: 'Become a Partner',
                    description:
                    'Collaborate long-term with FMAS. Visit our partnerships team to co-develop localized disaster response solutions.',
                    onPressed: () {
                      context.go('/contact');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ===== IMPACT STATEMENT =====
            Container(
              width: double.infinity,
              color: const Color(0xFF0C4A6E),
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                children: [
                  Icon(
                    FontAwesomeIcons.gift,
                    size: 48,
                    color: Colors.cyan[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Impact Matters',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.cyan[100],
                      fontSize: width > 800 ? 28 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Every contribution helps us maintain 24/7 monitoring systems '
                        'and deploy emergency teams within 30 minutes of disaster alerts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.cyan[200],
                      fontSize: width > 800 ? 18 : 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Key Stats Row
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 16,
                    children: const [
                      _StatBox(label: '5,000+ Lives Saved'),
                      _StatBox(label: '200+ Communities'),
                      _StatBox(label: '85% Efficiency'),
                      _StatBox(label: '24/7 Support'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),

      // ===== FOOTER =====
      bottomNavigationBar: const FooterWidget(),
    );
  }
}

// A small widget to display a “stat” box in the Impact section
class _StatBox extends StatelessWidget {
  final String label;
  const _StatBox({required this.label, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.cyan,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
