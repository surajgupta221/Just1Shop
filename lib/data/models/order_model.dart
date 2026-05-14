// lib/data/models/order_model.dart
import 'user_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final double discountAmount;
  final double deliveryCharge;
  final double finalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String? paymentId;
  final AddressModel deliveryAddress;
  final String status;
  final String? deliveryBoyId;
  final String? couponCode;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final List<OrderStatusHistory> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.discountAmount,
    required this.deliveryCharge,
    required this.finalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentId,
    required this.deliveryAddress,
    required this.status,
    this.deliveryBoyId,
    this.couponCode,
    required this.orderDate,
    this.deliveryDate,
    required this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((x) => x.toMap()).toList(),
      'totalAmount': totalAmount,
      'discountAmount': discountAmount,
      'deliveryCharge': deliveryCharge,
      'finalAmount': finalAmount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
      'deliveryAddress': deliveryAddress.toMap(),
      'status': status,
      'deliveryBoyId': deliveryBoyId,
      'couponCode': couponCode,
      'orderDate': orderDate,
      'deliveryDate': deliveryDate,
      'statusHistory': statusHistory.map((x) => x.toMap()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      items: List<OrderItem>.from(
          map['items']?.map((x) => OrderItem.fromMap(x)) ?? []),
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      discountAmount: map['discountAmount']?.toDouble() ?? 0.0,
      deliveryCharge: map['deliveryCharge']?.toDouble() ?? 0.0,
      finalAmount: map['finalAmount']?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? 'cod',
      paymentStatus: map['paymentStatus'] ?? 'pending',
      paymentId: map['paymentId'],
      deliveryAddress: AddressModel.fromMap(map['deliveryAddress'] ?? {}),
      status: map['status'] ?? 'placed',
      deliveryBoyId: map['deliveryBoyId'],
      couponCode: map['couponCode'],
      orderDate: map['orderDate']?.toDate() ?? DateTime.now(),
      deliveryDate: map['deliveryDate']?.toDate(),
      statusHistory: List<OrderStatusHistory>.from(
          map['statusHistory']?.map((x) => OrderStatusHistory.fromMap(x)) ??
              []),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }
}

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String image;
  final String unit;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
      'unit': unit,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toInt() ?? 0,
      image: map['image'] ?? '',
      unit: map['unit'] ?? '',
    );
  }

  double get total => price * quantity;
}

class OrderStatusHistory {
  final String status;
  final DateTime timestamp;
  final String updatedBy;

  OrderStatusHistory({
    required this.status,
    required this.timestamp,
    required this.updatedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'timestamp': timestamp,
      'updatedBy': updatedBy,
    };
  }

  factory OrderStatusHistory.fromMap(Map<String, dynamic> map) {
    return OrderStatusHistory(
      status: map['status'] ?? '',
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
      updatedBy: map['updatedBy'] ?? '',
    );
  }
}
