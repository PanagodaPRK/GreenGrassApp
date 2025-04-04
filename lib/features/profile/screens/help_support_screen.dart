import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  _HelpSupportScreenState createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Support categories
  final List<Map<String, dynamic>> _supportCategories = [
    {
      'icon': Icons.account_circle_outlined,
      'title': 'Account Issues',
      'description': 'Login, password reset, profile management',
    },
    {
      'icon': Icons.payment_outlined,
      'title': 'Billing & Subscription',
      'description': 'Payment methods, subscription queries',
    },
    {
      'icon': Icons.device_unknown_outlined,
      'title': 'Technical Support',
      'description': 'App performance, device compatibility',
    },
    {
      'icon': Icons.privacy_tip_outlined,
      'title': 'Privacy & Security',
      'description': 'Data protection, account security',
    },
  ];

  // Submission state
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Apply system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  // Validate email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Launch URL safely
  void _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showErrorSnackbar('Could not launch $url');
      }
    } catch (e) {
      _showErrorSnackbar('An error occurred');
    }
  }

  // Show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  // Submit support request
  void _submitSupportRequest() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Simulate network request
        await Future.delayed(const Duration(seconds: 2));

        // Reset form
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();

        // Show success dialog
        _showSuccessDialog();
      } catch (e) {
        _showErrorSnackbar('Failed to submit support request');
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // Success dialog
  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(
          Icons.check_circle_outline_rounded,
          color: Colors.green,
          size: 64,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Message Sent!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We will get back to you within 24-48 hours.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'OK',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Help & Support',
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12.0 : 16.0,
            vertical: isSmallScreen ? 12.0 : 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Support Categories
              _buildSectionHeader(context, 'Support Categories'),
              _buildSupportCategoriesGrid(context),

              // Contact Methods Section
              _buildSectionHeader(context, 'Contact Methods'),
              _buildContactMethodsGrid(context),

              // Support Request Form
              _buildSectionHeader(context, 'Send Us a Message'),
              _buildSupportForm(context),
            ],
          ),
        ),
      ),
    );
  }

  // Section Header Widget
  Widget _buildSectionHeader(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Padding(
      padding: EdgeInsets.only(
        top: isSmallScreen ? 12.0 : 16.0,
        bottom: isSmallScreen ? 8.0 : 12.0,
      ),
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Support Categories Grid
  Widget _buildSupportCategoriesGrid(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: isSmallScreen ? 8.0 : 12.0,
        mainAxisSpacing: isSmallScreen ? 8.0 : 12.0,
      ),
      itemCount: _supportCategories.length,
      itemBuilder: (context, index) {
        final category = _supportCategories[index];
        return GestureDetector(
          onTap: () {
            // TODO: Implement category-specific support flow
            Get.snackbar(
              category['title'],
              category['description'],
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.primary,
              colorText: Colors.white,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  category['title'] as String,
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    category['description'] as String,
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Contact Methods Grid
  Widget _buildContactMethodsGrid(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    final contactMethods = [
      {
        'icon': Icons.email_outlined,
        'title': 'Email Support',
        'subtitle': 'support@greengrass.com',
        'onTap': () => _launchURL('mailto:support@greengrass.com'),
      },
      {
        'icon': Icons.phone_outlined,
        'title': 'Phone Support',
        'subtitle': '+1 (555) 123-4567',
        'onTap': () => _launchURL('tel:+15551234567'),
      },
      {
        'icon': Icons.chat_outlined,
        'title': 'Live Chat',
        'subtitle': 'Chat with our team',
        'onTap': () {
          // TODO: Implement live chat functionality
          Get.snackbar(
            'Coming Soon',
            'Live chat feature will be available soon',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primary,
            colorText: Colors.white,
          );
        },
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': 'FAQ',
        'subtitle': 'Frequently Asked Questions',
        'onTap': () => Get.toNamed('/faq'),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: isSmallScreen ? 8.0 : 12.0,
        mainAxisSpacing: isSmallScreen ? 8.0 : 12.0,
      ),
      itemCount: contactMethods.length,
      itemBuilder: (context, index) {
        final method = contactMethods[index];
        return GestureDetector(
          onTap: method['onTap'] as void Function(),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    method['icon'] as IconData,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  method['title'] as String,
                  style: textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  method['subtitle'] as String,
                  style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Support Request Form
  Widget _buildSupportForm(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name Input
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Your Name',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: AppColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              prefixIcon: Icon(
                Icons.person_outline,
                color: Colors.grey.shade400,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          SizedBox(height: isSmallScreen ? 12.0 : 16.0),

          // Email Input
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Your Email',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: AppColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: Colors.grey.shade400,
              ),
            ),
            validator: _validateEmail,
          ),
          SizedBox(height: isSmallScreen ? 12.0 : 16.0),

          // Support Category Dropdown
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: DropdownButtonFormField<String>(
              dropdownColor: AppColors.surfaceDark,
              decoration: InputDecoration(
                hintText: 'Select Support Category',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                prefixIcon: Icon(
                  Icons.category_outlined,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              items:
                  _supportCategories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['title'],
                      child: Text(category['title']),
                    );
                  }).toList(),
              onChanged: (value) {
                // Handle category selection
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a support category';
                }
                return null;
              },
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 12.0 : 16.0),

          // Message Input
          TextFormField(
            controller: _messageController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Describe your issue in detail',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: AppColors.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              prefixIcon: Icon(
                Icons.message_outlined,
                color: Colors.grey.shade400,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please describe your issue';
              }
              return null;
            },
          ),
          SizedBox(height: isSmallScreen ? 16.0 : 24.0),

          // Submit Button
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitSupportRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                _isSubmitting
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : Text(
                      'Send Message',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
          SizedBox(height: isSmallScreen ? 16.0 : 24.0),

          // Additional Support Information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We typically respond within 24-48 hours. For urgent matters, please contact our phone support.',
                    style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
