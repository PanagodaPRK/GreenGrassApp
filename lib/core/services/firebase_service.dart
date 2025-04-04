// lib/core/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getters for Firebase instances
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;

  // Collection references
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get moviesCollection => _firestore.collection('movies');
  CollectionReference get teledramasCollection =>
      _firestore.collection('teledramas');
  CollectionReference get songsCollection => _firestore.collection('songs');
  CollectionReference get booksCollection => _firestore.collection('books');
  CollectionReference get reviewsCollection => _firestore.collection('reviews');
  CollectionReference get commentsCollection =>
      _firestore.collection('comments');
}
