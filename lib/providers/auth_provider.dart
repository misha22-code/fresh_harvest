// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:fresh_harvest/models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  UserRole? get currentRole => _currentUser?.role;

  AuthProvider() {
    restoreSession();
  }

  // ─── Login Methods ────────────────────────────────────────────────────────

  void login(AppUser user) {
    _currentUser = user;
    _isAuthenticated = true;
    notifyListeners();
  }

  void signInAsOwner() {
    _currentUser = AppUser(
      id: 'u2',
      name: 'Store Owner',
      email: 'owner@fresh.com',
      role: UserRole.owner,
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  void autoLoginAsCustomer() {
    _currentUser = AppUser(
      id: 'u3',
      name: 'Customer',
      email: 'customer@fresh.com',
      role: UserRole.customer,
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  // ─── Logout ──────────────────────────────────────────────────────────────

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // ✅ signOut method for compatibility
  void signOut() {
    logout();
  }

  void restoreSession() {
    // Auto-login as customer for demo
    if (_currentUser == null) {
      autoLoginAsCustomer();
    }
  }
}