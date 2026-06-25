// lib/models/notification.dart
import 'package:equatable/equatable.dart';

enum NotificationType {
  order,
  delivery,
  promotion,
  payment,
  general,
}

class Notification extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, String> payload;
  final DateTime timestamp;
  final bool isRead;

  const Notification({
    required this.id,
    required this.title,
    required this.body,
    this.type = NotificationType.general,
    this.payload = const {},
    required this.timestamp,
    this.isRead = false,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      payload: Map<String, String>.from(json['payload'] ?? {}),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  Notification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, String>? payload,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return Notification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  List<Object?> get props => [id, title, body, type, payload, timestamp, isRead];
}