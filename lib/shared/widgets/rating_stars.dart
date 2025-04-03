// lib/shared/widgets/rating_stars.dart
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool isSelectable;
  final Function(double)? onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 24,
    this.isSelectable = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isFilled = starValue <= rating;
        final isHalfFilled = starValue > rating && starValue - 0.5 <= rating;

        return GestureDetector(
          onTap: isSelectable
              ? () => onRatingChanged?.call(starValue.toDouble())
              : null,
          child: Icon(
            isFilled
                ? Icons.star
                : isHalfFilled
                    ? Icons.star_half
                    : Icons.star_border,
            color: AppColors.warning,
            size: size,
          ),
        );
      }),
    );
  }
}
