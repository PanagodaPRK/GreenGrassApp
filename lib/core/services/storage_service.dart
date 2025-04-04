// lib/core/services/storage_service.dart
import 'dart:io';
import 'firebase_service.dart';

class StorageService {
  final FirebaseService _firebaseService;

  StorageService(this._firebaseService);

  // Upload a single image
  Future<String> uploadImage(File file, String path) async {
    try {
      final storageRef = _firebaseService.storage.ref().child(path);
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Upload multiple images
  Future<List<String>> uploadImages(List<File> files, String basePath) async {
    try {
      final List<String> urls = [];

      for (int i = 0; i < files.length; i++) {
        final path = '$basePath/image_$i.jpg';
        final url = await uploadImage(files[i], path);
        urls.add(url);
      }

      return urls;
    } catch (e) {
      rethrow;
    }
  }

  // Delete an image
  Future<void> deleteImage(String url) async {
    try {
      final storageRef = _firebaseService.storage.refFromURL(url);
      await storageRef.delete();
    } catch (e) {
      rethrow;
    }
  }
}
