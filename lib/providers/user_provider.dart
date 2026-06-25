// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import 'package:fresh_harvest/models/app_user.dart';
import 'package:fresh_harvest/services/mock_data_service.dart';

class UserProvider extends ChangeNotifier {
  List<AppUser> _users = [];
  List<AppUser> _filteredUsers = [];
  bool _isLoading = false;

  List<AppUser> get users => List.unmodifiable(_filteredUsers);
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    _users = List<AppUser>.from(
        await MockDataService.instance.getAllUsers());
    _filteredUsers = List.from(_users);

    _isLoading = false;
    notifyListeners();
  }

  void search(String query) {
    if (query.isEmpty) {
      _filteredUsers = List.from(_users);
    } else {
      final q = query.toLowerCase();
      _filteredUsers = _users
          .where((u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q))
          .toList();
    }
    notifyListeners();
  }

  Future<void> toggleUserActive(String userId) async {
    await MockDataService.instance.toggleUserActive(userId);
    final idx = _users.indexWhere((u) => u.id == userId);
    if (idx != -1) {
      _users[idx] = _users[idx].copyWith(isActive: !_users[idx].isActive);
      search('');
    }
  }
}