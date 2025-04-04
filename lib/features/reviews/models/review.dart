import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String mediaId;
  final String mediaType; // movie, teledrama, song, book
  final String userId;
  final String userFullName;
  final String? userProfileImage;
  final double rating;
  final String content;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.mediaId,
    required this.mediaType,
    required this.userId,
    required this.userFullName,
    this.userProfileImage,
    required this.rating,
    required this.content,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      mediaId: map['mediaId'] ?? '',
      mediaType: map['mediaType'] ?? '',
      userId: map['userId'] ?? '',
      userFullName: map['userFullName'] ?? '',
      userProfileImage: map['userProfileImage'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      content: map['content'] ?? '',
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mediaId': mediaId,
      'mediaType': mediaType,
      'userId': userId,
      'userFullName': userFullName,
      'userProfileImage': userProfileImage,
      'rating': rating,
      'content': content,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
