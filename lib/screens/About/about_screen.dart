// lib/screens/about/about_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/navbar_widget.dart';
import '../../widgets/footer_widget.dart';

// Data class representing a feature in the About section
class AboutFeature {
  final IconData icon;
  final String title;
  final String content;

  AboutFeature({
    required this.icon,
    required this.title,
    required this.content,
  });
}

// Data class representing an impact statistic
class AboutImpactStat {
  final String value;
  final String label;

  AboutImpactStat({
    required this.value,
    required this.label,
  });
}

/// The About screen, showcasing hero, features, impact stats, and CTAs
class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    // Hero section strings
    const heroTitle = 'About FMAS';
    const heroSubtitle = 'We empower communities through real-time flood monitoring and rapid response.';
    const heroFeature = 'Innovative, Reliable, Community-Driven';
    const ctaDonate = 'Donate';
    const ctaViewAlerts = 'View Alerts';

    // List of features to display
    final features = <AboutFeature>[
      AboutFeature(
        icon: Icons.public,
        title: 'Global Coverage',
        content: 'Monitoring across multiple regions with satellite integration.',
      ),
      AboutFeature(
        icon: Icons.wifi,
        title: 'Real-Time Alerts',
        content: 'Instant SMS & email alerts to keep everyone informed.',
      ),
      AboutFeature(
        icon: Icons.menu_book,
        title: 'Educational Resources',
        content: 'Guides, videos, and protocols to help communities stay prepared.',
      ),
      AboutFeature(
        icon: Icons.people,
        title: 'Community Engagement',
        content: 'Working alongside local volunteers and county offices.',
      ),
      AboutFeature(
        icon: Icons.location_on,
        title: 'Geospatial Insights',
        content: 'Interactive maps to track flood-prone zones and resources.',
      ),
      AboutFeature(
        icon: Icons.shield,
        title: 'Safety & Preparedness',
        content: 'Ensuring protocols and training are accessible to all.',
      ),
    ];

    // List of impact stats to display
    final impactStats = <AboutImpactStat>[
      AboutImpactStat(value: '12', label: 'Counties Covered'),
      AboutImpactStat(value: '20', label: 'Regional Offices'),
      AboutImpactStat(value: '5K+', label: 'Volunteers'),
      AboutImpactStat(value: '1K+', label: 'Beneficiaries'),
    ];

    // Build the main content as a scrollable column
    return NavbarScaffold(
      body: Column(
        children: [
          // Scrollable area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ===== HERO SECTION =====
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0B3C91), Color(0xFF00C4C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 64, horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Hero title
                        Text(
                          heroTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: width > 800 ? 40 : 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Hero subtitle
                        Text(
                          heroSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: width > 800 ? 20 : 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Hero feature row
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield,
                                color: Colors.cyan[200], size: 28),
                            const SizedBox(width: 8),
                            Text(
                              heroFeature,
                              style: TextStyle(
                                color: Colors.cyan[100],
                                fontSize: width > 800 ? 18 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // CTA buttons
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context.go('/donate'),
                              icon: const Icon(Icons.favorite),
                              label: const Text(ctaDonate),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan[500],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/alerts'),
                              icon: const Icon(Icons.warning_amber_rounded),
                              label: const Text(ctaViewAlerts),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ===== FEATURES GRID =====
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          'Our Key Features',
                          style: TextStyle(
                            fontSize: width > 800 ? 30 : 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 24),
                        GridView.builder(
                          itemCount: features.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: width > 1000
                                ? 3
                                : width > 600
                                ? 2
                                : 1,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                          itemBuilder: (context, index) {
                            final feat = features[index];
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    Icon(feat.icon,
                                        size: 48,
                                        color: Colors.cyan[600]),
                                    const SizedBox(height: 12),
                                    Text(
                                      feat.title,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      feat.content,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ===== IMPACT STATS =====
                  Container(
                    width: double.infinity,
                    color: Colors.blue[50],
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          'Our Impact in Numbers',
                          style: TextStyle(
                            fontSize: width > 800 ? 30 : 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12.0),
                          child: GridView.builder(
                            itemCount: impactStats.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: width > 1000
                                  ? 4
                                  : width > 600
                                  ? 2
                                  : 1,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.2,
                            ),
                            itemBuilder: (context, index) {
                              final stat = impactStats[index];
                              return Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          stat.value,
                                          style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[800]),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          stat.label,
                                          style:
                                          const TextStyle(fontSize: 16, color: Colors.grey),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ===== FINAL CTA =====
                  Container(
                    width: double.infinity,
                    color: const Color(0xFF0C4A6E),
                    padding: const EdgeInsets.symmetric(
                        vertical: 48, horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          'Ready to Make a Difference?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width > 800 ? 30 : 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your support helps us expand our network,',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: width > 800 ? 18 : 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => context.go('/donate'),
                              icon: const Icon(Icons.favorite),
                              label: const Text('Donate Now'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyan[400],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => context.go('/alerts'),
                              icon: const Icon(Icons.warning),
                              label: const Text('View Alerts'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                textStyle: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Pinned footer at the bottom
          const FooterWidget(),
        ],
      ),
    );
  }
}
