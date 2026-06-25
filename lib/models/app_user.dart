// lib/models/app_user.dart
enum UserRole {
  customer,
  owner,
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phoneNumber;
  final String? region;
  final String? area;
  final String? avatarUrl;
  final bool isActive;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = UserRole.customer,
    this.phoneNumber,
    this.region,
    this.area,
    this.avatarUrl,
    this.isActive = true,
  });

  bool get isOwner => role == UserRole.owner;
  bool get isCustomer => role == UserRole.customer;

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? phoneNumber,
    String? region,
    String? area,
    String? avatarUrl,
    bool? isActive,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      region: region ?? this.region,
      area: area ?? this.area,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}