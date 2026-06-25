// lib/providers/product_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fresh_harvest/models/product.dart';
import 'package:fresh_harvest/services/mock_data_service.dart';

class ProductProvider extends ChangeNotifier {
  final MockDataService _mockService = MockDataService.instance;
  
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = false;
  String? _selectedCategoryId;
  String _searchQuery = '';

  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  bool get isLoading => _isLoading;
  String? get selectedCategoryId => _selectedCategoryId;

  // ─── Load Products ────────────────────────────────────────────────────────

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _mockService.getProducts();
      _filteredProducts = [];
      _applyFilters();
    } catch (e) {
      debugPrint('Error loading products: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Filters ──────────────────────────────────────────────────────────────

  void _applyFilters() {
    var filtered = List<Product>.from(_products);

    if (_selectedCategoryId != null) {
      filtered = filtered.where((p) => p.categoryId == _selectedCategoryId).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) =>
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.urduName.contains(_searchQuery)
      ).toList();
    }

    _filteredProducts = filtered;
    notifyListeners();
  }

  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // ─── CRUD Operations ─────────────────────────────────────────────────────

  Future<void> addProduct(Product product) async {
    try {
      await _mockService.addProduct(product);
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _mockService.updateProduct(product);
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _mockService.deleteProduct(productId);
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  // ✅ FIXED: Update stock using updateProduct
  Future<void> updateStock(String productId, int newStock) async {
    try {
      // Find the product
      final productIndex = _products.indexWhere((p) => p.id == productId);
      if (productIndex != -1) {
        final currentProduct = _products[productIndex];
        final updatedProduct = currentProduct.copyWith(stockQuantity: newStock);
        await _mockService.updateProduct(updatedProduct);
        await loadProducts();
      }
    } catch (e) {
      debugPrint('Error updating stock: $e');
      rethrow;
    }
  }

  // ─── Get Product by ID ──────────────────────────────────────────────────

  Product? getProductById(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }
}