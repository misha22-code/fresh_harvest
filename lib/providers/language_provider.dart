import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isUrdu = false;

  bool get isUrdu => _isUrdu;

  void toggleLanguage() {
    _isUrdu = !_isUrdu;
    notifyListeners();
  }
}
