import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../../core/navigation/routes.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/models/user_profile.dart';

class CloudinaryConfig {
  final String cloudName;
  final String apiKey;
  final String apiSecret;

  CloudinaryConfig({
    required this.cloudName,
    required this.apiKey,
    required this.apiSecret,
  });

  // Parse Cloudinary URL
  factory CloudinaryConfig.fromUrl(String cloudinaryUrl) {
    try {
      if (!cloudinaryUrl.startsWith('cloudinary://')) {
        throw FormatException('Invalid Cloudinary URL format');
      }

      final withoutProtocol = cloudinaryUrl.replaceFirst('cloudinary://', '');
      final parts = withoutProtocol.split('@');

      if (parts.length != 2) {
        throw FormatException('Invalid Cloudinary URL parts');
      }

      final keySecret = parts[0].split(':');
      final cloudName = parts[1];

      if (keySecret.length != 2 || cloudName.isEmpty) {
        throw FormatException('Invalid Cloudinary URL credentials');
      }

      return CloudinaryConfig(
        cloudName: cloudName,
        apiKey: keySecret[0],
        apiSecret: keySecret[1],
      );
    } catch (e) {
      print('Error parsing Cloudinary URL: $e');
      throw FormatException('Cannot parse Cloudinary URL');
    }
  }
}

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Cloudinary Configuration
  late CloudinaryConfig _cloudinaryConfig;

  final RxBool isLoading = false.obs;
  final RxBool isLoggedIn = false.obs;
  final Rx<UserProfile> userProfile =
      UserProfile(
        id: '',
        fullName: '',
        email: '',
        mobile: '',
        profileImage: null,
      ).obs;

  @override
  void onInit() {
    super.onInit();
    _initializeCloudinaryConfig();
    loadUserProfile();
  }

  void _initializeCloudinaryConfig() {
    try {
      // Direct configuration - REPLACE WITH YOUR ACTUAL CREDENTIALS
      _cloudinaryConfig = CloudinaryConfig(
        cloudName: 'ds4kcxwe6',
        apiKey: '145352627495393',
        apiSecret: 'fC4GQ9PTGlrn-ZGvUGh4yp8F5Y4',
      );
    } catch (e) {
      _showErrorSnackbar('Cloudinary configuration failed: ${e.toString()}');
    }
  }

  Future<void> loadUserProfile() async {
    try {
      isLoading.value = true;
      isLoggedIn.value = _authService.isLoggedIn;

      if (isLoggedIn.value) {
        final profile = await _authService.getCurrentUserProfile();
        if (profile != null) {
          userProfile.value = profile;
        }
      }
    } catch (e) {
      _showErrorSnackbar('Failed to load profile: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> editProfile() async {
    final TextEditingController nameController = TextEditingController(
      text: userProfile.value.fullName,
    );

    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Color(0xFFD1D5DB)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF374151)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF16A34A)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFD1D5DB)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      try {
        isLoading.value = true;
        await _authService.updateUserProfile(
          userId: userProfile.value.id,
          fullName: nameController.text,
        );
        await loadUserProfile();
        _showSuccessSnackbar('Profile updated successfully');
      } catch (e) {
        _showErrorSnackbar('Failed to update profile: ${e.toString()}');
      } finally {
        isLoading.value = false;
        nameController.dispose();
      }
    }
  }

  Future<void> editPhoneNumber() async {
    final TextEditingController phoneController = TextEditingController(
      text: userProfile.value.mobile,
    );

    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text(
          'Edit Phone Number',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: Color(0xFFD1D5DB)),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF374151)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF16A34A)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFD1D5DB)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && phoneController.text.isNotEmpty) {
      try {
        isLoading.value = true;
        await _authService.updateUserProfile(
          userId: userProfile.value.id,
          mobile: phoneController.text,
        );
        await loadUserProfile();
        _showSuccessSnackbar('Phone number updated successfully');
      } catch (e) {
        _showErrorSnackbar('Failed to update phone number: ${e.toString()}');
      } finally {
        isLoading.value = false;
        phoneController.dispose();
      }
    }
  }

  Future<void> selectProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        isLoading.value = true;
        final String? secureUrl = await _uploadToCloudinary(image);

        if (secureUrl != null) {
          await _updateUserProfileImage(secureUrl);
          await loadUserProfile();
          _showSuccessSnackbar('Profile image updated successfully');
        } else {
          throw Exception('Upload failed: No secure URL returned');
        }
      }
    } catch (e) {
      _showErrorSnackbar('Failed to update profile image: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> _uploadToCloudinary(XFile image) async {
    try {
      // Validate file size
      final fileSize = await image.length();
      if (fileSize == 0) {
        throw Exception('Invalid image file');
      }

      // Check file size limit (10MB)
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image size exceeds 10MB limit');
      }

      // Generate unique filename
      final userId = _authService.currentUser!.uid;
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';

      // Prepare request URL
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/${_cloudinaryConfig.cloudName}/image/upload",
      );

      // Create multipart request
      var request = http.MultipartRequest("POST", uri);

      // Read file bytes
      var fileBytes = await image.readAsBytes();
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      );

      // Add files and fields to request
      request.files.add(multipartFile);

      // Unsigned upload preset configuration
      request.fields['upload_preset'] = 'user_profiles_unsigned';
      request.fields['folder'] = 'user_profiles';

      // Optional: Add transformation
      request.fields['transformation'] = 'c_limit,h_500,w_500,q_80';

      // Send the request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      // Process response
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(responseBody);
        return jsonResponse['secure_url'];
      } else {
        // Detailed error logging
        print('Upload failed with status ${response.statusCode}');
        print('Response body: $responseBody');

        // Parse and display specific error message
        var errorResponse = jsonDecode(responseBody);
        String errorMessage =
            errorResponse['error']?['message'] ?? 'Unknown upload error';

        throw Exception('Upload failed: $errorMessage');
      }
    } catch (e) {
      print('Cloudinary upload error: $e');

      // Specific error handling
      if (e is SocketException) {
        _showErrorSnackbar(
          'Network Error: Please check your internet connection',
        );
      } else if (e is http.ClientException) {
        _showErrorSnackbar('Connection error: ${e.message}');
      } else {
        _showErrorSnackbar('Image upload failed: ${e.toString()}');
      }

      return null;
    }
  }

  Future<void> _updateUserProfileImage(String cloudinaryUrl) async {
    try {
      final userId = _authService.currentUser!.uid;
      await _firestore.collection('users').doc(userId).update({
        'profileImage': cloudinaryUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Firestore Update Error: $e');
      throw Exception('Failed to update profile image in database');
    }
  }

  Future<void> deleteProfileImage() async {
    try {
      // Check if there's an existing profile image
      if (userProfile.value.profileImage == null) {
        _showErrorSnackbar('No profile image to delete');
        return;
      }

      // Show confirmation dialog
      final confirmDelete = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Profile Image'),
          content: const Text(
            'Are you sure you want to delete your profile image?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmDelete == true) {
        isLoading.value = true;

        // Extract public ID from the Cloudinary URL
        final Uri imageUri = Uri.parse(userProfile.value.profileImage!);
        final String publicId = path.basenameWithoutExtension(imageUri.path);

        // Delete from Cloudinary
        await _deleteFromCloudinary(publicId);

        // Remove from Firestore
        final userId = _authService.currentUser!.uid;
        await _firestore.collection('users').doc(userId).update({
          'profileImage': FieldValue.delete(),
        });

        // Reload profile
        await loadUserProfile();

        _showSuccessSnackbar('Profile image deleted successfully');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to delete profile image: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _deleteFromCloudinary(String publicId) async {
    try {
      // Prepare request URL
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/${_cloudinaryConfig.cloudName}/image/destroy",
      );

      // Create the request body
      final body = {'public_id': publicId, 'api_key': _cloudinaryConfig.apiKey};

      // Send delete request
      final response = await http.post(uri, body: body);

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        return responseBody['result'] == 'ok';
      } else {
        print("Failed to delete file, status: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print('Cloudinary delete error: $e');
      return false;
    }
  }

  void changePassword() {
    Get.toNamed(Routes.resetPassword, arguments: userProfile.value.email);
  }

  void openFAQ() {
    Get.toNamed('/faq');
  }

  void openHelpAndContact() {
    Get.toNamed('/help-support');
  }

  Future<void> logout() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(0xFFD1D5DB)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFD1D5DB)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        isLoading.value = true;
        await _authService.signOut();
        isLoggedIn.value = false;
        userProfile.value = UserProfile(
          id: '',
          fullName: '',
          email: '',
          mobile: '',
          profileImage: null,
        );
        Get.offAllNamed(Routes.login);
      } catch (e) {
        _showErrorSnackbar('Failed to logout: ${e.toString()}');
      } finally {
        isLoading.value = false;
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }
}
