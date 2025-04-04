import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/routes.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());
    final Size size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
                : controller.isLoggedIn.value
                ? _buildLoggedInProfile(context, controller, isSmallScreen)
                : _buildLoginPrompt(context, isSmallScreen),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, bool isSmallScreen) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 50,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'GreenGrass',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Sign in to access your profile',
                style: TextStyle(
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Create and manage your reviews, customize your profile, and more.',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: AppColors.textSecondaryDark,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              // Login button
              ElevatedButton(
                onPressed: () => Get.toNamed(Routes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  minimumSize: Size(isSmallScreen ? 220 : 280, 50),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 16),

              // Register button
              OutlinedButton(
                onPressed: () => Get.toNamed(Routes.register),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size(isSmallScreen ? 220 : 280, 50),
                ),
                child: const Text(
                  'Create an Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedInProfile(
    BuildContext context,
    ProfileController controller,
    bool isSmallScreen,
  ) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: AppColors.surfaceDark,
            pinned: true,
            expandedHeight: 240,
            collapsedHeight: 60,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                color: AppColors.primaryDark,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    _buildUserAvatar(controller),
                    const SizedBox(height: 16),
                    Obx(
                      () => Text(
                        controller.userProfile.value.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        controller.userProfile.value.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(controller),
                  const SizedBox(height: 24),
                  _buildActionButtons(controller, isSmallScreen),
                  const SizedBox(height: 24),
                  _buildSettingsSection(controller, context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(ProfileController controller) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Obx(
          () => Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              image:
                  controller.userProfile.value.profileImage != null &&
                          controller.userProfile.value.profileImage!.isNotEmpty
                      ? DecorationImage(
                        image: NetworkImage(
                          controller.userProfile.value.profileImage!,
                        ),
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                controller.userProfile.value.profileImage == null ||
                        controller.userProfile.value.profileImage!.isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 60)
                    : null,
          ),
        ),

        // Camera button
        GestureDetector(
          onTap: controller.selectProfileImage,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(ProfileController controller) {
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Full name
            _buildInfoRow(
              icon: Icons.person_outline,
              title: 'Full Name',
              value: Obx(
                () => Text(
                  controller.userProfile.value.fullName,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const Divider(height: 24, color: AppColors.dividerDark),

            // Email
            _buildInfoRow(
              icon: Icons.email_outlined,
              title: 'Email',
              value: Obx(
                () => Text(
                  controller.userProfile.value.email,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            const Divider(height: 24, color: AppColors.dividerDark),

            // Phone
            _buildInfoRow(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: Obx(
                () => Text(
                  controller.userProfile.value.mobile.isNotEmpty
                      ? controller.userProfile.value.mobile
                      : 'Not added',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        controller.userProfile.value.mobile.isNotEmpty
                            ? Colors.white
                            : Colors.grey,
                    fontStyle:
                        controller.userProfile.value.mobile.isNotEmpty
                            ? FontStyle.normal
                            : FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required Widget value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 4),
              value,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ProfileController controller, bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.editProfile,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.changePassword,
            icon: const Icon(Icons.lock_outline, size: 18),
            label: const Text('Change Password'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(
    ProfileController controller,
    BuildContext context,
  ) {
    return Card(
      color: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.help_outline,
            title: 'FAQ',
            onTap: controller.openFAQ,
          ),
          const Divider(height: 1, indent: 56, color: AppColors.dividerDark),
          _buildSettingItem(
            icon: Icons.support_agent_outlined,
            title: 'Help & Support',
            onTap: controller.openHelpAndContact,
          ),
          const Divider(height: 1, indent: 56, color: AppColors.dividerDark),
          _buildSettingItem(
            icon: Icons.logout,
            title: 'Logout',
            textColor: Colors.redAccent,
            onTap: controller.logout,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: textColor ?? AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
