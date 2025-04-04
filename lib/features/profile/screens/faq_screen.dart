import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  // List of FAQs
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I create an account?',
      'answer':
          'You can create an account by tapping the "Sign Up" button on the login screen and providing the required information. You can sign up using your email or through social media accounts.',
    },
    {
      'question': 'Can I change my profile information?',
      'answer':
          'Yes, you can edit your profile information by going to the Profile Settings. Tap on your profile icon and select "Edit Profile" to update your details.',
    },
    {
      'question': 'How do I write a review?',
      'answer':
          'To write a review, navigate to the details page of a media item and tap the "Write Review" button. Rate the item and share your thoughts.',
    },
    {
      'question': 'Is my personal information secure?',
      'answer':
          'We take data privacy seriously. Your personal information is encrypted and protected. We do not share your data with third parties without your consent.',
    },
    {
      'question': 'How can I reset my password?',
      'answer':
          'On the login screen, tap "Forgot Password". Enter your registered email, and you will receive a password reset link.',
    },
    {
      'question': 'Can I download media for offline viewing?',
      'answer':
          'Currently, offline downloads are not supported. You can stream media online through the app.',
    },
  ];

  @override
  void initState() {
    super.initState();

    // Apply system UI overlay style for a more immersive experience
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
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
          'Frequently Asked Questions',
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12.0 : 16.0,
          vertical: isSmallScreen ? 12.0 : 16.0,
        ),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          return _buildFAQItem(context, _faqs[index]);
        },
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, Map<String, String> faq) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12.0 : 16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
      ),
      child: ExpansionTile(
        title: Text(
          faq['question'] ?? '',
          style: textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: Colors.white70,
        children: [
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Text(
              faq['answer'] ?? '',
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
