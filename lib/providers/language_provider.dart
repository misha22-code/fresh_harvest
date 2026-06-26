// lib/providers/language_provider.dart
import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isUrdu = false;

  bool get isUrdu => _isUrdu;

  void toggleLanguage() {
    _isUrdu = !_isUrdu;
    notifyListeners();
  }

  void setLanguage(String language) {
    if (language == 'ur') {
      _isUrdu = true;
    } else {
      _isUrdu = false;
    }
    notifyListeners();
  }
}