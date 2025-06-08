// lib/screens/faq/faq_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';         // ✔︎ Icons for plus/minus
import '../../widgets/navbar_widget.dart';                        // ✔︎ Our responsive navbar
import '../../widgets/footer_widget.dart';                        // ✔︎ The global footer

/// The main FAQ screen widget (stateful because items expand/collapse).
class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  int? _openIndex; // Tracks which FAQ item is currently expanded (or null)

  /// Our list of questions & answers.
  // Sample FAQ items (replace or localize as needed)
  final List<Map<String, String>> _faqItems = [
    {
      'question': 'What is FMAS and how does it work?',
      'answer':
      'FMAS stands for Flood Monitoring and Alert System. We use river‐level sensors, satellite data, and mobile networks to send real‐time warnings to at‐risk communities.',
    },
    {
      'question': 'How can I sign up for flood alerts?',
      'answer':
      'Go to our Home page and scroll to “Stay Updated with Alerts.” Choose your subscription method (email or SMS), enter your contact info, select your locations, and tap “Subscribe.”',
    },
    {
      'question': 'Is there a fee to receive alerts?',
      'answer':
      'No—alerts are entirely free. However, if you choose SMS, standard carrier messaging rates may apply for your mobile provider.',
    },
    {
      'question': 'How does FMAS handle data privacy?',
      'answer':
      'All personal data we collect (email or phone) is stored securely and used only for sending flood-related notifications. We never share your data with third parties without consent.',
    },
    {
      'question': 'Can I volunteer with FMAS?',
      'answer':
      'Yes! Please visit our “Get Involved” section or click “Donate” → “Become a Partner” to learn about volunteer opportunities.',
    },
    {
      'question': 'How does FMAS coordinate with local authorities?',
      'answer':
      'We work closely with county and regional offices to integrate sensor data into existing emergency management workflows, ensuring timely response and resource allocation.',
    },
    {
      'question': 'What should I do if I encounter a false alert?',
      'answer':
      'If you suspect an alert is false or an error, please contact us immediately via the “Contact Us” page or call our support hotline at +254 700 112 233.',
    },
    {
      'question': 'Can I customize alert thresholds?',
      'answer':
      'Currently, alerts are based on standardized river‐level thresholds set in partnership with local meteorological departments. Custom thresholds are coming soon!',
    },
    {
      'question': 'Does FMAS cover areas outside of Kenya?',
      'answer':
      'Right now, FMAS focuses on Kenyan counties. In the future, we plan to expand to neighboring countries in the region.',
    },
    {
      'question': 'How do I update my subscription preferences?',
      'answer':
      'Simply return to the “Stay Updated with Alerts” section on the Home page, re-enter your email/phone, select new locations, and hit “Subscribe” again. It will overwrite your old preferences.',
    },
    {
      'question': 'Where can I find user resources and guides?',
      'answer':
      'Click “Resources” in the navbar or visit the “User Resources” page to access PDF handbooks, videos, and training materials on flood preparedness.',
    },
    {
      'question': 'Whom do I contact for technical issues?',
      'answer':
      'For any technical support, email support@fmas.org or use the “Contact Us” form. We aim to respond within 24 hours on business days.',
    },
  ];

  /// Toggles open/closed state of an FAQ item.
  void _toggleFAQ(int index) {
    setState(() {
      // If you tap the same open index, close it; otherwise open the tapped one.
      _openIndex = (_openIndex == index) ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    // ------------------------------------------------------------
    // STEP 1: Build the FAQ content (header + list) in a Column
    // ------------------------------------------------------------
    final faqContent = Column(
      children: [
        // ===== Header Section =====
        Container(
          width: double.infinity,                            // Full width
          color: Colors.blue[800],                           // Dark-blue background
          padding: const EdgeInsets.symmetric(               // Vertical + horizontal padding
              vertical: 48, horizontal: 24),
          child: Column(
            children: [
              Text(
                'Frequently Asked Questions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,                       // White text
                  fontSize: width > 800 ? 36 : 28,           // Larger on tablet
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Answers to common questions about FMAS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,                    // 70% white
                  fontSize: width > 800 ? 18 : 16,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // ===== FAQ Items List =====
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),  // Disable inner scroll
            shrinkWrap: true,                                // Wrap height to content
            itemCount: _faqItems.length,                     // Number of items
            itemBuilder: (context, index) {
              final faq = _faqItems[index];
              final bool isOpen = (_openIndex == index);

              return Card(
                elevation: 3,                                // Subtle shadow
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // -- Question Header (clickable) --
                    InkWell(
                      onTap: () => _toggleFAQ(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                faq['question']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Icon(
                              // Switch icon based on open state
                              isOpen ? LucideIcons.minus : LucideIcons.plus,
                              size: 24,
                              color: Colors.blue[800],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // -- Expandable Answer Section --
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Text(
                          faq['answer']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                      crossFadeState: isOpen
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 48),
      ],
    );

    // ------------------------------------------------------------
    // STEP 2: Wrap in NavbarScaffold for app bar + drawer support
    // ------------------------------------------------------------
    return NavbarScaffold(
      body: Column(
        children: [
          // a) Make the FAQ content scrollable in its own area:
          Expanded(
            child: SingleChildScrollView(child: faqContent),
          ),

          // b) Pin the footer at the bottom:
          const FooterWidget(),
        ],
      ),
    );
  }
}



// // lib/screens/faq/faq_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:lucide_icons_flutter/lucide_icons.dart'; // ← Correct Lucide import
// import '../../widgets/navbar_widget.dart';
// import '../../widgets/footer_widget.dart';
//
// class FAQScreen extends StatefulWidget {
//   const FAQScreen({Key? key}) : super(key: key);
//
//   @override
//   State<FAQScreen> createState() => _FAQScreenState();
// }
//
// class _FAQScreenState extends State<FAQScreen> {
//   int? _openIndex;
//
//   // Sample FAQ items (replace or localize as needed)
//   final List<Map<String, String>> _faqItems = [
//     {
//       'question': 'What is FMAS and how does it work?',
//       'answer':
//       'FMAS stands for Flood Monitoring and Alert System. We use river‐level sensors, satellite data, and mobile networks to send real‐time warnings to at‐risk communities.',
//     },
//     {
//       'question': 'How can I sign up for flood alerts?',
//       'answer':
//       'Go to our Home page and scroll to “Stay Updated with Alerts.” Choose your subscription method (email or SMS), enter your contact info, select your locations, and tap “Subscribe.”',
//     },
//     {
//       'question': 'Is there a fee to receive alerts?',
//       'answer':
//       'No—alerts are entirely free. However, if you choose SMS, standard carrier messaging rates may apply for your mobile provider.',
//     },
//     {
//       'question': 'How does FMAS handle data privacy?',
//       'answer':
//       'All personal data we collect (email or phone) is stored securely and used only for sending flood-related notifications. We never share your data with third parties without consent.',
//     },
//     {
//       'question': 'Can I volunteer with FMAS?',
//       'answer':
//       'Yes! Please visit our “Get Involved” section or click “Donate” → “Become a Partner” to learn about volunteer opportunities.',
//     },
//     {
//       'question': 'How does FMAS coordinate with local authorities?',
//       'answer':
//       'We work closely with county and regional offices to integrate sensor data into existing emergency management workflows, ensuring timely response and resource allocation.',
//     },
//     {
//       'question': 'What should I do if I encounter a false alert?',
//       'answer':
//       'If you suspect an alert is false or an error, please contact us immediately via the “Contact Us” page or call our support hotline at +254 700 112 233.',
//     },
//     {
//       'question': 'Can I customize alert thresholds?',
//       'answer':
//       'Currently, alerts are based on standardized river‐level thresholds set in partnership with local meteorological departments. Custom thresholds are coming soon!',
//     },
//     {
//       'question': 'Does FMAS cover areas outside of Kenya?',
//       'answer':
//       'Right now, FMAS focuses on Kenyan counties. In the future, we plan to expand to neighboring countries in the region.',
//     },
//     {
//       'question': 'How do I update my subscription preferences?',
//       'answer':
//       'Simply return to the “Stay Updated with Alerts” section on the Home page, re-enter your email/phone, select new locations, and hit “Subscribe” again. It will overwrite your old preferences.',
//     },
//     {
//       'question': 'Where can I find user resources and guides?',
//       'answer':
//       'Click “Resources” in the navbar or visit the “User Resources” page to access PDF handbooks, videos, and training materials on flood preparedness.',
//     },
//     {
//       'question': 'Whom do I contact for technical issues?',
//       'answer':
//       'For any technical support, email support@fmas.org or use the “Contact Us” form. We aim to respond within 24 hours on business days.',
//     },
//   ];
//
//   void _toggleFAQ(int index) {
//     setState(() {
//       _openIndex = (_openIndex == index) ? null : index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double width = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       // ===== NAVBAR =====
//       appBar: const PreferredSize(
//         preferredSize: Size.fromHeight(60),
//         child: NavbarWidget(),
//       ),
//
//       // ===== BODY =====
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // ===== PAGE HEADER =====
//             Container(
//               width: double.infinity,
//               color: Colors.blue[800],
//               padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
//               child: Column(
//                 children: [
//                   Text(
//                     'Frequently Asked Questions',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: width > 800 ? 36 : 28,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Answers to common questions about FMAS',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: width > 800 ? 18 : 16,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),
//
//             // ===== FAQ ITEMS LIST =====
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24.0),
//               child: ListView.builder(
//                 physics: const NeverScrollableScrollPhysics(),
//                 shrinkWrap: true,
//                 itemCount: _faqItems.length,
//                 itemBuilder: (context, index) {
//                   final faq = _faqItems[index];
//                   final bool isOpen = (_openIndex == index);
//                   return Card(
//                     elevation: 3,
//                     margin: const EdgeInsets.only(bottom: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       children: [
//                         // Question header with InkWell
//                         InkWell(
//                           onTap: () => _toggleFAQ(index),
//                           borderRadius: BorderRadius.circular(12),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 16),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     faq['question']!,
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.w600,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                 ),
//                                 Icon(
//                                   isOpen
//                                       ? LucideIcons.minus
//                                       : LucideIcons.plus,
//                                   size: 24,
//                                   color: Colors.blue[800],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         // Answer (expandable)
//                         AnimatedCrossFade(
//                           firstChild: const SizedBox.shrink(),
//                           secondChild: Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             child: Text(
//                               faq['answer']!,
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.black87,
//                                 height: 1.4,
//                               ),
//                             ),
//                           ),
//                           crossFadeState: isOpen
//                               ? CrossFadeState.showSecond
//                               : CrossFadeState.showFirst,
//                           duration: const Duration(milliseconds: 300),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//             const SizedBox(height: 48),
//           ],
//         ),
//       ),
//
//       // ===== FOOTER =====
//       bottomNavigationBar: const FooterWidget(),
//     );
//   }
// }
