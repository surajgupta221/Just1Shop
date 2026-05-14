// lib/presentation/customer/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../data/models/product_model.dart';
import '../../../presentation/blocs/cart/cart_bloc.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/utils/helpers.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.product.images.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.product.images[0],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                            child: Icon(Icons.image_not_supported, size: 50)),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50)),
                    ),
            ),
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${widget.product.unit}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Helpers.formatCurrency(widget.product.finalPrice),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          if (widget.product.hasDiscount)
                            Text(
                              Helpers.formatCurrency(widget.product.price),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  if (widget.product.hasDiscount) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${widget.product.discountPercentage.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quantity Selector
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          disabledBackgroundColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$_quantity',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.green[50],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Add to Cart Button
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, state) {
                      int cartQuantity = 0;
                      if (state is CartLoaded) {
                        cartQuantity =
                            state.cart.items[widget.product.id]?.quantity ?? 0;
                      }

                      if (cartQuantity == 0) {
                        return CustomButton(
                          text: 'Add to Cart',
                          onPressed: () {
                            context.read<CartBloc>().add(
                                  AddToCart(widget.product, _quantity),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${widget.product.name} added to cart'),
                                action: SnackBarAction(
                                  label: 'View Cart',
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/cart'),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'In Cart: $cartQuantity ${widget.product.unit}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (cartQuantity > 1) {
                                        context.read<CartBloc>().add(
                                              UpdateCartItem(widget.product.id,
                                                  cartQuantity - 1),
                                            );
                                      } else {
                                        context.read<CartBloc>().add(
                                              RemoveFromCart(widget.product.id),
                                            );
                                      }
                                    },
                                    icon: const Icon(Icons.remove),
                                    color: Colors.green,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      context.read<CartBloc>().add(
                                            UpdateCartItem(widget.product.id,
                                                cartQuantity + 1),
                                          );
                                    },
                                    icon: const Icon(Icons.add),
                                    color: Colors.green,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
