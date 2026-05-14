// lib/data/models/category_model.dart
class CategoryModel {
  final String id;
  final String name;
  final String image;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder']?.toInt() ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }
}

class SubCategoryModel {
  final String id;
  final String name;
  final String categoryId;
  final String image;
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.image,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'image': image,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory SubCategoryModel.fromMap(Map<String, dynamic> map) {
    return SubCategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      categoryId: map['categoryId'] ?? '',
      image: map['image'] ?? '',
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder']?.toInt() ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }
}
