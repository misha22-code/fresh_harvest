// lib/screens/owner/owner_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fresh_harvest/models/order.dart';
import 'package:fresh_harvest/providers/auth_provider.dart';
import 'package:fresh_harvest/providers/order_provider.dart';
import 'package:fresh_harvest/config/app_routes.dart';

class OwnerOrdersScreen extends StatefulWidget {
  const OwnerOrdersScreen({super.key});

  @override
  State<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends State<OwnerOrdersScreen> {
  String _selectedFilter = 'All';
  bool _isLoading = true;
  List<Order> _orders = [];

  final List<String> _filters = [
    'All',
    'Pending',
    'Confirmed',
    'Packing',
    'Out for Delivery',
    'Delivered',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final ownerId = context.read<AuthProvider>().currentUser?.id ?? 'u2';
      final allOrders = await context.read<OrderProvider>().getOrdersForVendor(ownerId);
      setState(() {
        _orders = allOrders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Order> _getFilteredOrders() {
    if (_selectedFilter == 'All') return _orders;
    
    OrderStatus? status;
    switch (_selectedFilter) {
      case 'Pending':
        status = OrderStatus.pending;
        break;
      case 'Confirmed':
        status = OrderStatus.confirmed;
        break;
      case 'Packing':
        status = OrderStatus.preparing;
        break;
      case 'Out for Delivery':
        status = OrderStatus.outForDelivery;
        break;
      case 'Delivered':
        status = OrderStatus.delivered;
        break;
      case 'Cancelled':
        status = OrderStatus.cancelled;
        break;
    }
    
    return _orders.where((o) => o.status == status).toList();
  }

  Future<void> _updateOrderStatus(Order order, OrderStatus newStatus) async {
    try {
      final updatedOrder = order.copyWith(status: newStatus);
      await context.read<OrderProvider>().updateOrder(updatedOrder);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Order #${order.id} updated to ${_getStatusLabel(newStatus)}'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Packing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.amber;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.orange;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '📋 Order Management',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.black54),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Filter Chips ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedFilter = filter);
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: Colors.green.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.green.shade800 : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: isSelected
                        ? BorderSide(color: Colors.green.shade400, width: 1.5)
                        : const BorderSide(color: Colors.transparent),
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),

          // ─── Order List ──────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_rounded,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No orders found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Orders will appear here when customers place them',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadOrders,
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
                        onRefresh: _loadOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];
                            return _OrderCard(
                              order: order,
                              onStatusUpdate: _updateOrderStatus,
                              onViewDetails: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.orderTracking,
                                  arguments: order,
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Order Card ──────────────────────────────────────────────────────────

class _OrderCard extends StatefulWidget {
  const _OrderCard({
    required this.order,
    required this.onStatusUpdate,
    required this.onViewDetails,
  });

  final Order order;
  final Future<void> Function(Order, OrderStatus) onStatusUpdate;
  final VoidCallback onViewDetails;

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final statusColor = _getStatusColor(order.status);
    final statusLabel = _getStatusLabel(order.status);

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
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ─── Customer Info ──────────────────────────────────────────────
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
              const SizedBox(width: 16),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ─── Items ──────────────────────────────────────────────────────
          Wrap(
            spacing: 4,
            children: order.items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${item.quantity}x ${item.product.name}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // ─── Actions ────────────────────────────────────────────────────
          Row(
            children: [
              // Total
              Expanded(
                child: Text(
                  'Total: Rs ${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              
              // View Details Button
              TextButton.icon(
                onPressed: widget.onViewDetails,
                icon: const Icon(Icons.visibility_rounded, size: 16),
                label: const Text('Details'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
              
              // Status Update Dropdown
              if (order.status != OrderStatus.delivered && 
                  order.status != OrderStatus.cancelled)
                PopupMenuButton<OrderStatus>(
                  onSelected: (newStatus) {
                    widget.onStatusUpdate(order, newStatus);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Update',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: Colors.green.shade700,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    if (order.status == OrderStatus.pending)
                      const PopupMenuItem(
                        value: OrderStatus.confirmed,
                        child: Text('✅ Confirm Order'),
                      ),
                    if (order.status == OrderStatus.confirmed ||
                        order.status == OrderStatus.pending)
                      const PopupMenuItem(
                        value: OrderStatus.preparing,
                        child: Text('📦 Start Packing'),
                      ),
                    if (order.status == OrderStatus.preparing)
                      const PopupMenuItem(
                        value: OrderStatus.outForDelivery,
                        child: Text('🚚 Out for Delivery'),
                      ),
                    if (order.status == OrderStatus.outForDelivery)
                      const PopupMenuItem(
                        value: OrderStatus.delivered,
                        child: Text('✅ Mark Delivered'),
                      ),
                    const PopupMenuItem(
                      value: OrderStatus.cancelled,
                      child: Text('❌ Cancel Order'),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.amber;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.orange;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Packing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}