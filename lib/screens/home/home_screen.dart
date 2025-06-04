// lib/screens/home/home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../widgets/navbar_widget.dart';
import '../../widgets/footer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ===== HERO CAROUSEL STATE =====
  final PageController _pageController = PageController();
  late Timer _carouselTimer;
  int _currentPage = 0;

  // → Replace these with your actual “Budalangi” hero images
  final List<String> _heroImages = [
    'assets/images/Budalangi1.jpeg',
    'assets/images/Budalangi3.jpg',
    'assets/images/Budalangi8.jpeg',
    'assets/images/Budalangi9.jpeg',
    'assets/images/Budalangi6.jpeg',
  ];

  // ===== SUBSCRIPTION FORM STATE =====
  String _subscriptionMethod = '';
  String _contactValue = '';
  List<String> _selectedLocations = [];
  bool _isSubmittingSubscription = false;
  String _subscriptionStatus = '';

  final List<MultiSelectItem<String>> _locationOptions = [
    MultiSelectItem('Bumadeya', 'Bumadeya'),
    MultiSelectItem('Budalangi Central', 'Budalangi Central'),
    MultiSelectItem('Budubusi', 'Budubusi'),
    MultiSelectItem('Mundere', 'Mundere'),
    MultiSelectItem('Musoma', 'Musoma'),
    MultiSelectItem('Sibuka', 'Sibuka'),
    MultiSelectItem('Sio Port', 'Sio Port'),
    MultiSelectItem('Rukala', 'Rukala'),
    MultiSelectItem('Mukhweya', 'Mukhweya'),
    MultiSelectItem('Sigulu Island', 'Sigulu Island'),
    MultiSelectItem('Siyaya', 'Siyaya'),
    MultiSelectItem('Nambuku', 'Nambuku'),
    MultiSelectItem('West Bunyala', 'West Bunyala'),
    MultiSelectItem('East Bunyala', 'East Bunyala'),
    MultiSelectItem('South Bunyala', 'South Bunyala'),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll every 5 seconds
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _heroImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _carouselTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubscriptionSubmit() async {
    setState(() {
      _isSubmittingSubscription = true;
      _subscriptionStatus = '';
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isSubmittingSubscription = false;
      _subscriptionStatus = 'Subscription successful!';
      _subscriptionMethod = '';
      _contactValue = '';
      _selectedLocations = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      // ===== NAVBAR =====
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: NavbarWidget(),
      ),

      // ===== BODY =====
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== HERO SECTION =====
            Stack(
              children: [
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _heroImages.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(0),
                        child: Image.asset(
                          _heroImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Text('Image not found'),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                  ),
                ),
                Container(
                  height: 400,
                  color: Colors.black.withOpacity(0.5),
                ),
                SizedBox(
                  height: 400,
                  width: double.infinity,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Empowering Communities\nThrough Real-Time Flood Monitoring',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width > 800 ? 42 : 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Stay informed with instant alerts,\nresource allocation, and rapid response.',
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
                                onPressed: () {
                                  context.go('/donate');
                                },
                                icon: const Icon(Icons.favorite),
                                label: const Text('Donate Now'),
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
                                onPressed: () {
                                  context.go('/alerts');
                                },
                                icon: const Icon(Icons.warning_amber_rounded),
                                label: const Text('View Alerts'),
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
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ===== “WHAT WE DO” SECTION =====
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'What We Do',
                    style: TextStyle(
                      fontSize: width > 800 ? 30 : 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: width > 1000
                        ? 4
                        : width > 600
                        ? 2
                        : 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildWhatWeDoCard(
                        title: 'Flood Monitoring',
                        imagePath: 'assets/images/floodMonitoring.png',
                        description:
                        '24/7 river-level sensors and satellite integration.',
                      ),
                      _buildWhatWeDoCard(
                        title: 'Flood Alerts',
                        imagePath: 'assets/images/alert.png',
                        description:
                        'Instant SMS & email alerts to at-risk households.',
                      ),
                      _buildWhatWeDoCard(
                        title: 'Resource Allocation',
                        imagePath: 'assets/images/resourceAllocation.png',
                        description:
                        'Dynamic distribution of relief kits and personnel.',
                      ),
                      _buildWhatWeDoCard(
                        title: 'Rapid Response',
                        imagePath: 'assets/images/floodResponse.png',
                        description:
                        'Coordinate first-responder teams within 30 minutes.',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ===== DONATE SECTION =====
            Container(
              width: double.infinity,
              color: const Color(0xFF0C4A6E),
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Support Our Mission',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width > 800 ? 30 : 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your donations help us maintain 24/7 monitoring systems\nand deploy emergency teams within 30 minutes of an alert.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width > 800 ? 18 : 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/donate');
                    },
                    child: const Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      child: Text(
                        'Contribute Now',
                        style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[500],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ===== SUBSCRIBE SECTION =====
            Container(
              width: double.infinity,
              color: Colors.blue[50],
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stay Updated with Alerts',
                    style: TextStyle(
                      fontSize: width > 800 ? 26 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // White card with stronger border and shadow
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade800, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // Subscription Method Label
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Subscription Method',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Dropdown – stronger outline color
                        DropdownButtonFormField<String>(
                          value: _subscriptionMethod.isEmpty
                              ? null
                              : _subscriptionMethod,
                          items: const [
                            DropdownMenuItem(
                              value: 'email',
                              child: Text('Email'),
                            ),
                            DropdownMenuItem(
                              value: 'sms',
                              child: Text('SMS'),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _subscriptionMethod = val ?? '';
                              _contactValue = '';
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue.shade800, width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue.shade900, width: 1.6),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Contact label changes based on selection
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _subscriptionMethod == 'sms'
                                ? 'Phone Number (+2547xxxxxxx)'
                                : 'Email Address',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Contact TextField – stronger outline color
                        TextFormField(
                          initialValue: _contactValue,
                          onChanged: (val) {
                            setState(() {
                              _contactValue = val;
                            });
                          },
                          keyboardType: _subscriptionMethod == 'sms'
                              ? TextInputType.phone
                              : TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: _subscriptionMethod == 'sms'
                                ? '+2547XXXXXXXX'
                                : 'you@example.com',
                            contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue.shade800, width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.blue.shade900, width: 1.6),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Select Locations',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Multi-select with outlined border
                        MultiSelectDialogField(
                          items: _locationOptions,
                          initialValue: _selectedLocations,
                          listType: MultiSelectListType.CHIP,
                          buttonText: const Text('Choose locations'),
                          title: const Text('Locations'),
                          searchable: false,
                          onConfirm: (values) {
                            setState(() {
                              _selectedLocations =
                                  values.map((e) => e as String).toList();
                            });
                          },
                          chipDisplay: MultiSelectChipDisplay(
                            onTap: (value) {
                              setState(() {
                                _selectedLocations.remove(value);
                              });
                            },
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue.shade800, width: 1.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // “Subscribe” button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_subscriptionMethod.isEmpty ||
                                _contactValue.isEmpty ||
                                _selectedLocations.isEmpty)
                                ? null
                                : () {
                              _handleSubscriptionSubmit();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 8),
                              child: _isSubmittingSubscription
                                  ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Subscribe',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        if (_subscriptionStatus.isNotEmpty)
                          Text(
                            _subscriptionStatus,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ===== REPORT NOW SECTION =====
            Stack(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/Budalangi3.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 300,
                  color: Colors.black.withOpacity(0.6),
                ),
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Report a Flood Now',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width > 800 ? 30 : 26,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Help us provide real-time data by reporting a flood in your area.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width > 800 ? 18 : 16,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.go('/report');
                            },
                            icon: const Icon(Icons.warning),
                            label: const Text('Report Now'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ===== PUBLICATIONS & VIDEOS SECTION =====
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Publications & Tutorials',
                    style: TextStyle(
                      fontSize: width > 800 ? 26 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: width > 1000
                        ? 3
                        : width > 600
                        ? 2
                        : 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildPublicationCard(
                        imagePath: 'assets/images/Budalangi6.jpeg',
                        title: 'Emergency Plan Handbook',
                        description:
                        'Download our comprehensive emergency planning guide (PDF).',
                        buttonText: 'Download PDF',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content:
                              const Text('Open EmergencyPlan.pdf'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      _buildPublicationCard(
                        imagePath: 'assets/images/Budalangi9.jpeg',
                        title: 'Flood Response Tutorial',
                        description:
                        'Watch our step-by-step flood reporting tutorial.',
                        buttonText: 'Watch Video',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content:
                              const Text('Open YouTube Tutorial'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      _buildPublicationCard(
                        imagePath: 'assets/images/Budalangi8.jpeg',
                        title: 'Emergency Protocols PDF',
                        description:
                        'Access Kenya El-Nino floods emergency appeal (online).',
                        buttonText: 'View Online',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content:
                              const Text('Open external ReliefWeb link'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/userResources');
                    },
                    child: const Padding(
                      padding:
                      EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text(
                        'View More Resources',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[500],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ===== SHORT FAQ SECTION =====
            Container(
              width: double.infinity,
              color: Colors.blue[50],
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: width > 800 ? 26 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildFAQTile(
                        question: 'How do I register for alerts?',
                        answer:
                        'Go to the Register page, fill in your details, and select your locations. You will receive a confirmation email or SMS.',
                      ),
                      _buildFAQTile(
                        question: 'Can I donate via mobile money?',
                        answer:
                        'Yes—simply click “Donate Now” and follow the M-Pesa or credit card instructions on our donation page.',
                      ),
                      _buildFAQTile(
                        question: 'How do I report a flood?',
                        answer:
                        'Click the “Report Now” button on the homepage. Fill out the form with location details and any photos if available.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      context.go('/faq');
                    },
                    child: const Text(
                      'View All FAQs',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ===== OUR IMPACT SECTION =====
            Container(
              width: double.infinity,
              color: const Color(0xFF0C4A6E),
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Our Impact',
                    style: TextStyle(
                      fontSize: width > 800 ? 26 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add side padding so the cards don’t touch screen edges
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: GridView.count(
                      crossAxisCount: width > 1000
                          ? 4
                          : width > 600
                          ? 2
                          : 1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        // County Branches
                        _buildImpactCard(
                          imagePath: 'assets/images/regional.png', // replace if you have a “county” icon
                          label: 'County Branches',
                          value: '12',
                        ),

                        // Regional Offices
                        _buildImpactCard(
                          imagePath: 'assets/images/regional.png',
                          label: 'Regional Offices',
                          value: '20',
                        ),

                        // Volunteers
                        _buildImpactCard(
                          imagePath: 'assets/images/volunteer.png',
                          label: 'Volunteers',
                          value: '5K+',
                        ),

                        // Beneficiaries
                        _buildImpactCard(
                          imagePath: 'assets/images/beneficiary.png',
                          label: 'Beneficiaries',
                          value: '1K+',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ===== CONTACT US SNIPPET =====
            Container(
              width: double.infinity,
              color: Colors.blue[50],
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Get in Touch',
                    style: TextStyle(
                      fontSize: width > 800 ? 26 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Need help or have questions? We’re here for you 24/7. Contact us for support or collaboration.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: width > 800 ? 18 : 16,
                      color: Colors.blueGrey[700],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go('/contact');
                    },
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Contact Us'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan[500],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),

      // ===== FOOTER =====
      bottomNavigationBar: const FooterWidget(),
    );
  }

  // ==================== WIDGET HELPERS ====================

  Widget _buildWhatWeDoCard({
    required String title,
    required String imagePath,
    required String description,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                height: 80,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 80,
                    color: Colors.grey[200],
                    child: const Center(child: Text('Image not found')),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicationCard({
    required String imagePath,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imagePath,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 140,
                  color: Colors.grey[200],
                  child: const Center(child: Text('Image not found')),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTile({
    required String question,
    required String answer,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              answer,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildImpactCard({
    required String imagePath,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.asset(
              imagePath,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  color: Colors.grey[200],
                  child: const Center(child: Text('Image not found')),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
