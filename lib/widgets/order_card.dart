// lib/widgets/order_card.dart
import 'package:flutter/material.dart';
import 'package:fresh_harvest/config/app_constants.dart';
import 'package:fresh_harvest/models/order.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.showTrackButton = false,
    this.onTrack,
  });

  final Order order;
  final VoidCallback? onTap;
  final bool showTrackButton;
  final VoidCallback? onTrack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: kWhiteColor,
      elevation: 2,
      shadowColor: kShadowColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kCardRadius),
        child: Padding(
          padding: const EdgeInsets.all(kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id}',
                    style: textTheme.titleSmall?.copyWith(
                      color: kTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _StatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: kPaddingSmall),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: kTextSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: kTextSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                order.customerName,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              // ✅ FIXED: Use deliveryAddress.city instead of order.city
              Text(
                order.latitude != null && order.longitude != null
                    ? 'Location: ${order.latitude!.toStringAsFixed(4)}, ${order.longitude!.toStringAsFixed(4)}'
                    : '${order.deliveryAddress.city} · ${order.deliveryTime}',
                style: textTheme.bodySmall?.copyWith(color: kTextSecondary),
              ),
              const SizedBox(height: kPaddingSmall),
              const Divider(height: 1, color: kBorderColor),
              const SizedBox(height: kPaddingSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.items.length} '
                    'item${order.items.length == 1 ? '' : 's'}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: kTextSecondary,
                    ),
                  ),
                  Text(
                    'Rs ${order.total.toStringAsFixed(2)}',
                    style: textTheme.labelLarge?.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              if (showTrackButton) ...[
                const SizedBox(height: kPaddingSmall),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: onTrack ?? onTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kPrimaryColor,
                      side: const BorderSide(color: kPrimaryColor),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.location_on_outlined, size: 14),
                    label: const Text('Track Order'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dd = dt.day.toString().padLeft(2, '0');
    final mmm = months[dt.month - 1];
    return '$dd $mmm ${dt.year}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = _chipStyle(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  static (Color, Color, String) _chipStyle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return (
          const Color(0xFFFFF3E0),
          const Color(0xFFE65100),
          'Pending',
        );
      case OrderStatus.confirmed:
        return (
          const Color(0xFFE3F2FD),
          const Color(0xFF1565C0),
          'Accepted',
        );
      case OrderStatus.preparing:
        return (
          const Color(0xFFF3E5F5),
          const Color(0xFF6A1B9A),
          'Packed',
        );
      case OrderStatus.outForDelivery:
        return (
          const Color(0xFFE0F2F1),
          const Color(0xFF00695C),
          'Out for Delivery',
        );
      case OrderStatus.delivered:
        return (
          const Color(0xFFE8F5E9),
          const Color(0xFF2E7D32),
          'Delivered',
        );
      case OrderStatus.cancelled:
        return (
          const Color(0xFFFFEBEE),
          const Color(0xFFC62828),
          'Cancelled',
        );
    }
  }
}