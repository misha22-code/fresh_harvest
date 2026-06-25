import 'package:flutter/material.dart';
import 'package:fresh_harvest/config/app_constants.dart';
import 'package:fresh_harvest/models/product.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/favorite_provider.dart';

/// Product card for grid layouts.
///
/// Shows: image · Urdu name · English name · price · favourite · add-to-cart.
/// Removed: category ID badge, stock badge, vendor ID, origin, quality, usage.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.isInCart = false,
  });

  final Product       product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool          isInCart;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      color: kWhiteColor,
      elevation: 3,
      shadowColor: kShadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Image (60 %) ──────────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      product.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Container(
                        color: kBorderColor,
                        child: const Center(
                          child: Icon(
                            Icons.shopping_basket_outlined,
                            size: 40,
                            color: kTextSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Subtle bottom gradient
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 40,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(60),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Favourite heart — bottom right
                  Positioned(
                    bottom: kPaddingSmall,
                    right: kPaddingSmall,
                    child: Consumer<FavoriteProvider>(
                      builder: (context, favorites, _) {
                        final isFav = favorites.isFavorite(product.id);
                        return GestureDetector(
                          onTap: () => favorites.toggleFavorite(product),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(210),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: isFav ? Colors.red : kTextSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Details (40 %) ────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // Names
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<LanguageProvider>(
                          builder: (context, language, _) {
                            return Text(
                              language.isUrdu
                                  ? product.urduName
                                  : product.name,
                              style: tt.titleSmall?.copyWith(
                                fontSize: 16,
                                color: kTextPrimary,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textDirection: language.isUrdu
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                            );
                          },
                        ),
                        Text(
                          product.name,
                          style: tt.labelSmall?.copyWith(
                            color: kTextSecondary,
                            fontSize: 10,
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Price + Add to Cart
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Rs ${product.price.toStringAsFixed(0)}/${product.unit}',
                            style: tt.labelLarge?.copyWith(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _AddToCartButton(
                          isInCart: isInCart,
                          onPressed: onAddToCart,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add to Cart button ───────────────────────────────────────────────────────

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({
    required this.isInCart,
    required this.onPressed,
  });

  final bool          isInCart;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isInCart) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: kAccentColor.withAlpha(51),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded,
            size: 18, color: kPrimaryColor),
      );
    }

    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: kPrimaryColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: const Icon(
            Icons.add_shopping_cart_rounded,
            size: 18,
            color: kWhiteColor,
          ),
        ),
      ),
    );
  }
}