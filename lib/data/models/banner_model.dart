// lib/data/models/banner_model.dart
class BannerModel {
  final String id;
  final String title;
  final String image;
  final String? link;
  final String type; // 'product', 'category', 'external'
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
    this.link,
    required this.type,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'link': link,
      'type': type,
      'isActive': isActive,
      'sortOrder': sortOrder,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      image: map['image'] ?? '',
      link: map['link'],
      type: map['type'] ?? 'external',
      isActive: map['isActive'] ?? true,
      sortOrder: map['sortOrder']?.toInt() ?? 0,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }
}

class OfferModel {
  final String id;
  final String title;
  final String description;
  final String image;
  final double discountPercentage;
  final double? maxDiscount;
  final String? couponCode;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> applicableCategories;
  final List<String> applicableProducts;
  final DateTime createdAt;
  final DateTime updatedAt;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.discountPercentage,
    this.maxDiscount,
    this.couponCode,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.applicableCategories,
    required this.applicableProducts,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'discountPercentage': discountPercentage,
      'maxDiscount': maxDiscount,
      'couponCode': couponCode,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'applicableCategories': applicableCategories,
      'applicableProducts': applicableProducts,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory OfferModel.fromMap(Map<String, dynamic> map) {
    return OfferModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      image: map['image'] ?? '',
      discountPercentage: map['discountPercentage']?.toDouble() ?? 0.0,
      maxDiscount: map['maxDiscount']?.toDouble(),
      couponCode: map['couponCode'],
      startDate: map['startDate']?.toDate() ?? DateTime.now(),
      endDate: map['endDate']?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      applicableCategories:
          List<String>.from(map['applicableCategories'] ?? []),
      applicableProducts: List<String>.from(map['applicableProducts'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  bool get isValid =>
      isActive &&
      DateTime.now().isAfter(startDate) &&
      DateTime.now().isBefore(endDate);
}

class CouponModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final double discountPercentage;
  final double? maxDiscount;
  final double? minOrderAmount;
  final int? maxUsage;
  final int currentUsage;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> applicableCategories;
  final List<String> applicableProducts;
  final DateTime createdAt;
  final DateTime updatedAt;

  CouponModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountPercentage,
    this.maxDiscount,
    this.minOrderAmount,
    this.maxUsage,
    required this.currentUsage,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.applicableCategories,
    required this.applicableProducts,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'discountPercentage': discountPercentage,
      'maxDiscount': maxDiscount,
      'minOrderAmount': minOrderAmount,
      'maxUsage': maxUsage,
      'currentUsage': currentUsage,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'applicableCategories': applicableCategories,
      'applicableProducts': applicableProducts,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CouponModel.fromMap(Map<String, dynamic> map) {
    return CouponModel(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      discountPercentage: map['discountPercentage']?.toDouble() ?? 0.0,
      maxDiscount: map['maxDiscount']?.toDouble(),
      minOrderAmount: map['minOrderAmount']?.toDouble(),
      maxUsage: map['maxUsage']?.toInt(),
      currentUsage: map['currentUsage']?.toInt() ?? 0,
      startDate: map['startDate']?.toDate() ?? DateTime.now(),
      endDate: map['endDate']?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
      applicableCategories:
          List<String>.from(map['applicableCategories'] ?? []),
      applicableProducts: List<String>.from(map['applicableProducts'] ?? []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  bool get isValid {
    if (!isActive) return false;
    if (DateTime.now().isBefore(startDate) || DateTime.now().isAfter(endDate))
      return false;
    if (maxUsage != null && currentUsage >= maxUsage!) return false;
    return true;
  }

  bool canApply(double orderAmount) {
    if (!isValid) return false;
    if (minOrderAmount != null && orderAmount < minOrderAmount!) return false;
    return true;
  }
}
