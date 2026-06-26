// lib/widgets/skeleton_loader.dart
import 'package:flutter/material.dart';
import 'package:fresh_harvest/config/app_constants.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// ShimmerBox — base animated shimmer rectangle
// ═══════════════════════════════════════════════════════════════════════════════

/// An animated shimmer placeholder box.
///
/// Drives a left-to-right shimmer sweep using a looping [AnimationController]
/// and a [LinearGradient] transition from dark grey → light grey → dark grey.
class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = kButtonRadius,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  static const _colorBase    = Color(0xFFE0E0E0); // light grey
  static const _colorShimmer = Color(0xFFF5F5F5); // lighter grey

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end:   Alignment(_animation.value,     0),
              colors: const [_colorBase, _colorShimmer, _colorBase],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ProductCardSkeleton
// ═══════════════════════════════════════════════════════════════════════════════

/// Shimmer placeholder matching the layout of [ProductCard].
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(kCardRadius),
        boxShadow: [
          BoxShadow(color: kShadowColor, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area (60 %)
          Expanded(
            flex: 6,
            child: ShimmerBox(
              width: double.infinity,
              height: double.infinity,
              borderRadius: kCardRadius,
            ),
          ),
          // Details area (40 %)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(kPaddingSmall),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ShimmerBox(
                    width: double.infinity,
                    height: 12,
                    borderRadius: 4,
                  ),
                  ShimmerBox(
                    width: 80,
                    height: 10,
                    borderRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ProductGridSkeleton
// ═══════════════════════════════════════════════════════════════════════════════

/// A full-grid shimmer layout matching the responsive product grid.
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  // ✅ FIXED: gridColumns method added
  int gridColumns(double width) {
    if (width < 600) return 2;
    if (width < 900) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = gridColumns(constraints.maxWidth);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(kPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: kPaddingSmall,
            mainAxisSpacing: kPaddingSmall,
            childAspectRatio: 0.7,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) => const ProductCardSkeleton(),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// StatsRowSkeleton
// ═══════════════════════════════════════════════════════════════════════════════

/// A horizontal row of shimmer stat card placeholders for dashboards.
class StatsRowSkeleton extends StatelessWidget {
  const StatsRowSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: kPadding),
      child: Row(
        children: List.generate(count, (i) {
          return Padding(
            padding: EdgeInsets.only(right: i < count - 1 ? kPaddingSmall : 0),
            child: Container(
              width: 160,
              height: 90,
              decoration: BoxDecoration(
                color: kWhiteColor,
                borderRadius: BorderRadius.circular(kCardRadius),
                boxShadow: [
                  BoxShadow(
                    color: kShadowColor,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(kPadding),
                child: Row(
                  children: [
                    const ShimmerBox(width: 44, height: 44, borderRadius: 12),
                    const SizedBox(width: kPaddingSmall),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          ShimmerBox(width: double.infinity, height: 16, borderRadius: 4),
                          SizedBox(height: 6),
                          ShimmerBox(width: 60, height: 10, borderRadius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ListItemSkeleton
// ═══════════════════════════════════════════════════════════════════════════════

/// A shimmer placeholder for list rows (circle avatar + two text bars).
class ListItemSkeleton extends StatelessWidget {
  const ListItemSkeleton({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: kPadding,
        vertical: kPaddingSmall,
      ),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: kPaddingSmall),
      itemBuilder: (context, index) => const _ListItemSkeletonRow(),
    );
  }
}

class _ListItemSkeletonRow extends StatelessWidget {
  const _ListItemSkeletonRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(kPadding),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(kCardRadius),
        boxShadow: [
          BoxShadow(
            color: kShadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circle avatar placeholder
          const ShimmerBox(width: 44, height: 44, borderRadius: 22),
          const SizedBox(width: kPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: double.infinity, height: 13, borderRadius: 4),
                SizedBox(height: 6),
                ShimmerBox(width: 120, height: 10, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EmptyStateWidget
// ═══════════════════════════════════════════════════════════════════════════════

/// Displays a friendly empty-state with a large icon, title, optional subtitle,
/// and an optional action button.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Optional button widget (e.g., an [ElevatedButton] or [TextButton]).
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kPaddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 80,
              color: kBorderColor,
            ),
            const SizedBox(height: kPadding),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(color: kTextPrimary),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: kPaddingSmall),
              Text(
                subtitle!,
                style: textTheme.bodyMedium?.copyWith(color: kTextSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: kPaddingLarge),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ErrorStateWidget
// ═══════════════════════════════════════════════════════════════════════════════

/// Displays an error state with a red icon, message, and optional retry button.
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;

  /// When non-null, a "Try Again" button is rendered below the error message.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kPaddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: kErrorColor,
            ),
            const SizedBox(height: kPadding),
            Text(
              message,
              style: textTheme.bodyLarge?.copyWith(color: kTextPrimary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: kPaddingLarge),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}