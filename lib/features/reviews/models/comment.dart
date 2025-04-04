import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String? parentId; // null for top-level comments
  final String reviewId;
  final String userId;
  final String userFullName;
  final String? userProfileImage;
  final String content;
  final int likeCount;
  final int replyCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.id,
    this.parentId,
    required this.reviewId,
    required this.userId,
    required this.userFullName,
    this.userProfileImage,
    required this.content,
    required this.likeCount,
    required this.replyCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map, String id) {
    return Comment(
      id: id,
      parentId: map['parentId'],
      reviewId: map['reviewId'] ?? '',
      userId: map['userId'] ?? '',
      userFullName: map['userFullName'] ?? '',
      userProfileImage: map['userProfileImage'],
      content: map['content'] ?? '',
      likeCount: map['likeCount'] ?? 0,
      replyCount: map['replyCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'reviewId': reviewId,
      'userId': userId,
      'userFullName': userFullName,
      'userProfileImage': userProfileImage,
      'content': content,
      'likeCount': likeCount,
      'replyCount': replyCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
