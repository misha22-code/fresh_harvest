// lib/models/order.dart
import 'package:fresh_harvest/models/product.dart';

// ─── ORDER STATUS ENUM ──────────────────────────────────────────────────────
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  outForDelivery,
  delivered,
  cancelled,
}

// ─── DELIVERY STATUS ENUM ──────────────────────────────────────────────────
enum DeliveryStatus {
  pending,
  pickedUp,
  inTransit,
  delivered,
  failed,
}

// ─── ADDRESS CLASS ──────────────────────────────────────────────────────────
class Address {
  final String street;
  final String city;
  final String state;
  final String postalCode;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
  });

  String get formatted => '$street, $city, $state - $postalCode';
}

// ─── ORDER ITEM CLASS ──────────────────────────────────────────────────────
class OrderItem {
  final Product product;
  final int quantity;
  final double price;

  OrderItem({
    required this.product,
    required this.quantity,
    required this.price,
  });

  double get lineTotal => price * quantity;
}

// ─── ORDER CLASS ────────────────────────────────────────────────────────────
class Order {
  final String id;
  final String customerId;
  final String vendorId;
  final String? deliveryPersonnelId;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final DeliveryStatus? deliveryStatus;
  final Address deliveryAddress;
  final String customerName;
  final String phoneNumber;
  final String deliveryArea;
  final String deliveryTime;
  final String? deliveryNotes;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  final String paymentMethod;

  Order({
    required this.id,
    required this.customerId,
    required this.vendorId,
    this.deliveryPersonnelId,
    required this.items,
    required this.total,
    required this.status,
    this.deliveryStatus,
    required this.deliveryAddress,
    required this.customerName,
    required this.phoneNumber,
    required this.deliveryArea,
    required this.deliveryTime,
    this.deliveryNotes,
    this.latitude,
    this.longitude,
    DateTime? createdAt,
    this.paymentMethod = 'cod',
  }) : createdAt = createdAt ?? DateTime.now();

  Order copyWith({
    String? id,
    String? customerId,
    String? vendorId,
    String? deliveryPersonnelId,
    List<OrderItem>? items,
    double? total,
    OrderStatus? status,
    DeliveryStatus? deliveryStatus,
    Address? deliveryAddress,
    String? customerName,
    String? phoneNumber,
    String? deliveryArea,
    String? deliveryTime,
    String? deliveryNotes,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    String? paymentMethod,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      vendorId: vendorId ?? this.vendorId,
      deliveryPersonnelId: deliveryPersonnelId ?? this.deliveryPersonnelId,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      customerName: customerName ?? this.customerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      deliveryArea: deliveryArea ?? this.deliveryArea,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}