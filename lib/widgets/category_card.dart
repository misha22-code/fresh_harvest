import 'package:flutter/material.dart';
import 'package:fresh_harvest/config/app_constants.dart';
import 'package:fresh_harvest/models/category.dart';

/// A visually distinct category card used in category browsing grids and rows.
///
/// When [isSelected] is `true` the card switches to a solid green background
/// with white text — providing clear visual feedback of the active category.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  final Category category;

  /// Highlights the card with a [kPrimaryColor] background when `true`.
  final bool isSelected;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final backgroundColor = isSelected
        ? kPrimaryColor
        : kAccentColor.withAlpha(31); // ~12 % opacity

    final labelColor = isSelected ? kWhiteColor : kTextPrimary;
    final subColor   = isSelected ? kWhiteColor.withAlpha(179) : kTextSecondary;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(kCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kCardRadius),
        splashColor: kPrimaryColor.withAlpha(51),
        highlightColor: kPrimaryColor.withAlpha(26),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kPaddingSmall,
            vertical: kPadding,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Emoji icon from iconAsset
              Text(
                category.iconAsset,
                style: const TextStyle(fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Category name
              Text(
                category.name,
                style: textTheme.bodyMedium?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),

              // Item count
              Text(
                '${category.itemCount} items',
                style: textTheme.labelSmall?.copyWith(color: subColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
