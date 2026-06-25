import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_harvest/config/app_constants.dart';
import 'package:fresh_harvest/models/category.dart';
import 'package:fresh_harvest/models/product.dart';
import 'package:fresh_harvest/providers/language_provider.dart';
import 'package:fresh_harvest/screens/customer/customer_cart_manager.dart';
import 'package:fresh_harvest/services/mock_data_service.dart';
import 'package:fresh_harvest/widgets/product_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, required this.onProductTap});

  final ValueChanged<Product> onProductTap;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final Future<List<dynamic>> _categoriesAndProducts;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _categoriesAndProducts = Future.wait([
      MockDataService.instance.getCategories(),
      MockDataService.instance.getProducts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Read language once at build level
    final isUrdu = context.watch<LanguageProvider>().isUrdu;

    return FutureBuilder<List<dynamic>>(
      future: _categoriesAndProducts,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Unable to load categories.'));
        }

        final categories = snapshot.data?[0] as List<Category>;
        final products   = snapshot.data?[1] as List<Product>;

        _selectedCategoryId ??= categories.first.id;

        final filteredProducts = products
            .where((p) => p.categoryId == _selectedCategoryId)
            .toList();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: kPadding,
              vertical: kPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ───────────────────────────────────────────────────
                Text(
                  isUrdu ? 'اقسام دیکھیں' : 'Browse Categories',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 10),

                // ── Compact horizontal category strip ────────────────────────
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _CompactCategoryChip(
                        category: category,
                        isSelected: category.id == _selectedCategoryId,
                        isUrdu: isUrdu,   // ✅ pass language flag
                        onTap: () =>
                            setState(() => _selectedCategoryId = category.id),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // ── Section label ─────────────────────────────────────────────
                Row(
                  children: [
                    Text(
                      isUrdu ? 'مصنوعات' : 'Products',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${filteredProducts.length})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: kTextSecondary,
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Products grid ─────────────────────────────────────────────
                Expanded(
                  child: filteredProducts.isEmpty
                      ? Center(
                          child: Text(
                            isUrdu
                                ? 'اس قسم میں کوئی مصنوع نہیں۔'
                                : 'No products in this category.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      : GridView.builder(
                          itemCount: filteredProducts.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                MediaQuery.of(context).size.width >= 900
                                    ? 4
                                    : MediaQuery.of(context).size.width >= 600
                                        ? 3
                                        : 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 0.70, // ✅ reduced for more vertical space, fixes overflow
                          ),
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return ProductCard(
                              product: product,
                              onTap: () => widget.onProductTap(product),
                              onAddToCart: () {
                                CustomerCartManager.instance
                                    .addProduct(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${product.name} added to cart.'),
                                    duration:
                                        const Duration(milliseconds: 900),
                                  ),
                                );
                              },
                              isInCart: CustomerCartManager.instance
                                  .contains(product),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Compact Category Chip ────────────────────────────────────────────────────

class _CompactCategoryChip extends StatelessWidget {
  const _CompactCategoryChip({
    required this.category,
    required this.isSelected,
    required this.isUrdu,       // ✅ new
    required this.onTap,
  });

  final Category     category;
  final bool         isSelected;
  final bool         isUrdu;    // ✅ new
  final VoidCallback onTap;

  // ✅ Urdu names keyed by category id — matches mock_data_service.dart ids
  static const _urduNames = <String, String>{
    'cat1': 'پھل',
    'cat2': 'سبزیاں',
    'cat3': 'پتے دار',
    'cat4': 'غیر معمولی',
    'cat5': 'جڑی بوٹیاں',
    'cat6': 'نامیاتی',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // ✅ Pick Urdu or English name
    final displayName = isUrdu
        ? (_urduNames[category.id] ?? category.name)
        : category.name;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        constraints: const BoxConstraints(minWidth: 52, maxWidth: 120),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withAlpha(60),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CategoryIcon(category: category, isSelected: isSelected),
            const SizedBox(width: 4),
            Text(
              displayName,           // ✅ uses Urdu or English
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: isUrdu  // ✅ RTL for Urdu text
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              style: tt.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? cs.onPrimary : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Icon ────────────────────────────────────────────────────────────

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({
    required this.category,
    required this.isSelected,
  });

  final Category category;
  final bool     isSelected;

  static const _emojis = <String, String>{
    'cat1': '🍎',
    'cat2': '🥦',
    'cat3': '🥬',
    'cat4': '🥭',
    'cat5': '🌿',
    'cat6': '🌱',
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final asset = category.iconAsset.trim();
    final emoji = asset.isEmpty ? (_emojis[category.id] ?? '') : asset;

    if (emoji.isNotEmpty && emoji.runes.length <= 2) {
      return Text(emoji, style: const TextStyle(fontSize: 14));
    }

    if (asset.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          asset,
          width: 16,
          height: 16,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(cs),
        ),
      );
    }

    if (asset.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.asset(
          asset,
          width: 16,
          height: 16,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(cs),
        ),
      );
    }

    return _fallback(cs);
  }

  Widget _fallback(ColorScheme cs) => Icon(
        Icons.category_rounded,
        size: 14,
        color: isSelected ? cs.onPrimary : cs.primary,
      );
}