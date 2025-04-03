import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingPage {
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
  });
}

class WelcomeController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  final List<OnboardingPage> onboardingPages = [
    OnboardingPage(
      title: 'Welcome to GreenGrass',
      description:
          'Your go-to platform for discovering and reviewing the best media content.',
      imagePath: 'assets/images/img1.jpg',
      icon: Icons.play_circle_filled,
    ),
    OnboardingPage(
      title: 'Movies & TV Shows',
      description:
          'Explore and review the latest movies and TV shows. Share your thoughts with the community.',
      imagePath: 'assets/images/img2.jpg',
      icon: Icons.movie_outlined,
    ),
    OnboardingPage(
      title: 'Music & Books',
      description:
          'Discover new songs and books. Read reviews from other users and create your own.',
      imagePath: 'assets/images/img3.jpg',
      icon: Icons.headphones,
    ),
    OnboardingPage(
      title: 'Create & Share',
      description:
          'Create your own reviews, rate content, and build your profile as a trusted reviewer.',
      imagePath: 'assets/images/img1.jpg',
      icon: Icons.star_outline,
    ),
  ];

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changePage(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (currentPage.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }
}
