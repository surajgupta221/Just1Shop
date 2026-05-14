// lib/presentation/customer/widgets/category_card_modern.dart
import 'package:flutter/material.dart';
import '../../../core/constants/ui_constants.dart';

class CategoryCardModern extends StatelessWidget {
  final String categoryName;
  final IconData icon;
  final Color? bgColor;

  const CategoryCardModern({
    Key? key,
    required this.categoryName,
    required this.icon,
    this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = bgColor ?? UIConstants.primaryLight;

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: UIConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(UIConstants.radiusM),
            ),
            child: Icon(
              icon,
              color: UIConstants.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: UIConstants.paddingXS),
          Text(
            categoryName,
            style: UITextStyles.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
