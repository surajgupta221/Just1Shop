// lib/presentation/customer/screens/cart_screen_new.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../data/models/cart_model.dart';
import '../../blocs/cart/cart_bloc.dart';

class CartScreenModern extends StatefulWidget {
  const CartScreenModern({Key? key}) : super(key: key);

  @override
  State<CartScreenModern> createState() => _CartScreenModernState();
}

class _CartScreenModernState extends State<CartScreenModern> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        title: Text('Shopping Cart', style: UITextStyles.headlineLarge),
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
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: UIConstants.primaryColor,
              ),
            );
          }

          if (state is CartLoaded) {
            final cart = state.cart;

            if (cart.itemCount == 0) {
              return _buildEmptyCart(context);
            }

            return _buildCartContent(context, cart);
          }

          if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: UIConstants.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: UITextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.read<CartBloc>().add(LoadCart()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: UIConstants.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 50,
              color: UIConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: UITextStyles.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Add some items to get started',
            style: UITextStyles.bodyMedium.copyWith(
              color: UIConstants.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.shopping_bag_rounded),
            label: const Text('Continue Shopping'),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIConstants.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.paddingL,
                vertical: UIConstants.paddingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusL),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartModel cart) {
    final deliveryCharge = cart.totalAmount >= 500 ? 0.0 : 40.0;
    final finalAmount = cart.totalAmount + deliveryCharge - cart.discountAmount;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(UIConstants.paddingM),
            children: [
              _buildDeliveryInfo(),
              const SizedBox(height: UIConstants.paddingL),
              Text(
                'Items (${cart.itemCount})',
                style: UITextStyles.headlineSmall,
              ),
              const SizedBox(height: UIConstants.paddingM),
              ...cart.items.entries.map((entry) => _buildCartItemCard(
                    context,
                    entry.value,
                    cart,
                  )),
              const SizedBox(height: UIConstants.paddingL),
              _buildCouponSection(),
              const SizedBox(height: UIConstants.paddingL),
              _buildBillSummary(cart, deliveryCharge, finalAmount),
              const SizedBox(height: UIConstants.paddingL),
            ],
          ),
        ),
        _buildCheckoutButton(context, finalAmount),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.primaryLight,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(
          color: UIConstants.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flash_on_rounded,
            color: UIConstants.primaryColor,
            size: 24,
          ),
          const SizedBox(width: UIConstants.paddingS),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery in 10-15 mins',
                style: UITextStyles.labelLarge.copyWith(
                  color: UIConstants.primaryColor,
                ),
              ),
              Text(
                'Standard delivery',
                style: UITextStyles.bodySmall.copyWith(
                  color: UIConstants.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.check_circle_rounded,
            color: UIConstants.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    dynamic cartItem,
    CartModel cart,
  ) {
    final product = cartItem.product;
    final hasDiscount =
        product.discountPrice != null && product.discountPrice! > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.paddingM),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(UIConstants.radiusM),
                  color: UIConstants.backgroundColor,
                  image: DecorationImage(
                    image: NetworkImage(product.images.isNotEmpty
                        ? product.images[0]
                        : 'https://via.placeholder.com/80'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: UIConstants.paddingM),
              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: UITextStyles.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${cartItem.quantity}x ${product.unit}',
                      style: UITextStyles.bodySmall.copyWith(
                        color: UIConstants.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price
                    hasDiscount
                        ? Row(
                            children: [
                              Text(
                                '₹${product.discountPrice!.toStringAsFixed(0)}',
                                style: UITextStyles.labelLarge.copyWith(
                                  color: UIConstants.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '₹${product.price.toStringAsFixed(0)}',
                                style: UITextStyles.bodySmall.copyWith(
                                  color: UIConstants.textTertiary,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            '₹${product.price.toStringAsFixed(0)}',
                            style: UITextStyles.labelLarge.copyWith(
                              color: UIConstants.primaryColor,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.paddingM),
          const Divider(height: 1),
          const SizedBox(height: UIConstants.paddingM),
          // Quantity Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ₹${cartItem.total.toStringAsFixed(0)}',
                style: UITextStyles.labelLarge,
              ),
              _buildQuantityControl(context, cartItem, cart),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(
    BuildContext context,
    dynamic cartItem,
    CartModel cart,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: UIConstants.dividerColor),
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (cartItem.quantity > 1) {
                context.read<CartBloc>().add(
                      UpdateCartItem(
                        cartItem.product.id,
                        cartItem.quantity - 1,
                      ),
                    );
              } else {
                context.read<CartBloc>().add(
                      RemoveFromCart(cartItem.product.id),
                    );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.paddingS,
                vertical: 4,
              ),
              child: Icon(
                Icons.remove_rounded,
                size: 18,
                color: UIConstants.primaryColor,
              ),
            ),
          ),
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '${cartItem.quantity}',
              style: UITextStyles.labelSmall,
            ),
          ),
          GestureDetector(
            onTap: () {
              context.read<CartBloc>().add(
                    UpdateCartItem(
                      cartItem.product.id,
                      cartItem.quantity + 1,
                    ),
                  );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.paddingS,
                vertical: 4,
              ),
              child: Icon(
                Icons.add_rounded,
                size: 18,
                color: UIConstants.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => _buildCouponBottomSheet(),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(UIConstants.paddingM),
        decoration: BoxDecoration(
          color: UIConstants.surfaceColor,
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          border: Border.all(
            color: UIConstants.primaryColor,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_offer_rounded,
              color: UIConstants.primaryColor,
            ),
            const SizedBox(width: UIConstants.paddingS),
            Text(
              'Apply Coupon Code',
              style: UITextStyles.labelLarge.copyWith(
                color: UIConstants.primaryColor,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: UIConstants.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Available Coupons',
            style: UITextStyles.headlineMedium,
          ),
          const SizedBox(height: UIConstants.paddingL),
          // Sample coupons
          _buildCouponCard('SAVE50', '-50₹', 'On orders above ₹200'),
          const SizedBox(height: UIConstants.paddingM),
          _buildCouponCard('FRESH20', '-20%', 'On fresh vegetables'),
          const SizedBox(height: UIConstants.paddingL),
        ],
      ),
    );
  }

  Widget _buildCouponCard(String code, String discount, String condition) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.primaryLight,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(
          color: UIConstants.primaryColor,
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                code,
                style: UITextStyles.labelLarge.copyWith(
                  color: UIConstants.primaryColor,
                ),
              ),
              Text(
                discount,
                style: UITextStyles.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                condition,
                style: UITextStyles.bodySmall.copyWith(
                  color: UIConstants.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIConstants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
              ),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildBillSummary(
    CartModel cart,
    double deliveryCharge,
    double finalAmount,
  ) {
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
          _buildBillRow(
            'Subtotal',
            '₹${cart.totalAmount.toStringAsFixed(0)}',
          ),
          if (cart.discountAmount > 0)
            _buildBillRow(
              'Discount',
              '-₹${cart.discountAmount.toStringAsFixed(0)}',
              isDiscount: true,
            ),
          _buildBillRow(
            'Delivery',
            deliveryCharge == 0
                ? 'FREE'
                : '₹${deliveryCharge.toStringAsFixed(0)}',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: UIConstants.paddingS),
            child: Divider(),
          ),
          _buildBillRow(
            'Total Amount',
            '₹${finalAmount.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(
    String label,
    String amount, {
    bool isDiscount = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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

  Widget _buildCheckoutButton(BuildContext context, double finalAmount) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        boxShadow: UIConstants.shadowsL,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: UITextStyles.headlineMedium,
                ),
                Text(
                  '₹${finalAmount.toStringAsFixed(0)}',
                  style: UITextStyles.displaySmall.copyWith(
                    color: UIConstants.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingM),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.go('/checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: UIConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.radiusL),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Proceed to Checkout',
                  style: UITextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
