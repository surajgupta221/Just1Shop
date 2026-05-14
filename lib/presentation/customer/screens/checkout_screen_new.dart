// lib/presentation/customer/screens/checkout_screen_new.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../data/models/cart_model.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/order/order_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';

class CheckoutScreenModern extends StatefulWidget {
  const CheckoutScreenModern({Key? key}) : super(key: key);

  @override
  State<CheckoutScreenModern> createState() => _CheckoutScreenModernState();
}

class _CheckoutScreenModernState extends State<CheckoutScreenModern> {
  String _paymentMethod = 'cod';
  dynamic _selectedAddress;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        title: Text('Checkout', style: UITextStyles.headlineLarge),
        backgroundColor: UIConstants.surfaceColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: UIConstants.backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          ),
        ),
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
              SnackBar(
                content: Text(state.message),
                backgroundColor: UIConstants.errorColor,
              ),
            );
          }
        },
        builder: (context, orderState) {
          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              if (cartState is CartLoaded && cartState.cart.itemCount > 0) {
                return _buildCheckoutContent(context, cartState.cart);
              }
              return Center(
                child: Text(
                  'Your cart is empty',
                  style: UITextStyles.bodyMedium,
                ),
              );
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
            padding: const EdgeInsets.all(UIConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Address Section
                _buildSectionCard(
                  'Deliver To',
                  Icons.location_on_rounded,
                  _buildAddressSection(user),
                ),

                const SizedBox(height: UIConstants.paddingL),

                // Order Summary Section
                _buildSectionCard(
                  'Order Summary',
                  Icons.receipt_long_rounded,
                  _buildOrderSummary(cart),
                ),

                const SizedBox(height: UIConstants.paddingL),

                // Payment Method Section
                _buildSectionCard(
                  'Payment Method',
                  Icons.credit_card_rounded,
                  _buildPaymentMethodSection(),
                ),

                const SizedBox(height: UIConstants.paddingL),

                // Bill Details Section
                _buildBillDetailsCard(cart, deliveryCharge, finalAmount),

                const SizedBox(height: UIConstants.paddingXL),

                // Place Order Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedAddress != null && !_isLoading
                        ? () => _placeOrder(context, cart, user)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIConstants.primaryColor,
                      disabledBackgroundColor: UIConstants.textTertiary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusL),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Place Order',
                            style: UITextStyles.headlineSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: UIConstants.paddingL),
              ],
            ),
          );
        }
        return const Center(child: Text('Please login to continue'));
      },
    );
  }

  Widget _buildSectionCard(String title, IconData icon, Widget content) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        boxShadow: UIConstants.shadowsM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: UIConstants.primaryColor, size: 24),
              const SizedBox(width: UIConstants.paddingS),
              Text(title, style: UITextStyles.headlineSmall),
            ],
          ),
          const SizedBox(height: UIConstants.paddingM),
          content,
        ],
      ),
    );
  }

  Widget _buildAddressSection(dynamic user) {
    if (user.addresses.isEmpty) {
      return Column(
        children: [
          const Icon(Icons.location_off,
              size: 48, color: UIConstants.textTertiary),
          const SizedBox(height: 12),
          const Text('No delivery address found'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/add-address'),
            child: const Text('Add Address'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedAddress != null) ...[
          Text(
            _selectedAddress.name,
            style: UITextStyles.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _selectedAddress.address,
            style: UITextStyles.bodyMedium,
          ),
          Text(
            '${_selectedAddress.landmark}, ${_selectedAddress.pincode}',
            style: UITextStyles.bodySmall,
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/address'),
            icon: const Icon(Icons.edit_rounded),
            label: const Text('Change Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIConstants.backgroundColor,
              foregroundColor: UIConstants.primaryColor,
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(CartModel cart) {
    return Column(
      children: cart.items.values.take(3).map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingS),
          child: Row(
            children: [
              Text(
                item.product.name,
                style: UITextStyles.bodyMedium,
              ),
              const Spacer(),
              Text(
                '${item.quantity}x',
                style: UITextStyles.bodySmall,
              ),
              const SizedBox(width: UIConstants.paddingS),
              Text(
                '₹${item.total.toStringAsFixed(0)}',
                style: UITextStyles.labelLarge,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      children: [
        _buildPaymentOption('Cash on Delivery', 'cod', Icons.money_rounded),
        const SizedBox(height: UIConstants.paddingM),
        _buildPaymentOption(
            'Online Payment', 'online', Icons.credit_card_rounded),
      ],
    );
  }

  Widget _buildPaymentOption(String title, String value, IconData icon) {
    final isSelected = _paymentMethod == value;

    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(UIConstants.paddingM),
        decoration: BoxDecoration(
          color: isSelected
              ? UIConstants.primaryLight
              : UIConstants.backgroundColor,
          border: Border.all(
            color: isSelected
                ? UIConstants.primaryColor
                : UIConstants.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? UIConstants.primaryColor
                      : UIConstants.dividerColor,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: UIConstants.primaryColor,
                    )
                  : null,
            ),
            const SizedBox(width: UIConstants.paddingM),
            Icon(icon, color: UIConstants.primaryColor),
            const SizedBox(width: UIConstants.paddingS),
            Text(title, style: UITextStyles.labelLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildBillDetailsCard(
      CartModel cart, double deliveryCharge, double finalAmount) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        boxShadow: UIConstants.shadowsM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Bill Details', style: UITextStyles.headlineSmall),
          const SizedBox(height: UIConstants.paddingM),
          _buildBillRow('Subtotal', '₹${cart.totalAmount.toStringAsFixed(0)}'),
          if (cart.discountAmount > 0)
            _buildBillRow(
              'Discount',
              '-₹${cart.discountAmount.toStringAsFixed(0)}',
              isDiscount: true,
            ),
          _buildBillRow(
            'Delivery Charge',
            deliveryCharge == 0
                ? 'FREE'
                : '₹${deliveryCharge.toStringAsFixed(0)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: UIConstants.paddingS),
            child: Divider(),
          ),
          _buildBillRow(
            'Total',
            '₹${finalAmount.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String amount,
      {bool isDiscount = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style:
                isTotal ? UITextStyles.headlineSmall : UITextStyles.bodyMedium,
          ),
          Text(
            amount,
            style:
                (isTotal ? UITextStyles.headlineSmall : UITextStyles.bodyMedium)
                    .copyWith(
              color: isDiscount ? UIConstants.errorColor : null,
            ),
          ),
        ],
      ),
    );
  }

  void _placeOrder(BuildContext context, CartModel cart, dynamic user) {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    setState(() => _isLoading = true);
    context.read<OrderBloc>().add(
          CreateOrder(cart, user, _selectedAddress, _paymentMethod, null),
        );
  }
}
