import 'package:flutter/material.dart';
import '../models/product.dart';

class FavoriteProvider extends ChangeNotifier {
  final List<Product> _favoriteProducts = [];

  List<Product> get favoriteProducts =>
      List.unmodifiable(_favoriteProducts);

  bool isFavorite(String productId) {
    return _favoriteProducts.any(
      (product) => product.id == productId,
    );
  }

  void toggleFavorite(Product product) {
    final index = _favoriteProducts.indexWhere(
      (item) => item.id == product.id,
    );

    if (index >= 0) {
      _favoriteProducts.removeAt(index);
    } else {
      _favoriteProducts.add(product);
    }

    notifyListeners();
  }
}