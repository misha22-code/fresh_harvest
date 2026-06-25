// lib/models/delivery_address.dart
class DeliveryAddress {
  final String id;
  final String label;
  final String street;
  final String city;
  final String area;
  final String? landmark;
  final String formatted;
  final double latitude;
  final double longitude;

  DeliveryAddress({
    required this.id,
    required this.label,
    required this.street,
    required this.city,
    required this.area,
    this.landmark,
    required this.formatted,
    required this.latitude,
    required this.longitude,
  });

  DeliveryAddress copyWith({
    String? id,
    String? label,
    String? street,
    String? city,
    String? area,
    String? landmark,
    String? formatted,
    double? latitude,
    double? longitude,
  }) {
    return DeliveryAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      street: street ?? this.street,
      city: city ?? this.city,
      area: area ?? this.area,
      landmark: landmark ?? this.landmark,
      formatted: formatted ?? this.formatted,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'street': street,
      'city': city,
      'area': area,
      'landmark': landmark,
      'formatted': formatted,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      id: json['id'] as String,
      label: json['label'] as String,
      street: json['street'] as String,
      city: json['city'] as String,
      area: json['area'] as String,
      landmark: json['landmark'] as String?,
      formatted: json['formatted'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }
}