// lib/screens/user_resources/resources_screen.dart

import 'package:flutter/material.dart';
//import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../widgets/navbar_widget.dart';
import '../../widgets/footer_widget.dart';

/// Represents a single resource item (PDF guide or external video/tool).
class ResourceItem {
  final String title;
  final String subtitle;      // e.g. “Beginner” or “Advanced”
  final IconData leadingIcon; // e.g. PDF icon or video icon
  final String url;           // asset path (pdf) or external URL
  final bool isAsset;         // true ⇒ open local asset, false ⇒ launch external

  ResourceItem({
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.url,
    this.isAsset = true,
  });
}

/// Top-level category of resources.
class ResourceCategory {
  final String name;
  final IconData icon;
  final List<ResourceItem> items;

  ResourceCategory({
    required this.name,
    required this.icon,
    required this.items,
  });
}

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({Key? key}) : super(key: key);

  @override
  _ResourcesScreenState createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  late YoutubePlayerController _ytController;

  @override
  void initState() {
    super.initState();
    // Initialize YouTube player
    _ytController = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(
        'https://www.youtube.com/watch?v=abcdefg1234',
      )!,
      flags: const YoutubePlayerFlags(autoPlay: false),
    );
  }

  @override
  void dispose() {
    _ytController.dispose();
    super.dispose();
  }

  /// Helper to open PDF asset in your device's default PDF viewer.
  Future<void> _openPdfAsset(String assetPath) async {
    // For a production app you'd copy the asset to a temp file first.
    // Here we just launch the asset directly (works if the OS supports it).
    await launchUrl(Uri.parse(assetPath));
  }

  /// Helper to launch any URL (http or mailto etc).
  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // --- Build your data from the React spec ---
    final categories = <ResourceCategory>[
      ResourceCategory(
        name: 'Guides',
        icon: Icons.menu_book,
        items: [
          ResourceItem(
            title: 'Flood Preparedness Handbook',
            subtitle: 'PDF · Beginner',
            leadingIcon: Icons.picture_as_pdf,
            url: 'assets/pdfs/EmergencyPlan.pdf',
            isAsset: true,
          ),
          ResourceItem(
            title: 'Emergency Plan Handbook',
            subtitle: 'PDF · Beginner',
            leadingIcon: Icons.picture_as_pdf,
            url: 'assets/pdfs/DisasterRiskReduction.pdf',
            isAsset: true,
          ),
          ResourceItem(
            title: 'Subscription Reports',
            subtitle: 'PDF · Beginner',
            leadingIcon: Icons.picture_as_pdf,
            url: 'assets/pdfs/subscriptionReport.pdf',
            isAsset: true,
          ),
          ResourceItem(
            title: 'El Niño Emergency Protocols',
            subtitle: 'Article · Advanced',
            leadingIcon: Icons.article,
            url: 'https://example.com/articles/el-nino-protocols',
            isAsset: false,
          ),
        ],
      ),
      ResourceCategory(
        name: 'Multimedia',
        icon: Icons.video_library,
        items: [
          ResourceItem(
            title: 'Flood Reporting Tutorial',
            subtitle: 'Video',
            leadingIcon: Icons.play_circle_fill,
            url: 'https://youtu.be/abcdefg1234',
            isAsset: false,
          ),
          ResourceItem(
            title: 'El Niño Preparedness News',
            subtitle: 'Video',
            leadingIcon: Icons.play_circle_fill,
            url: 'https://youtu.be/hijklmn5678',
            isAsset: false,
          ),
          ResourceItem(
            title: 'Flood Response in Budalangi',
            subtitle: 'Video',
            leadingIcon: Icons.play_circle_fill,
            url: 'https://youtu.be/opqrstu9012',
            isAsset: false,
          ),
          ResourceItem(
            title: 'Kenya’s Rapid-Flood Report',
            subtitle: 'Video',
            leadingIcon: Icons.play_circle_fill,
            url: 'https://youtu.be/vwxyz34567',
            isAsset: false,
          ),
        ],
      ),
      ResourceCategory(
        name: 'Tools',
        icon: Icons.build_circle,
        items: [
          ResourceItem(
            title: 'Flood Risk Assessment Tool',
            subtitle: 'Web App',
            leadingIcon: Icons.open_in_new,
            url: 'https://fmas.example.com/risk-tool',
            isAsset: false,
          ),
          ResourceItem(
            title: 'Evacuation Route Planner',
            subtitle: 'Interactive Map',
            leadingIcon: Icons.map,
            url: 'https://fmas.example.com/evacuation-planner',
            isAsset: false,
          ),
        ],
      ),
    ];

    // --- Compose the three-column grid of cards ---
    final grid = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width > 1000 ? 3 : width > 600 ? 2 : 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (_, catIndex) {
        final cat = categories[catIndex];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category header
                Row(
                  children: [
                    Icon(cat.icon, color: Colors.blue[800]),
                    const SizedBox(width: 8),
                    Text(cat.name,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                // List each item
                Expanded(
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cat.items.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final item = cat.items[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(item.leadingIcon,
                            color: Colors.blue[600]),
                        title: Text(item.title),
                        subtitle: Text(item.subtitle,
                            style: const TextStyle(fontSize: 12)),
                        trailing: Icon(
                          item.isAsset
                              ? Icons.download_rounded
                              : Icons.open_in_new,
                          color: Colors.blue[800],
                        ),
                        onTap: () {
                          if (item.isAsset) {
                            _openPdfAsset(item.url);
                          } else {
                            _launchExternal(item.url);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // --- Interactive Learning Hub card ---
    final learningHub = Card(
      elevation: 3,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Interactive Learning Hub',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // YouTube video player
            YoutubePlayer(
              controller: _ytController,
              showVideoProgressIndicator: true,
            ),
            const SizedBox(height: 16),
            // Essential Reading
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Essential Reading',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('• Flood First Aid Guide'),
                  Text('• Adult First Aid/CPR/AED Course'),
                  Text('• Evacuation Planning'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Interactive Tools tags
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text('Risk Assessment')),
                Chip(label: Text('Flood Simulator')),
                Chip(label: Text('Preparation Quiz')),
              ],
            ),
          ],
        ),
      ),
    );

    // --- Stay Prepared subscription banner ---
    final subscriptionSection = Container(
      width: double.infinity,
      color: Colors.blue[800],
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: Column(
        children: [
          const Text('Stay Prepared',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            'Get monthly updates with new resources and flood safety tips',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          // Email input + button
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  // wire up subscription
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan[500],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                ),
                child: const Text('Subscribe'),
              ),
            ],
          ),
        ],
      ),
    );

    // --- FULL PAGE CONTENT as one scrollable column ---
    final pageContent = Column(
      children: [
        // Hero header
        Container(
          width: double.infinity,
          color: Colors.blue[800],
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          child: Column(
            children: [
              const Text('User Resources',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Access guides, videos, tools, and interactive learning to help you use FMAS effectively.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Three-column grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: grid,
        ),

        const SizedBox(height: 24),

        // Interactive Learning Hub
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: learningHub,
        ),

        const SizedBox(height: 24),

        // Subscription footer
        subscriptionSection,

        const SizedBox(height: 24),
      ],
    );

    // --- Wrap in NavbarScaffold + pinned FooterWidget ---
    return NavbarScaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(child: pageContent),
          ),
          const FooterWidget(),
        ],
      ),
    );
  }
}
