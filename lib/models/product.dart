// lib/models/product.dart
class Product {
  final String id;
  final String name;
  final String urduName;
  final double price;
  final String unit;
  final int stockQuantity;
  final String imageUrl;
  final String vendorId;
  final bool isActive;
  final String categoryId;
  final String description;
  final String origin;
  final String quality;
  final String usage;

  Product({
    required this.id,
    required this.name,
    required this.urduName,
    required this.price,
    required this.unit,
    required this.stockQuantity,
    required this.imageUrl,
    required this.vendorId,
    this.isActive = true,
    this.categoryId = '',
    this.description = '',
    this.origin = '',
    this.quality = '',
    this.usage = '',
  });

  Product copyWith({
    String? id,
    String? name,
    String? urduName,
    double? price,
    String? unit,
    int? stockQuantity,
    String? imageUrl,
    String? vendorId,
    bool? isActive,
    String? categoryId,
    String? description,
    String? origin,
    String? quality,
    String? usage,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      urduName: urduName ?? this.urduName,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      vendorId: vendorId ?? this.vendorId,
      isActive: isActive ?? this.isActive,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      origin: origin ?? this.origin,
      quality: quality ?? this.quality,
      usage: usage ?? this.usage,
    );
  }
}