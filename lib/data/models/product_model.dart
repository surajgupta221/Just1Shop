// lib/data/models/product_model.dart
class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> images;
  final String categoryId;
  final String unit;
  final int stock;
  final bool isActive;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.images,
    required this.categoryId,
    required this.unit,
    required this.stock,
    required this.isActive,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  double get finalPrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  double get discountPercentage => hasDiscount 
      ? ((price - discountPrice!) / price * 100) 
      : 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'images': images,
      'categoryId': categoryId,
      'unit': unit,
      'stock': stock,
      'isActive': isActive,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      discountPrice: map['discountPrice']?.toDouble(),
      images: List<String>.from(map['images'] ?? []),
      categoryId: map['categoryId'] ?? '',
      unit: map['unit'] ?? '',
      stock: map['stock']?.toInt() ?? 0,
      isActive: map['isActive'] ?? true,
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }
}
