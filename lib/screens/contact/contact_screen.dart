// lib/screens/contact/contact_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/navbar_widget.dart';
import '../../widgets/footer_widget.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _message = '';
  bool _isSubmitting = false;
  String _submitStatus = '';

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
      _submitStatus = '';
    });

    // Simulate sending the message (replace with real API call if needed)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
      _submitStatus = 'Thank you, your message has been sent!';
      _formKey.currentState!.reset();
      _name = '';
      _email = '';
      _message = '';
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
            // Hero Header
            Container(
              width: double.infinity,
              color: Colors.blue[800],
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Contact Us',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: width > 800 ? 36 : 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Have questions or feedback? We’d love to hear from you.',
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

            // Contact Form Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
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
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name Field
                      Text(
                        'Your Name',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _name,
                        onSaved: (val) => _name = val?.trim() ?? '',
                        validator: (val) =>
                        (val == null || val.trim().isEmpty)
                            ? 'Please enter your name'
                            : null,
                        decoration: InputDecoration(
                          hintText: 'John Doe',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                            BorderSide(color: Colors.blue.shade800, width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                            BorderSide(color: Colors.blue.shade900, width: 1.6),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email Field
                      Text(
                        'Email Address',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _email,
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (val) => _email = val?.trim() ?? '',
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          // Simple email pattern check
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(val.trim())) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'you@example.com',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                            BorderSide(color: Colors.blue.shade800, width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                            BorderSide(color: Colors.blue.shade900, width: 1.6),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Message Field
                      Text(
                        'Your Message',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue[900],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: _message,
                        maxLines: 5,
                        onSaved: (val) => _message = val?.trim() ?? '',
                        validator: (val) =>
                        (val == null || val.trim().isEmpty)
                            ? 'Please enter a message'
                            : null,
                        decoration: InputDecoration(
                          hintText: 'Write your message here...',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                            BorderSide(color: Colors.blue.shade800, width: 1.2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                            BorderSide(color: Colors.blue.shade900, width: 1.6),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _handleSubmit,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 8),
                            child: _isSubmitting
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text(
                              'Send Message',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
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

                      // Submission status (success message)
                      if (_submitStatus.isNotEmpty)
                        Text(
                          _submitStatus,
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ),
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
