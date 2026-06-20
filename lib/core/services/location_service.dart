// lib/core/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters
  Future<bool> get isLocationServiceEnabled =>
      Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> get checkPermission =>
      Geolocator.checkPermission();

  // Request location permission
  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current position
  Future<Position?> getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ Location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Location permissions are permanently denied');
        Geolocator.openLocationSettings();
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('❌ Error getting position: $e');
      return null;
    }
  }

  // Stream current position updates
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  // Delivery boy shares live location
  Future<void> shareLiveLocation({
    required String deliveryBoyId,
    required String orderId,
  }) async {
    try {
      final positionStream = getPositionStream();

      positionStream.listen((Position position) {
        _updateDeliveryLocation(
          deliveryBoyId: deliveryBoyId,
          orderId: orderId,
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
        );
      });
    } catch (e) {
      print('❌ Error sharing location: $e');
    }
  }

  // Update delivery location in Firestore
  Future<void> _updateDeliveryLocation({
    required String deliveryBoyId,
    required String orderId,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    try {
      // Update delivery boy's current location
      await _firestore.collection('delivery_partners').doc(deliveryBoyId).set({
        'currentLatitude': latitude,
        'currentLongitude': longitude,
        'accuracy': accuracy,
        'lastUpdateTime': DateTime.now(),
        'isOnline': true,
      }, SetOptions(merge: true));

      // Update order's delivery tracking
      await _firestore.collection('orders').doc(orderId).set({
        'deliveryLocation': {
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy,
          'timestamp': DateTime.now(),
        }
      }, SetOptions(merge: true));

      print('✅ Location updated for order: $orderId');
    } catch (e) {
      print('❌ Error updating location: $e');
    }
  }

  // Get delivery boy's current location
  Future<Map<String, dynamic>?> getDeliveryBoyLocation(
      String deliveryBoyId) async {
    try {
      final doc = await _firestore
          .collection('delivery_partners')
          .doc(deliveryBoyId)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Error getting delivery boy location: $e');
      return null;
    }
  }

  // Stop sharing location
  Future<void> stopSharingLocation(String deliveryBoyId) async {
    try {
      await _firestore.collection('delivery_partners').doc(deliveryBoyId).set({
        'isOnline': false,
        'lastUpdateTime': DateTime.now(),
      }, SetOptions(merge: true));

      print('✅ Stopped sharing location');
    } catch (e) {
      print('❌ Error stopping location: $e');
    }
  }

  // Calculate distance between two coordinates (in km)
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert to km
  }

  // Calculate ETA (estimated time of arrival)
  static String calculateETA(double distanceKm, {double speedKmh = 30}) {
    final minutes = ((distanceKm / speedKmh) * 60).toInt();
    if (minutes < 1) return 'Less than 1 min';
    if (minutes == 1) return '1 min';
    if (minutes < 60) return '$minutes mins';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }
}
