// lib/presentation/blocs/cart/cart_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/cart_model.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final ProductModel product;
  final int quantity;

  const AddToCart(this.product, this.quantity);

  @override
  List<Object?> get props => [product, quantity];
}

class UpdateCartItem extends CartEvent {
  final String productId;
  final int quantity;

  const UpdateCartItem(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

class RemoveFromCart extends CartEvent {
  final String productId;

  const RemoveFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearCart extends CartEvent {}

// States
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final CartModel cart;

  const CartLoaded(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CartBloc extends Bloc<CartEvent, CartState> {
  CartModel _cart = CartModel.empty();

  CartBloc() : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItem>(_onUpdateCartItem);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
  }

  void _onLoadCart(LoadCart event, Emitter<CartState> emit) {
    emit(CartLoaded(_cart));
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final existingQuantity = _cart.items[event.product.id]?.quantity ?? 0;
    final newQuantity = existingQuantity + event.quantity;

    final cartItem = CartItem(
      product: event.product,
      quantity: newQuantity,
    );

    final updatedItems = Map<String, CartItem>.from(_cart.items);
    updatedItems[event.product.id] = cartItem;

    _cart = _cart.copyWith(items: updatedItems);
    emit(CartLoaded(_cart));
  }

  void _onUpdateCartItem(UpdateCartItem event, Emitter<CartState> emit) {
    if (event.quantity <= 0) {
      add(RemoveFromCart(event.productId));
      return;
    }

    final existingItem = _cart.items[event.productId];
    if (existingItem != null) {
      final updatedItem = existingItem.copyWith(quantity: event.quantity);
      final updatedItems = Map<String, CartItem>.from(_cart.items);
      updatedItems[event.productId] = updatedItem;

      _cart = _cart.copyWith(items: updatedItems);
      emit(CartLoaded(_cart));
    }
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final updatedItems = Map<String, CartItem>.from(_cart.items);
    updatedItems.remove(event.productId);

    _cart = _cart.copyWith(items: updatedItems);
    emit(CartLoaded(_cart));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    _cart = CartModel.empty();
    emit(CartLoaded(_cart));
  }
}
