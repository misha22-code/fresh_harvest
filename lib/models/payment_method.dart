// lib/models/payment_method.dart
import 'package:flutter/material.dart';

enum PaymentMethod {
  cod,
  easypaisa,
  jazzcash,
}

extension PaymentMethodExtension on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cod:
        return 'Cash on Delivery';
      case PaymentMethod.easypaisa:
        return 'Easypaisa';
      case PaymentMethod.jazzcash:
        return 'JazzCash';
    }
  }

  String get value {
    switch (this) {
      case PaymentMethod.cod:
        return 'cod';
      case PaymentMethod.easypaisa:
        return 'easypaisa';
      case PaymentMethod.jazzcash:
        return 'jazzcash';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cod:
        return Icons.money_rounded;
      case PaymentMethod.easypaisa:
        return Icons.phone_android_rounded;
      case PaymentMethod.jazzcash:
        return Icons.phone_iphone_rounded;
    }
  }

  Color get color {
    switch (this) {
      case PaymentMethod.cod:
        return Colors.green;
      case PaymentMethod.easypaisa:
        return Colors.orange;
      case PaymentMethod.jazzcash:
        return Colors.red;
    }
  }
}