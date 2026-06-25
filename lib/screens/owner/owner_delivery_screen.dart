// lib/screens/owner/owner_delivery_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_harvest/models/order.dart';
import 'package:fresh_harvest/providers/auth_provider.dart';
import 'package:fresh_harvest/providers/order_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class OwnerDeliveryScreen extends StatefulWidget {
  const OwnerDeliveryScreen({super.key});

  @override
  State<OwnerDeliveryScreen> createState() => _OwnerDeliveryScreenState();
}

class _OwnerDeliveryScreenState extends State<OwnerDeliveryScreen> {
  bool _isLoading = true;
  List<Order> _deliveryOrders = [];

  @override
  void initState() {
    super.initState();
    _loadDeliveryOrders();
  }

  Future<void> _loadDeliveryOrders() async {
    setState(() => _isLoading = true);
    try {
      final ownerId = context.read<AuthProvider>().currentUser?.id ?? 'u2';
      final allOrders = await context.read<OrderProvider>().getOrdersForVendor(ownerId);
      setState(() {
        _deliveryOrders = allOrders
            .where((o) => 
                o.status == OrderStatus.outForDelivery || 
                o.status == OrderStatus.preparing ||
                o.status == OrderStatus.confirmed)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateDeliveryStatus(Order order, OrderStatus newStatus) async {
    try {
      final updatedOrder = order.copyWith(status: newStatus);
      await context.read<OrderProvider>().updateOrder(updatedOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Delivery updated for Order #${order.id}'),
          backgroundColor: Colors.green,
        ),
      );
      _loadDeliveryOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openMaps(String address) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}'
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '🚚 Delivery Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black54),
            onPressed: _loadDeliveryOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deliveryOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delivery_dining_rounded,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No active deliveries',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Orders ready for delivery will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadDeliveryOrders,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDeliveryOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _deliveryOrders.length,
                    itemBuilder: (context, index) {
                      final order = _deliveryOrders[index];
                      return _DeliveryCard(
                        order: order,
                        onUpdateStatus: _updateDeliveryStatus,
                        onNavigate: () => _openMaps(order.deliveryAddress.formatted),
                      );
                    },
                  ),
                ),
    );
  }
}

// ─── Delivery Card ──────────────────────────────────────────────────────

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    required this.order,
    required this.onUpdateStatus,
    required this.onNavigate,
  });

  final Order order;
  final Future<void> Function(Order, OrderStatus) onUpdateStatus;
  final VoidCallback onNavigate;

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Packing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.orange;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ──────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${order.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusLabel(order.status),
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ─── Customer ────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.person_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                order.customerName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              const Icon(Icons.phone_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                order.phoneNumber,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // ─── Address ─────────────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.deliveryAddress.formatted,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ─── Order Items ────────────────────────────────────────────────
          Text(
            'Items: ${order.items.map((i) => '${i.quantity}x ${i.product.name}').join(', ')}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // ─── Actions ────────────────────────────────────────────────────
          Row(
            children: [
              // Navigate Button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: const Text('Navigate'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Status Update Button
              if (order.status != OrderStatus.delivered &&
                  order.status != OrderStatus.cancelled)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Update Delivery Status',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Divider(),
                              ListTile(
                                leading: const Icon(Icons.check_circle_rounded, color: Colors.blue),
                                title: const Text('Confirm'),
                                onTap: () {
                                  Navigator.pop(context);
                                  onUpdateStatus(order, OrderStatus.confirmed);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.inventory_2_rounded, color: Colors.orange),
                                title: const Text('Start Packing'),
                                onTap: () {
                                  Navigator.pop(context);
                                  onUpdateStatus(order, OrderStatus.preparing);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delivery_dining_rounded, color: Colors.purple),
                                title: const Text('Out for Delivery'),
                                onTap: () {
                                  Navigator.pop(context);
                                  onUpdateStatus(order, OrderStatus.outForDelivery);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.check_circle_rounded, color: Colors.green),
                                title: const Text('Delivered'),
                                onTap: () {
                                  Navigator.pop(context);
                                  onUpdateStatus(order, OrderStatus.delivered);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.cancel_rounded, color: Colors.red),
                                title: const Text('Cancel'),
                                onTap: () {
                                  Navigator.pop(context);
                                  onUpdateStatus(order, OrderStatus.cancelled);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.update_rounded, size: 16),
                    label: const Text('Update Status'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}