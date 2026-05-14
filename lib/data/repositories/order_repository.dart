// lib/data/repositories/order_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../../core/services/firebase_service.dart';

class OrderRepository {
  OrderRepository();

  Future<String> createOrder(OrderModel order) async {
    try {
      DocumentReference docRef = FirebaseService.ordersCollection.doc();
      OrderModel orderWithId = OrderModel(
        id: docRef.id,
        userId: order.userId,
        items: order.items,
        totalAmount: order.totalAmount,
        discountAmount: order.discountAmount,
        deliveryCharge: order.deliveryCharge,
        finalAmount: order.finalAmount,
        paymentMethod: order.paymentMethod,
        paymentStatus: order.paymentStatus,
        paymentId: order.paymentId,
        deliveryAddress: order.deliveryAddress,
        status: order.status,
        deliveryBoyId: order.deliveryBoyId,
        couponCode: order.couponCode,
        orderDate: order.orderDate,
        deliveryDate: order.deliveryDate,
        statusHistory: [
          OrderStatusHistory(
            status: order.status,
            timestamp: DateTime.now(),
            updatedBy: order.userId,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(orderWithId.toMap());
      return docRef.id;
    } catch (e) {
      throw e;
    }
  }

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return FirebaseService.ordersCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
                (doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc =
          await FirebaseService.ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateOrderStatus(
      String orderId, String status, String updatedBy) async {
    try {
      await FirebaseService.ordersCollection.doc(orderId).update({
        'status': status,
        'updatedAt': DateTime.now(),
        'statusHistory': FieldValue.arrayUnion([
          {
            'status': status,
            'timestamp': DateTime.now(),
            'updatedBy': updatedBy,
          }
        ]),
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> updatePaymentStatus(
      String orderId, String paymentStatus, String? paymentId) async {
    try {
      await FirebaseService.ordersCollection.doc(orderId).update({
        'paymentStatus': paymentStatus,
        'paymentId': paymentId,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw e;
    }
  }

  // Admin methods
  Stream<List<OrderModel>> getAllOrders() {
    return FirebaseService.ordersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map(
                (doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> assignDeliveryBoy(String orderId, String deliveryBoyId) async {
    try {
      await FirebaseService.ordersCollection.doc(orderId).update({
        'deliveryBoyId': deliveryBoyId,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw e;
    }
  }
}
