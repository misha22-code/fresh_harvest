import 'package:flutter/material.dart';
import 'package:fresh_harvest/config/app_constants.dart';

/// A premium stats / KPI card for dashboards.
///
/// Displays a coloured icon on the left and value + label on the right.
/// An optional [subtitle] can show trend info, and [trailing] supports
/// completely custom right-side widgets (e.g., a sparkline).
class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.subtitle,
    this.trailing,
  });

  final String label;
  final String value;
  final IconData icon;

  /// Defaults to [kPrimaryColor] when null.
  final Color? iconColor;

  /// Card background — defaults to [kWhiteColor].
  final Color? backgroundColor;

  /// Optional secondary information shown below the label (e.g., "↑ 12%").
  final String? subtitle;

  /// Optional trailing widget replacing the default layout's right padding.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final resolvedIcon = iconColor ?? kPrimaryColor;

    return Card(
      color: backgroundColor ?? kWhiteColor,
      elevation: 3,
      shadowColor: kShadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // ✅ consistent radius
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // ✅ reduced padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Icon container ───────────────────────────────────────────
            Container(
              width: 44,  // ✅ reduced icon container
              height: 44, // ✅ reduced icon container
              decoration: BoxDecoration(
                color: resolvedIcon.withAlpha(38),
                borderRadius: BorderRadius.circular(16), // ✅ consistent radius
              ),
              child: Icon(icon, color: resolvedIcon, size: 22), // ✅ smaller icon
            ),
            const SizedBox(width: kPadding),

            // ── Text block ───────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 18,                        // ✅ reduced value size
                      color: kTextPrimary,
                      fontWeight: FontWeight.w700,         // ✅ bold value
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: kTextSecondary,
                      fontSize: 15,                        // ✅ larger label
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: textTheme.labelSmall?.copyWith(
                        color: kTextSecondary,
                      ),
                    ),
                ],
              ),
            ),

            // ── Optional trailing ────────────────────────────────────────
            if (trailing != null) ...[
              const SizedBox(width: kPaddingSmall),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}