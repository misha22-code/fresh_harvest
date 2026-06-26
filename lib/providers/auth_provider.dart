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

  // ─── Owner Login ─────────────────────────────────────────────────────────

  void signInAsOwner() {
    _currentUser = AppUser(
      id: 'owner_123',
      name: 'Store Owner',
      email: 'owner@fresh.com',
      role: UserRole.owner,
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  // ─── Customer Auto Login ────────────────────────────────────────────────

  void autoLoginAsCustomer() {
    _currentUser = AppUser(
      id: 'customer_123',
      name: 'Guest User',
      email: 'guest@fresh.com',
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

  void signOut() {
    logout();
  }

  // ─── Session Restore ────────────────────────────────────────────────────

  void restoreSession() {
    // ✅ Auto-login as customer by default
    if (_currentUser == null) {
      autoLoginAsCustomer();
    }
  }

  // ─── Check if User is Owner ─────────────────────────────────────────────

  bool get isOwner => _currentUser?.isOwner ?? false;
}