// lib/shared/widgets/comment_card.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../features/reviews/models/comment.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  final bool isReply;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final Function(Comment)? onViewReplies;
  final List<Comment>? replies;
  final bool showReplies;

  const CommentCard({
    super.key,
    required this.comment,
    this.isReply = false,
    required this.onLike,
    required this.onReply,
    this.onViewReplies,
    this.replies,
    this.showReplies = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: isReply ? 40 : 0,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image
              CircleAvatar(
                backgroundImage: comment.userProfileImage != null
                    ? NetworkImage(comment.userProfileImage!)
                    : null,
                backgroundColor: AppColors.primaryLight,
                radius: 18,
                child: comment.userProfileImage == null
                    ? Text(
                        comment.userFullName.isNotEmpty
                            ? comment.userFullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Comment text and actions
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Comment bubble
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isReply
                            ? Colors.grey.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username and timestamp
                          Row(
                            children: [
                              Text(
                                comment.userFullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _getTimeAgo(comment.createdAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Comment text
                          Text(comment.content),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Action buttons
                    Row(
                      children: [
                        // Like button
                        InkWell(
                          onTap: onLike,
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.thumb_up_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  comment.likeCount.toString(),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Reply button
                        InkWell(
                          onTap: onReply,
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.reply_outlined,
                                  size: 16,
                                  color: AppColors.textSecondary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Reply',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // View/hide replies
          if (!isReply && comment.replyCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 8),
              child: InkWell(
                onTap: () => onViewReplies?.call(comment),
                child: Text(
                  showReplies
                      ? 'Hide replies'
                      : 'View ${comment.replyCount} ${comment.replyCount == 1 ? 'reply' : 'replies'}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

          // Replies
          if (showReplies && replies != null && replies!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: replies!
                    .map(
                      (reply) => CommentCard(
                        comment: reply,
                        isReply: true,
                        onLike: onLike,
                        onReply: onReply,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }
}
