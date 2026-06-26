// lib/screens/customer/categories_screen.dart
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
        final products = snapshot.data?[1] as List<Product>;

        _selectedCategoryId ??= categories.first.id;

        final filteredProducts = products
            .where((p) => p.categoryId == _selectedCategoryId)
            .toList();

        return Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Browse Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // ─── Categories Horizontal List ──────────────────────────────
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = _selectedCategoryId == category.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = category.id;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? kPrimaryColor : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(25),
                          border: isSelected
                              ? null
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Text(
                              category.iconAsset,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isUrdu ? _getUrduName(category.id) : category.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // ─── Products Count ──────────────────────────────────────────
              Row(
                children: [
                  Text(
                    'Products',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
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

              // ─── Products Grid ────────────────────────────────────────────
              Expanded(
                child: filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          isUrdu ? 'اس قسم میں کوئی مصنوع نہیں۔' : 'No products in this category.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : GridView.builder(
                        itemCount: filteredProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.70,
                        ),
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return ProductCard(
                            product: product,
                            onTap: () => widget.onProductTap(product),
                            onAddToCart: () {
                              CustomerCartManager.instance.addProduct(product);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${product.name} added to cart.'),
                                  duration: const Duration(milliseconds: 900),
                                ),
                              );
                            },
                            isInCart: CustomerCartManager.instance.contains(product),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getUrduName(String categoryId) {
    const names = {
      'cat1': 'پھل',
      'cat2': 'سبزیاں',
      'cat3': 'پتے دار',
      'cat4': 'غیر معمولی',
      'cat5': 'جڑی بوٹیاں',
      'cat6': 'نامیاتی',
    };
    return names[categoryId] ?? categoryId;
  }
}