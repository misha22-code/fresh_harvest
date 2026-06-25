// Remove this import - it's not used
// import 'package:fresh_harvest/models/order.dart';

enum DeliveryStatus {
  assigned,
  pickedUp,
  inTransit,
  delivered,
  failed,
}

class DeliveryAssignment {
  final String id;
  final String orderId;
  final String personnelId;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryAddress;
  DeliveryStatus status;
  final String estimatedDeliveryTime;
  final DateTime assignedAt;
  DateTime? pickedUpAt;
  DateTime? deliveredAt;
  String? notes;

  DeliveryAssignment({
    required this.id,
    required this.orderId,
    required this.personnelId,
    this.customerName,
    this.customerPhone,
    this.deliveryAddress,
    required this.status,
    required this.estimatedDeliveryTime,
    required this.assignedAt,
    this.pickedUpAt,
    this.deliveredAt,
    this.notes,
  });

  DeliveryAssignment copyWith({
    String? id,
    String? orderId,
    String? personnelId,
    String? customerName,
    String? customerPhone,
    String? deliveryAddress,
    DeliveryStatus? status,
    String? estimatedDeliveryTime,
    DateTime? assignedAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
    String? notes,
  }) {
    return DeliveryAssignment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      personnelId: personnelId ?? this.personnelId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      status: status ?? this.status,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      assignedAt: assignedAt ?? this.assignedAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'personnelId': personnelId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'deliveryAddress': deliveryAddress,
      'status': status.name,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'assignedAt': assignedAt.toIso8601String(),
      'pickedUpAt': pickedUpAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'notes': notes,
    };
  }

  factory DeliveryAssignment.fromJson(Map<String, dynamic> json) {
    return DeliveryAssignment(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      personnelId: json['personnelId'] as String,
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      deliveryAddress: json['deliveryAddress'] as String?,
      status: DeliveryStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DeliveryStatus.assigned,
      ),
      estimatedDeliveryTime: json['estimatedDeliveryTime'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String),
      pickedUpAt: json['pickedUpAt'] != null
          ? DateTime.parse(json['pickedUpAt'] as String)
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }
}