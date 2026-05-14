// lib/presentation/customer/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/cart_model.dart';
import '../../../presentation/blocs/cart/cart_bloc.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/helpers.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.cart.itemCount > 0) {
                return TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear Cart'),
                        content: const Text(
                            'Are you sure you want to clear all items from your cart?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<CartBloc>().add(ClearCart());
                              Navigator.pop(context);
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartLoaded) {
            if (state.cart.itemCount == 0) {
              return _buildEmptyCart(context);
            }
            return _buildCartContent(context, state.cart);
          } else if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
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
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add some delicious items to get started',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            ),
            child: const Text('Start Shopping'),
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
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.items.length,
            itemBuilder: (context, index) {
              final item = cart.items.values.elementAt(index);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.product.images.isNotEmpty
                              ? item.product.images[0]
                              : '',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.product.unit} × ${Helpers.formatCurrency(item.product.finalPrice)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: ${Helpers.formatCurrency(item.total)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quantity Controls
                      Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (item.quantity > 1) {
                                    context.read<CartBloc>().add(
                                          UpdateCartItem(item.product.id,
                                              item.quantity - 1),
                                        );
                                  } else {
                                    context.read<CartBloc>().add(
                                          RemoveFromCart(item.product.id),
                                        );
                                  }
                                },
                                icon: const Icon(Icons.remove),
                                iconSize: 20,
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  context.read<CartBloc>().add(
                                        UpdateCartItem(
                                            item.product.id, item.quantity + 1),
                                      );
                                },
                                icon: const Icon(Icons.add),
                                iconSize: 20,
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              context.read<CartBloc>().add(
                                    RemoveFromCart(item.product.id),
                                  );
                            },
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Cart Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Price Breakdown
              _buildPriceRow(
                  'Subtotal', Helpers.formatCurrency(cart.totalAmount)),
              if (cart.discountAmount > 0)
                _buildPriceRow('Discount',
                    '-${Helpers.formatCurrency(cart.discountAmount)}',
                    isDiscount: true),
              _buildPriceRow(
                  'Delivery Charge',
                  deliveryCharge == 0.0
                      ? 'FREE'
                      : Helpers.formatCurrency(deliveryCharge)),
              const Divider(),
              _buildPriceRow('Total', Helpers.formatCurrency(finalAmount),
                  isTotal: true),

              const SizedBox(height: 16),

              // Checkout Button
              CustomButton(
                text: 'Proceed to Checkout',
                onPressed: () => Navigator.pushNamed(context, '/checkout'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount,
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
}
