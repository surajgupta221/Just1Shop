// lib/presentation/blocs/order/order_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/cart_model.dart';
import '../../../data/models/banner_model.dart';
import '../../../data/models/user_model.dart';

// Events
abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserOrders extends OrderEvent {
  final String userId;

  const LoadUserOrders(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateOrder extends OrderEvent {
  final CartModel cart;
  final UserModel user;
  final AddressModel deliveryAddress;
  final String paymentMethod;
  final CouponModel? coupon;

  const CreateOrder(
    this.cart,
    this.user,
    this.deliveryAddress,
    this.paymentMethod,
    this.coupon,
  );

  @override
  List<Object?> get props =>
      [cart, user, deliveryAddress, paymentMethod, coupon];
}

class LoadOrderDetails extends OrderEvent {
  final String orderId;

  const LoadOrderDetails(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class UpdateOrderStatus extends OrderEvent {
  final String orderId;
  final String status;
  final String updatedBy;

  const UpdateOrderStatus(this.orderId, this.status, this.updatedBy);

  @override
  List<Object?> get props => [orderId, status, updatedBy];
}

// States
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class UserOrdersLoaded extends OrderState {
  final List<OrderModel> orders;

  const UserOrdersLoaded(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderDetailsLoaded extends OrderState {
  final OrderModel order;

  const OrderDetailsLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCreated extends OrderState {
  final String orderId;

  const OrderCreated(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  OrderBloc(this._orderRepository) : super(OrderInitial()) {
    on<LoadUserOrders>(_onLoadUserOrders);
    on<CreateOrder>(_onCreateOrder);
    on<LoadOrderDetails>(_onLoadOrderDetails);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
  }

  void _onLoadUserOrders(LoadUserOrders event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      await emit.forEach(
        _orderRepository.getUserOrders(event.userId),
        onData: (List<OrderModel> orders) => UserOrdersLoaded(orders),
        onError: (error, stackTrace) => OrderError(error.toString()),
      );
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  void _onCreateOrder(CreateOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      // Calculate totals
      double totalAmount = event.cart.totalAmount;
      double discountAmount = event.cart.discountAmount;
      double deliveryCharge =
          totalAmount >= 500 ? 0 : 40; // Free delivery above ₹500

      // Apply coupon discount if valid
      if (event.coupon != null && event.coupon!.canApply(totalAmount)) {
        double couponDiscount =
            totalAmount * (event.coupon!.discountPercentage / 100);
        if (event.coupon!.maxDiscount != null) {
          couponDiscount = couponDiscount.clamp(0, event.coupon!.maxDiscount!);
        }
        discountAmount += couponDiscount;
      }

      double finalAmount = totalAmount + deliveryCharge - discountAmount;

      // Create order items
      List<OrderItem> orderItems = event.cart.items.values.map((cartItem) {
        return OrderItem(
          productId: cartItem.product.id,
          name: cartItem.product.name,
          price: cartItem.product.finalPrice,
          quantity: cartItem.quantity,
          image: cartItem.product.images.isNotEmpty
              ? cartItem.product.images[0]
              : '',
          unit: cartItem.product.unit,
        );
      }).toList();

      // Create order
      OrderModel order = OrderModel(
        id: '', // Will be set by repository
        userId: event.user.id,
        items: orderItems,
        totalAmount: totalAmount,
        discountAmount: discountAmount,
        deliveryCharge: deliveryCharge,
        finalAmount: finalAmount,
        paymentMethod: event.paymentMethod,
        paymentStatus: event.paymentMethod == 'cod' ? 'pending' : 'pending',
        paymentId: null,
        deliveryAddress: event.deliveryAddress,
        status: 'placed',
        deliveryBoyId: null,
        couponCode: event.coupon?.code,
        orderDate: DateTime.now(),
        deliveryDate: null,
        statusHistory: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final orderId = await _orderRepository.createOrder(order);
      emit(OrderCreated(orderId));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  void _onLoadOrderDetails(
      LoadOrderDetails event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await _orderRepository.getOrderById(event.orderId);
      if (order != null) {
        emit(OrderDetailsLoaded(order));
      } else {
        emit(const OrderError('Order not found'));
      }
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  void _onUpdateOrderStatus(
      UpdateOrderStatus event, Emitter<OrderState> emit) async {
    try {
      await _orderRepository.updateOrderStatus(
          event.orderId, event.status, event.updatedBy);
      // Reload order details if currently viewing this order
      if (state is OrderDetailsLoaded) {
        final currentOrder = (state as OrderDetailsLoaded).order;
        if (currentOrder.id == event.orderId) {
          add(LoadOrderDetails(event.orderId));
        }
      }
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
