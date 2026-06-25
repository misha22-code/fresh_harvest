import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fresh_harvest/models/order.dart';
import 'package:fresh_harvest/models/notification.dart' as model;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Notification service for handling:
/// - Local notifications
/// - Push notifications (FCM)
/// - In-app notifications
/// - Notification storage
/// 
/// TODO: Integrate with:
/// - firebase_messaging: ^14.6.5
/// - flutter_local_notifications: ^15.1.1
class NotificationService {
  // ── Singleton Pattern ──────────────────────────────────────────────────────
  
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // ── Constants ──────────────────────────────────────────────────────────────
  
  static const String _notificationsKey = 'notifications';
  static const int _maxStoredNotifications = 100;

  // ── State ──────────────────────────────────────────────────────────────────
  
  bool _isInitialized = false;
  final List<model.Notification> _notifications = [];
  final StreamController<model.Notification> _notificationStreamController =
      StreamController<model.Notification>.broadcast();

  // ── Getters ─────────────────────────────────────────────────────────────────
  
  bool get isInitialized => _isInitialized;
  List<model.Notification> get notifications => List.unmodifiable(_notifications);
  Stream<model.Notification> get notificationStream => _notificationStreamController.stream;

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Initialize the notification service
  /// 
  /// Sets up:
  /// - Local notification channels (Android)
  /// - FCM messaging
  /// - Permission handling
  /// - Notification click handlers
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load stored notifications
      await _loadNotifications();

      // TODO: Initialize flutter_local_notifications
      // const AndroidInitializationSettings initializationSettingsAndroid =
      //     AndroidInitializationSettings('@mipmap/ic_launcher');
      // const DarwinInitializationSettings initializationSettingsIOS =
      //     DarwinInitializationSettings();
      // const InitializationSettings initializationSettings =
      //     InitializationSettings(
      //       android: initializationSettingsAndroid,
      //       iOS: initializationSettingsIOS,
      //     );
      // await _localNotifications.initialize(
      //   initializationSettings,
      //   onDidReceiveNotificationResponse: _handleNotificationTap,
      // );

      // TODO: Initialize Firebase Messaging
      // _fcm = FirebaseMessaging.instance;
      // await _fcm!.requestPermission();
      // _setupFCMListeners();

      _isInitialized = true;
      debugPrint('✅ Notification Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Notification Service initialization failed: $e');
    }
  }

  // ── Local Notifications ────────────────────────────────────────────────────

  /// Show a local notification
  /// 
  /// [title] - Notification title
  /// [body] - Notification body
  /// [payload] - Additional data (e.g., order ID)
  /// [channelId] - Notification channel (Android)
  Future<void> showNotification({
    required String title,
    required String body,
    Map<String, String>? payload,
    String channelId = 'default',
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Notification service not initialized');
      return;
    }

    try {
      // Create notification object
      final notification = model.Notification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        type: _getNotificationType(title, body),
        payload: payload ?? {},
        timestamp: DateTime.now(),
        isRead: false,
      );

      // Store notification
      await _storeNotification(notification);

      // Emit to stream
      _notificationStreamController.add(notification);

      // TODO: Show local notification
      // const AndroidNotificationDetails androidPlatformChannelSpecifics =
      //     AndroidNotificationDetails(
      //       channelId,
      //       'Fresh Harvest Notifications',
      //       importance: Importance.max,
      //       priority: Priority.high,
      //       icon: '@mipmap/ic_launcher',
      //     );
      // const DarwinNotificationDetails iosPlatformChannelSpecifics =
      //     DarwinNotificationDetails();
      // const NotificationDetails platformChannelSpecifics =
      //     NotificationDetails(
      //       android: androidPlatformChannelSpecifics,
      //       iOS: iosPlatformChannelSpecifics,
      //     );
      // await _localNotifications!.show(
      //   DateTime.now().millisecondsSinceEpoch ~/ 1000,
      //   title,
      //   body,
      //   platformChannelSpecifics,
      //   payload: jsonEncode(payload),
      // );

      debugPrint('📢 Notification shown: $title');
    } catch (e) {
      debugPrint('❌ Failed to show notification: $e');
    }
  }

  /// Show order status notification
  Future<void> showOrderNotification(Order order, String status) async {
    final title = 'Order #${order.id}';
    String body;

    switch (status) {
      case 'confirmed':
        body = 'Your order has been confirmed! ✅';
        break;
      case 'preparing':
        body = 'Your order is being prepared 🍳';
        break;
      case 'outForDelivery':
        body = 'Your order is out for delivery 🚚';
        break;
      case 'delivered':
        body = 'Your order has been delivered 📦';
        break;
      case 'cancelled':
        body = 'Your order has been cancelled ❌';
        break;
      default:
        body = 'Your order status has been updated';
    }

    await showNotification(
      title: title,
      body: body,
      payload: {
        'orderId': order.id,
        'status': status,
      },
      channelId: 'orders',
    );
  }

  /// Show new order notification for vendors
  Future<void> showNewOrderNotification(Order order) async {
    await showNotification(
      title: '📦 New Order!',
      body: 'New order from ${order.customerName} - PKR ${order.total.toStringAsFixed(0)}',
      payload: {
        'orderId': order.id,
        'type': 'new_order',
      },
      channelId: 'orders',
    );
  }

  // ── FCM Push Notifications ─────────────────────────────────────────────────

  /// Setup Firebase Cloud Messaging listeners
  /// 
  /// TODO: Implement FCM message handling
  void _setupFCMListeners() {
    // TODO: Implement FCM listeners
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   _handleForegroundMessage(message);
    // });
    // FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   _handleMessageTap(message);
    // });
  }

  /// Handle foreground messages (app is open)
  /// 
  /// TODO: Implement foreground message handling
  void _handleForegroundMessage(dynamic message) {
    // Implement foreground handling
    debugPrint('📱 Foreground message received: $message');
  }

  /// Handle background messages (app is closed/minimized)
  /// 
  /// TODO: Implement background message handling
  static Future<void> _handleBackgroundMessage(dynamic message) async {
    // Implement background handling
    debugPrint('📱 Background message received: $message');
  }

  /// Handle notification tap (user clicks on notification)
  /// 
  /// TODO: Implement notification tap handling
  void _handleMessageTap(dynamic message) {
    // Navigate to appropriate screen based on payload
    debugPrint('🔔 Notification tapped: $message');
  }

  /// Handle local notification tap
  void _handleNotificationTap(dynamic response) {
    // Handle notification tap
    debugPrint('🔔 Local notification tapped: $response');
  }

  // ── Notification Storage ──────────────────────────────────────────────────

  /// Store notification in local storage
  Future<void> _storeNotification(model.Notification notification) async {
    try {
      _notifications.insert(0, notification);
      
      // Limit storage
      if (_notifications.length > _maxStoredNotifications) {
        _notifications.removeLast();
      }

      await _saveNotifications();
    } catch (e) {
      debugPrint('❌ Failed to store notification: $e');
    }
  }

  /// Save notifications to SharedPreferences
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _notifications.map((n) => n.toJson()).toList();
      await prefs.setString(_notificationsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('❌ Failed to save notifications: $e');
    }
  }

  /// Load notifications from SharedPreferences
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_notificationsKey);
      if (jsonString == null) return;

      final jsonList = jsonDecode(jsonString) as List;
      _notifications.clear();
      _notifications.addAll(
        jsonList.map((json) => model.Notification.fromJson(json)).toList(),
      );
    } catch (e) {
      debugPrint('❌ Failed to load notifications: $e');
    }
  }

  // ── Notification Management ──────────────────────────────────────────────

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final notification = _notifications[index];
      _notifications[index] = notification.copyWith(isRead: true);
      await _saveNotifications();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (var i = 0; i < _notifications.length; i++) {
      final notification = _notifications[i];
      _notifications[i] = notification.copyWith(isRead: true);
    }
    await _saveNotifications();
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveNotifications();
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    _notifications.clear();
    await _saveNotifications();
  }

  /// Get unread notification count
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }

  // ── Helper Methods ──────────────────────────────────────────────────────────

  /// Determine notification type based on content
  model.NotificationType _getNotificationType(String title, String body) {
    if (title.contains('Order') || body.contains('order')) {
      return model.NotificationType.order;
    } else if (title.contains('Delivery') || body.contains('delivery')) {
      return model.NotificationType.delivery;
    } else if (title.contains('Promo') || body.contains('offer')) {
      return model.NotificationType.promotion;
    } else if (title.contains('Payment') || body.contains('payment')) {
      return model.NotificationType.payment;
    }
    return model.NotificationType.general;
  }

  // ── Cleanup ─────────────────────────────────────────────────────────────────

  /// Dispose of resources
  void dispose() {
    _notificationStreamController.close();
  }
}

// ─── Extension ────────────────────────────────────────────────────────────────

extension NotificationServiceExtension on BuildContext {
  NotificationService get notifications => NotificationService();
}