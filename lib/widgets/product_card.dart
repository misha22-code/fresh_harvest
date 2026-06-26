// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:fresh_harvest/config/app_constants.dart';
import 'package:fresh_harvest/models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAddToCart,
    required this.isInCart,
  });

  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final bool isInCart;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final isUrdu = true; // Will be passed from parent

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kCardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Product Image ──────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(kCardRadius),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        product.imageUrl,
                        height: 80,
                        width: 80,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.eco_rounded,
                          size: 40,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                    if (isInCart)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: kPrimaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ─── Product Info ────────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Urdu name
                        Text(
                          product.urduName,
                          style: tt.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: kTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.rtl,
                        ),
                        // English name
                        Text(
                          product.name,
                          style: tt.labelSmall?.copyWith(
                            color: kTextSecondary,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // Price
                    Text(
                      'Rs ${product.price.toStringAsFixed(0)}/${product.unit}',
                      style: tt.bodySmall?.copyWith(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: ElevatedButton(
                        onPressed: onAddToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInCart ? Colors.grey.shade300 : kPrimaryColor,
                          foregroundColor: isInCart ? kTextSecondary : Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(
                          isInCart ? 'Added ✓' : '+ Cart',
                        ),
                      ),
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