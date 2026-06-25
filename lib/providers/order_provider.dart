// lib/providers/order_provider.dart
import 'package:flutter/material.dart';
import 'package:fresh_harvest/models/order.dart';
import 'package:fresh_harvest/models/cart_item.dart';
import 'package:fresh_harvest/services/mock_data_service.dart';

class OrderProvider extends ChangeNotifier {
  final MockDataService _mockService = MockDataService.instance;
  
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  // ─── Get Orders for Vendor ──────────────────────────────────────────────

  Future<List<Order>> getOrdersForVendor(String vendorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _mockService.getOrdersForVendor(vendorId);
      return _orders;
    } catch (e) {
      print('Error loading orders: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrdersForVendor(String vendorId) async {
    await getOrdersForVendor(vendorId);
  }

  // ─── Get Orders for Customer ─────────────────────────────────────────────

  Future<List<Order>> getOrdersForCustomer(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await _mockService.getOrdersForCustomer(customerId);
      return _orders;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrdersForCustomer(String customerId) async {
    await getOrdersForCustomer(customerId);
  }

  // ─── Place Order ──────────────────────────────────────────────────────────

  Future<void> placeOrder(
    List<CartItem> items,
    Address address,
    String customerId,
    String customerName,
    String phoneNumber,
    String city,
    String deliveryTimeSlot, {
    String? deliveryNotes,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final order = await _mockService.createOrder(
        items,
        address,
        customerId,
        customerName,
        phoneNumber,
        city,
        deliveryTimeSlot,
        deliveryNotes: deliveryNotes,
        latitude: latitude,
        longitude: longitude,
      );
      await loadOrdersForCustomer(customerId);
    } catch (e) {
      rethrow;
    }
  }

  // ─── Update Order ─────────────────────────────────────────────────────────

  Future<void> updateOrder(Order order) async {
    try {
      await _mockService.updateOrder(order);
      
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = order;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating order: $e');
      rethrow;
    }
  }

  // ─── Update Order Status ─────────────────────────────────────────────────

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await _mockService.updateOrderStatus(orderId, newStatus);
      
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  // ─── Real-time Listener (Mock) ───────────────────────────────────────────

  void listenToOrdersRealtime(String vendorId) {
    // This is a mock - no real-time in mock version
    // Just load orders once
    loadOrdersForVendor(vendorId);
  }
}