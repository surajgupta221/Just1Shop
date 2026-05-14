// lib/core/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Getters
  static FirebaseFirestore get firestore => _firestore;
  static FirebaseAuth get auth => _auth;
  static FirebaseStorage get storage => _storage;
  static FirebaseMessaging get messaging => _messaging;
  
  // Collections
  static CollectionReference get usersCollection => _firestore.collection('users');
  static CollectionReference get productsCollection => _firestore.collection('products');
  static CollectionReference get categoriesCollection => _firestore.collection('categories');
  static CollectionReference get ordersCollection => _firestore.collection('orders');
  static CollectionReference get bannersCollection => _firestore.collection('banners');
  static CollectionReference get couponsCollection => _firestore.collection('coupons');
}
