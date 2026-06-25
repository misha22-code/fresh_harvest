// lib/models/cart_item.dart
import 'package:fresh_harvest/models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  // ── Computed Properties ──────────────────────────────────────────────────

  /// Total price for this cart item (price × quantity)
  double get lineTotal => product.price * quantity;

  // ── Copy With ──────────────────────────────────────────────────────────

  /// Create a copy of this CartItem with optional new values
  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  // ── Equality & HashCode ────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.product.id == product.id &&
        other.quantity == quantity;
  }

  @override
  int get hashCode => product.id.hashCode ^ quantity.hashCode;

  // ── String Representation ──────────────────────────────────────────────

  @override
  String toString() {
    return 'CartItem(product: ${product.name}, quantity: $quantity, total: $lineTotal)';
  }
}