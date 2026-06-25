import 'package:flutter/foundation.dart';
import 'package:fresh_harvest/models/cart_item.dart';
import 'package:fresh_harvest/models/product.dart';

class CustomerCartManager extends ChangeNotifier {
  CustomerCartManager._();

  static final CustomerCartManager instance = CustomerCartManager._();

  final Map<String, CartItem> _items = {};

  List<CartItem> get items => List.unmodifiable(_items.values);

  int get totalItems => _items.values.fold<int>(0, (sum, item) => sum + item.quantity);

  int get distinctItems => _items.length;

  double get subtotal =>
      _items.values.fold<double>(0.0, (sum, item) => sum + item.lineTotal);

  static const double deliveryFee = 2.99;

  double get deliveryCharge => _items.isEmpty ? 0.0 : deliveryFee;

  double get totalAmount => subtotal + deliveryCharge;

  bool get isEmpty => _items.isEmpty;

  bool get hasItems => _items.isNotEmpty;

  bool contains(Product product) => _items.containsKey(product.id);

  int quantityFor(Product product) => _items[product.id]?.quantity ?? 0;

  void addProduct(Product product) {
    if (_items.containsKey(product.id)) {
      _items[product.id] = _items[product.id]!.copyWith(
        quantity: _items[product.id]!.quantity + 1,
      );
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (!_items.containsKey(productId)) return;
    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      _items[productId] = _items[productId]!.copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
