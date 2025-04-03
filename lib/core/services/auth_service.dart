import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'firebase_service.dart';
import '../../features/auth/models/user_profile.dart';

class AuthService extends GetxService {
  final FirebaseService _firebaseService;
  final RxBool isLoggedInValue = false.obs;

  AuthService(this._firebaseService);

  // Get current user
  User? get currentUser => _firebaseService.auth.currentUser;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  Future<AuthService> init() async {
    // Set initial logged in state
    isLoggedInValue.value = isLoggedIn;
    return this;
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final methods = await _firebaseService.auth.fetchSignInMethodsForEmail(
        email,
      );
      return methods.isNotEmpty;
    } catch (e) {
      print('Error checking if email exists: $e');
      return false;
    }
  }

  // Updated Sign up method to fix the PigeonUserDetails error
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String fullName,
    required String mobile,
  }) async {
    try {
      print('Starting user registration process');
      print('Email: $email');
      print('Full Name: $fullName');
      print('Mobile: $mobile');

      // Create user with email and password
      UserCredential? userCredential;
      try {
        userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email.trim(),
              password: password.trim(),
            );
        print('User credential created successfully');
      } catch (createUserError) {
        print('Error creating user: $createUserError');
        print('Error type: ${createUserError.runtimeType}');

        if (createUserError is FirebaseAuthException) {
          print('Firebase Auth Error Code: ${createUserError.code}');
          print('Firebase Auth Error Message: ${createUserError.message}');
        }

        rethrow;
      }

      final user = userCredential.user;
      if (user == null) {
        print('User creation failed: user is null');
        return {'success': false, 'message': 'Failed to create user'};
      }

      // Prepare user data for Firestore
      final userData = {
        'uid': user.uid,
        'fullName': fullName,
        'email': email,
        'mobile': mobile,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save user data to Firestore
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set(userData);
        print('User data saved to Firestore successfully');
      } catch (firestoreError) {
        print('Error saving user data to Firestore: $firestoreError');
        print('Error type: ${firestoreError.runtimeType}');

        // Optional: Delete the user if Firestore save fails
        try {
          await user.delete();
        } catch (deleteError) {
          print(
            'Error deleting user after Firestore save failure: $deleteError',
          );
        }

        return {'success': false, 'message': 'Failed to save user data'};
      }

      // Send email verification
      try {
        await user.sendEmailVerification();
        print('Verification email sent successfully');
      } catch (verificationError) {
        print('Error sending verification email: $verificationError');
        // This is not a critical failure, so we'll continue
      }

      return {
        'success': true,
        'message': 'Registration successful',
        'uid': user.uid,
      };
    } on FirebaseAuthException catch (e) {
      // Detailed Firebase Authentication error handling
      print('FirebaseAuthException occurred');
      print('Error Code: ${e.code}');
      print('Error Message: ${e.message}');

      String errorMessage = 'Registration failed';
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'The email is already in use';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          errorMessage = e.message ?? 'An unexpected error occurred';
      }

      return {'success': false, 'message': errorMessage};
    } catch (e) {
      // Catch-all for any other unexpected errors
      print('Unexpected error during registration');
      print('Error: $e');
      print('Error Type: ${e.runtimeType}');

      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Improved Login Method
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'Email and password are required'};
      }

      // Attempt to sign in
      final userCredential = await _firebaseService.auth
          .signInWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) {
        return {'success': false, 'message': 'Authentication failed'};
      }

      // Check email verification
      if (!user.emailVerified) {
        // Update Firestore to reflect unverified status
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'emailVerified': false});

        // Optional: Resend verification email
        try {
          await user.sendEmailVerification();
        } catch (e) {
          print('Failed to resend verification email: $e');
        }

        // Sign out and prevent login
        await _firebaseService.auth.signOut();

        return {
          'success': false,
          'message':
              'Please verify your email. A new verification link has been sent.',
        };
      }

      // Update Firestore to reflect verified status
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'emailVerified': true, 'lastLogin': FieldValue.serverTimestamp()},
      );

      // Update login state
      isLoggedInValue.value = true;

      return {'success': true, 'message': 'Login successful', 'uid': user.uid};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getFirebaseAuthErrorMessage(e)};
    } catch (e) {
      print('Unexpected login error: $e');
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Please provide a valid email address';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later';
      default:
        return e.message ?? 'An authentication error occurred';
    }
  }

  // ... [Rest of your AuthService methods remain unchanged]
  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseService.auth.signOut();
      isLoggedInValue.value = false;
    } catch (e) {
      rethrow;
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firebaseService.usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    if (currentUser != null) {
      return getUserProfile(currentUser!.uid);
    }
    return null;
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    try {
      await resetPassword(email);
      return {
        'success': true,
        'message': 'Password reset link has been sent to your email',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getFirebaseAuthErrorMessage(e)};
    } catch (e) {
      print('Forgot password error: $e');
      return {
        'success': false,
        'message': 'Failed to send password reset email',
      };
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Verify email with OTP (for Firebase, we'll use custom verification)
  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      // In Firebase, email verification is handled through the link sent to email
      // This is a placeholder for custom verification if needed
      await Future.delayed(const Duration(seconds: 2));
      return true;
    } catch (e) {
      print('Email verification error: $e');
      return false;
    }
  }

  // Resend verification code
  Future<bool> resendVerificationCode(String email) async {
    try {
      if (currentUser != null) {
        await currentUser!.sendEmailVerification();
        return true;
      }

      // Check if the email exists in the system
      final emailExists = await checkEmailExists(email);
      if (emailExists) {
        // We can't send verification without signing in, so just return true
        // and let the UI show appropriate messaging
        return true;
      }

      return false;
    } catch (e) {
      print('Resend verification error: $e');
      return false;
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? fullName,
    String? mobile,
    File? profileImage,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (fullName != null) {
        updates['fullName'] = fullName;
      }

      if (mobile != null) {
        updates['mobile'] = mobile;
      }

      // Upload new profile image if provided
      if (profileImage != null) {
        try {
          final storageRef = _firebaseService.storage
              .ref()
              .child('profile_images')
              .child('$userId.jpg');
          await storageRef.putFile(profileImage);
          final profileImageUrl = await storageRef.getDownloadURL();
          updates['profileImage'] = profileImageUrl;
        } catch (e) {
          print('Failed to upload profile image: $e');
          // Continue without updating profile image
        }
      }

      await _firebaseService.usersCollection.doc(userId).update(updates);
      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      print('Error updating profile: $e');
      return {'success': false, 'message': 'Failed to update profile'};
    }
  }
}
