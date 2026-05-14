// lib/data/repositories/product_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/banner_model.dart';
import '../../core/services/firebase_service.dart';

class ProductRepository {
  ProductRepository();

  // Products
  Stream<List<ProductModel>> getProducts() {
    return FirebaseService.productsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ProductModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<ProductModel>> searchProducts(String query) {
    return FirebaseService.productsCollection
        .where('isActive', isEqualTo: true)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ProductModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc =
          await FirebaseService.productsCollection.doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  // Categories
  Stream<List<CategoryModel>> getCategories() {
    return FirebaseService.firestore
        .collection('categories')
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CategoryModel.fromMap(doc.data()))
            .toList());
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    try {
      QuerySnapshot snapshot = await FirebaseService.productsCollection
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
              (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw e;
    }
  }

  // Banners
  Stream<List<BannerModel>> getBanners() {
    return FirebaseService.firestore
        .collection('banners')
        .where('isActive', isEqualTo: true)
        .orderBy('sortOrder')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BannerModel.fromMap(doc.data()))
            .toList());
  }

  // Offers
  Stream<List<OfferModel>> getOffers() {
    return FirebaseService.firestore
        .collection('offers')
        .where('isActive', isEqualTo: true)
        .where('startDate', isLessThanOrEqualTo: DateTime.now())
        .where('endDate', isGreaterThanOrEqualTo: DateTime.now())
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OfferModel.fromMap(doc.data()))
            .toList());
  }

  // Coupons
  Future<CouponModel?> getCouponByCode(String code) async {
    try {
      QuerySnapshot snapshot = await FirebaseService.firestore
          .collection('coupons')
          .where('code', isEqualTo: code.toUpperCase())
          .where('isActive', isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return CouponModel.fromMap(
            snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw e;
    }
  }
}
