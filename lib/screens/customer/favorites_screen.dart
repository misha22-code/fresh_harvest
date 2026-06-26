// lib/screens/customer/favorites_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_harvest/providers/favorite_provider.dart';
import 'package:fresh_harvest/providers/cart_provider.dart';
import 'package:fresh_harvest/widgets/product_card.dart';
import 'package:fresh_harvest/config/app_constants.dart';
import 'package:fresh_harvest/models/product.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  void _navigateToProductDetails(BuildContext context, Product product) {
    Navigator.pushNamed(context, '/productDetails', arguments: product);
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoriteProvider>();
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: favorites.favoriteProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorite products yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon to add products to favorites',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: favorites.favoriteProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.70,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final product = favorites.favoriteProducts[index];
                  final isInCart = cartProvider.items
                      .any((item) => item.product.id == product.id);

                  return ProductCard(
                    product: product,
                    onTap: () => _navigateToProductDetails(context, product),
                    onAddToCart: () {
                      cartProvider.addProduct(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          duration: const Duration(milliseconds: 900),
                          backgroundColor: kPrimaryColor,
                        ),
                      );
                    },
                    isInCart: isInCart,
                  );
                },
              ),
            ),
    );
  }
}