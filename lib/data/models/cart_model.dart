// lib/data/models/cart_model.dart
import 'product_model.dart';

class CartModel {
  final Map<String, CartItem> items;

  CartModel({
    required this.items,
  });

  CartModel.empty() : items = {};

  int get itemCount => items.length;

  int get totalQuantity =>
      items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      items.values.fold(0.0, (sum, item) => sum + item.total);

  double get discountAmount =>
      items.values.fold(0.0, (sum, item) => sum + item.discount);

  double get finalAmount => totalAmount - discountAmount;

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      items: Map<String, CartItem>.from(
        map['items']
                ?.map((key, value) => MapEntry(key, CartItem.fromMap(value))) ??
            {},
      ),
    );
  }

  CartModel copyWith({
    Map<String, CartItem>? items,
  }) {
    return CartModel(
      items: items ?? this.items,
    );
  }
}

class CartItem {
  final ProductModel product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get total => product.finalPrice * quantity;

  double get discount => product.hasDiscount
      ? (product.price - product.finalPrice) * quantity
      : 0.0;

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      product: ProductModel.fromMap(map['product'] ?? {}),
      quantity: map['quantity']?.toInt() ?? 0,
    );
  }

  CartItem copyWith({
    ProductModel? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
