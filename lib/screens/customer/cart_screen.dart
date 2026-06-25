import 'package:flutter/material.dart';
import 'package:fresh_harvest/config/app_constants.dart';
import 'package:fresh_harvest/models/cart_item.dart';
import 'package:fresh_harvest/screens/customer/customer_cart_manager.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.onCheckout});

  final VoidCallback? onCheckout;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CustomerCartManager _cartManager = CustomerCartManager.instance;

  @override
  void initState() {
    super.initState();
    _cartManager.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() => setState(() {});

  void _updateQuantity(CartItem item, int delta) {
    _cartManager.updateQuantity(item.product.id, item.quantity + delta);
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartManager.items;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_cart_outlined,
                  size: 72, color: kTextSecondary),
              const SizedBox(height: 16),
              Text(
                'Your cart is empty',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Browse products and add fresh items to your cart.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: kPadding, vertical: kPadding),
      child: Column(
        children: [

          // ── Cart items ───────────────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final item = items[index];
                return _CartItemTile(
                  item: item,
                  onDecrease: () => _updateQuantity(item, -1),
                  onIncrease: () => _updateQuantity(item, 1),
                  onRemove: () =>
                      _cartManager.removeProduct(item.product.id),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ── Summary card + checkout button ────────────────────────────────
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kCardRadius)),
            child: Padding(
              padding: const EdgeInsets.all(kPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // Subtotal
                  _SummaryRow(
                    label: 'Subtotal',
                    value:
                        'Rs ${_cartManager.subtotal.toStringAsFixed(0)}',
                  ),
                  const SizedBox(height: 8),

                  // Delivery fee
                  _SummaryRow(
                    label: 'Delivery Fee',
                    value:
                        'Rs ${_cartManager.deliveryCharge.toStringAsFixed(0)}',
                  ),

                  const Divider(height: 24),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Rs ${_cartManager.totalAmount.toStringAsFixed(0)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Checkout button
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed:
                          widget.onCheckout != null && _cartManager.hasItems
                              ? widget.onCheckout
                              : null,
                      icon: const Icon(Icons.shopping_bag_outlined,
                          size: 20),
                      label: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(kButtonRadius),
                        ),
                      ),
                    ),
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

// ─── Summary Row ──────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: kTextSecondary)),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

// ─── Cart Item Tile ───────────────────────────────────────────────────────────

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final CartItem     item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius)),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                item.product.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  width: 64,
                  height: 64,
                  color: cs.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image,
                      color: kTextSecondary, size: 26),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Name + price + qty controls
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Product name
                  Text(
                    item.product.name,
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  // Price per unit
                  Text(
                    'Rs ${item.product.price.toStringAsFixed(0)} / ${item.product.unit}',
                    style: tt.bodySmall?.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // [ - ]  qty  [ + ]
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QtyButton(
                          icon: Icons.remove_rounded, onTap: onDecrease),
                      SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: tt.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      _QtyButton(
                          icon: Icons.add_rounded, onTap: onIncrease),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Line total + delete
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs ${(item.product.price * item.quantity).toStringAsFixed(0)}',
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: kPrimaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(18),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent, size: 17),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quantity Button ──────────────────────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onTap});

  final IconData     icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: kPrimaryColor.withAlpha(20),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: kPrimaryColor.withAlpha(60)),
        ),
        child: Icon(icon, size: 16, color: kPrimaryColor),
      ),
    );
  }
}