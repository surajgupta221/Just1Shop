// lib/presentation/customer/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/cart/cart_bloc.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/order/order_bloc.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/cart_model.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/helpers.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'cod';
  AddressModel? _selectedAddress;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/order-confirmation',
              (route) => false,
              arguments: state.orderId,
            );
          } else if (state is OrderError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState is CartLoaded && cartState.cart.itemCount > 0) {
                return _buildCheckoutContent(context, cartState.cart);
              }
              return const Center(child: Text('Your cart is empty'));
            },
          );
        },
      ),
    );
  }

  Widget _buildCheckoutContent(BuildContext context, CartModel cart) {
    final deliveryCharge = cart.totalAmount >= 500 ? 0.0 : 40.0;
    final finalAmount = cart.totalAmount + deliveryCharge - cart.discountAmount;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated && authState.userProfile != null) {
          final user = authState.userProfile!;
          _selectedAddress ??=
              user.addresses.isNotEmpty ? user.addresses.first : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Address
                _buildSectionTitle('Delivery Address'),
                _buildAddressSection(user),

                const SizedBox(height: 24),

                // Order Items
                _buildSectionTitle('Order Items'),
                _buildOrderItems(cart),

                const SizedBox(height: 24),

                // Payment Method
                _buildSectionTitle('Payment Method'),
                _buildPaymentMethodSection(),

                const SizedBox(height: 24),

                // Bill Details
                _buildSectionTitle('Bill Details'),
                _buildBillDetails(cart, deliveryCharge.toDouble(), finalAmount),

                const SizedBox(height: 32),

                // Place Order Button
                CustomButton(
                  text: 'Place Order',
                  isLoading: _isLoading,
                  onPressed: _selectedAddress != null
                      ? () => _placeOrder(context, cart, user)
                      : null,
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('Please login to continue'));
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAddressSection(UserModel user) {
    if (user.addresses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.location_off, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              const Text('No delivery address found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/add-address'),
                child: const Text('Add Address'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Deliver to',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/address'),
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_selectedAddress != null) ...[
              Text(
                _selectedAddress!.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(_selectedAddress!.address),
              Text(
                  '${_selectedAddress!.landmark}, ${_selectedAddress!.pincode}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(CartModel cart) {
    return Card(
      child: Column(
        children: cart.items.values.map((item) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.product.images.isNotEmpty
                        ? item.product.images[0]
                        : '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${item.quantity} ${item.product.unit} × ${Helpers.formatCurrency(item.product.finalPrice)}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  Helpers.formatCurrency(item.total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Card(
      child: Column(
        children: [
          _buildPaymentOption('Cash on Delivery', 'cod', Icons.money),
          const Divider(height: 1),
          _buildPaymentOption('Online Payment', 'online', Icons.credit_card),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, String value, IconData icon) {
    return RadioListTile<String>(
      title: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      value: value,
      groupValue: _paymentMethod,
      onChanged: (newValue) {
        setState(() => _paymentMethod = newValue!);
      },
    );
  }

  Widget _buildBillDetails(
      CartModel cart, double deliveryCharge, double finalAmount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBillRow('Subtotal', Helpers.formatCurrency(cart.totalAmount)),
            if (cart.discountAmount > 0)
              _buildBillRow(
                  'Discount', '-${Helpers.formatCurrency(cart.discountAmount)}',
                  isDiscount: true),
            _buildBillRow(
                'Delivery Charge',
                deliveryCharge == 0
                    ? 'FREE'
                    : Helpers.formatCurrency(deliveryCharge)),
            const Divider(),
            _buildBillRow('Total', Helpers.formatCurrency(finalAmount),
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBillRow(String label, String amount,
      {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount ? Colors.red : Colors.black,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isDiscount
                  ? Colors.red
                  : (isTotal ? Colors.green : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _placeOrder(BuildContext context, CartModel cart, UserModel user) {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() => _isLoading = true);
    context.read<OrderBloc>().add(
          CreateOrder(cart, user, _selectedAddress!, _paymentMethod, null),
        );
  }
}
