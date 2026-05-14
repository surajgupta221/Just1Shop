// lib/presentation/customer/widgets/product_card_modern.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../data/models/product_model.dart';
import '../../blocs/cart/cart_bloc.dart';

class ProductCardModern extends StatelessWidget {
  final ProductModel product;

  const ProductCardModern({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/product-detail', extra: product),
      child: Container(
        decoration: BoxDecoration(
          color: UIConstants.surfaceColor,
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          boxShadow: UIConstants.shadowsM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with Badge
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(UIConstants.radiusL),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: UIConstants.backgroundColor,
                      child: product.images.isNotEmpty
                          ? Image.network(
                              product.images[0],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: UIConstants.dividerColor,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            )
                          : Container(
                              color: UIConstants.dividerColor,
                              child: const Icon(Icons.image),
                            ),
                    ),
                  ),
                  // Discount Badge
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: UIConstants.paddingS,
                          vertical: UIConstants.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: UIConstants.accentColor,
                          borderRadius:
                              BorderRadius.circular(UIConstants.radiusS),
                        ),
                        child: Text(
                          '${product.discountPercentage.toStringAsFixed(0)}% OFF',
                          style: UITextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.paddingS),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product Name and Unit
                    Column(
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
                          product.unit,
                          style: UITextStyles.bodySmall,
                        ),
                      ],
                    ),

                    // Price and Action Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Price
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${product.finalPrice.toStringAsFixed(0)}',
                              style: UITextStyles.headlineSmall.copyWith(
                                color: UIConstants.primaryColor,
                              ),
                            ),
                            if (product.hasDiscount)
                              Text(
                                '₹${product.price.toStringAsFixed(0)}',
                                style: UITextStyles.bodySmall.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  color: UIConstants.textTertiary,
                                ),
                              ),
                          ],
                        ),

                        // Add to Cart Button
                        BlocBuilder<CartBloc, CartState>(
                          builder: (context, state) {
                            int quantity = 0;
                            if (state is CartLoaded) {
                              quantity =
                                  state.cart.items[product.id]?.quantity ?? 0;
                            }

                            if (quantity == 0) {
                              return GestureDetector(
                                onTap: () {
                                  context.read<CartBloc>().add(
                                        AddToCart(product, 1),
                                      );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: UIConstants.primaryColor,
                                    borderRadius: BorderRadius.circular(
                                      UIConstants.radiusS,
                                    ),
                                  ),
                                  child: Text(
                                    'Add',
                                    style: UITextStyles.labelSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: UIConstants.primaryColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    UIConstants.radiusS,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (quantity > 1) {
                                          context.read<CartBloc>().add(
                                                UpdateCartItem(
                                                    product.id, quantity - 1),
                                              );
                                        } else {
                                          context.read<CartBloc>().add(
                                                RemoveFromCart(product.id),
                                              );
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: Icon(
                                          Icons.remove_rounded,
                                          size: 14,
                                          color: UIConstants.primaryColor,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Text(
                                        '$quantity',
                                        style: UITextStyles.labelSmall.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: UIConstants.primaryColor,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        context.read<CartBloc>().add(
                                              UpdateCartItem(
                                                  product.id, quantity + 1),
                                            );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(2),
                                        child: Icon(
                                          Icons.add_rounded,
                                          size: 14,
                                          color: UIConstants.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
