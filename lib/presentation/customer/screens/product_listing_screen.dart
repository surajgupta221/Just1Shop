import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../data/models/product_model.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/product/product_bloc.dart';
import '../widgets/just1shop_logo.dart';

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({Key? key}) : super(key: key);

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  bool _organicOnly = false;
  bool _localOnly = false;
  bool _flashDealsOnly = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<ProductBloc>();
    bloc.add(LoadProducts());
    bloc.add(LoadCategories());
    bloc.add(LoadBanners());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: UIConstants.surfaceColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go(RouteConstants.home),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: UIConstants.inkColor,
        ),
        title: Row(
          children: [
            const Just1ShopLogo(size: 34),
            const SizedBox(width: 10),
            Text(
              'Marketplace',
              style: UITextStyles.headlineLarge.copyWith(
                color: UIConstants.inkColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.go(RouteConstants.wallet),
            icon: const Icon(Icons.account_balance_wallet_outlined),
            color: UIConstants.aiBlue,
            tooltip: 'Just1Shop Money',
          ),
          IconButton(
            onPressed: () => context.go(RouteConstants.cart),
            icon: const Icon(Icons.shopping_cart_rounded),
            color: UIConstants.primaryDark,
            tooltip: 'Cart',
          ),
        ],
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          final products = _filteredProducts(_productsFromState(state));
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWide) _buildFilterRail(),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              isWide ? 12 : 16,
                              18,
                              16,
                              0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildHero(isWide),
                                const SizedBox(height: 16),
                                _buildSearchBar(),
                                if (!isWide) ...[
                                  const SizedBox(height: 14),
                                  _buildMobileFilters(),
                                ],
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Fresh picks for today',
                                        style:
                                            UITextStyles.headlineLarge.copyWith(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    _buildResultPill(products.length),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (state is ProductLoading)
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: _buildLoadingGrid(isWide),
                          )
                        else if (products.isEmpty)
                          SliverToBoxAdapter(child: _buildEmptyState())
                        else
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: _buildProductGrid(products, isWide),
                          ),
                        const SliverToBoxAdapter(child: SizedBox(height: 26)),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHero(bool isWide) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGlowChip('RADIANT ORGANIC MARKET'),
        const SizedBox(height: 14),
        Text(
          'AI-sorted groceries, organic freshness, 24 hour delivery.',
          style: UITextStyles.displaySmall.copyWith(
            color: UIConstants.inkColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Filter by organic, local, and flash deals. Every card is tuned for fast mobile shopping and wide web browsing.',
          style: UITextStyles.bodyMedium.copyWith(
            color: UIConstants.textSecondary,
          ),
        ),
      ],
    );

    final metrics = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _HeroMetric('84%', 'Basket score'),
        _HeroMetric('24h', 'Delivery promise'),
        _HeroMetric('AI', 'Smart restock'),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE2FBFF), Color(0xFFEFFFF5)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: UIConstants.primaryColor.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: UIConstants.aiBlue.withOpacity(0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 3, child: copy),
                const SizedBox(width: 22),
                Expanded(flex: 2, child: metrics),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: 18),
                metrics,
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        if (value.trim().isEmpty) {
          context.read<ProductBloc>().add(LoadProducts());
        } else {
          context.read<ProductBloc>().add(SearchProducts(value));
        }
      },
      decoration: InputDecoration(
        hintText: 'Search products, brands, nutrition goals...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: () {
            _searchController.clear();
            context.read<ProductBloc>().add(LoadProducts());
          },
          icon: const Icon(Icons.close_rounded),
        ),
        filled: true,
        fillColor: UIConstants.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: UIConstants.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: UIConstants.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: UIConstants.primaryColor),
        ),
      ),
    );
  }

  Widget _buildFilterRail() {
    return Container(
      width: 278,
      margin: const EdgeInsets.fromLTRB(16, 18, 8, 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: UIConstants.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Smart filters',
            style: UITextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _buildFilterButton('All', Icons.grid_view_rounded),
          _buildFilterButton('Dairy', Icons.local_drink_rounded),
          _buildFilterButton('Produce', Icons.eco_rounded),
          _buildFilterButton('Bakery', Icons.bakery_dining_rounded),
          const Divider(height: 30),
          _buildSwitch('Organic only', _organicOnly,
              (value) => setState(() => _organicOnly = value)),
          _buildSwitch('Local stock', _localOnly,
              (value) => setState(() => _localOnly = value)),
          _buildSwitch('Flash deals', _flashDealsOnly,
              (value) => setState(() => _flashDealsOnly = value)),
          const SizedBox(height: 20),
          _buildAdvisorPanel(),
        ],
      ),
    );
  }

  Widget _buildMobileFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCompactFilter('All'),
          _buildCompactFilter('Dairy'),
          _buildCompactFilter('Produce'),
          _buildCompactFilter('Bakery'),
          _buildToggleChip('Organic', _organicOnly,
              () => setState(() => _organicOnly = !_organicOnly)),
          _buildToggleChip('Local', _localOnly,
              () => setState(() => _localOnly = !_localOnly)),
          _buildToggleChip('Flash', _flashDealsOnly,
              () => setState(() => _flashDealsOnly = !_flashDealsOnly)),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, IconData icon) {
    final selected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedFilter = label),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? UIConstants.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? UIConstants.primaryColor : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: selected
                      ? UIConstants.primaryDark
                      : UIConstants.textSecondary),
              const SizedBox(width: 10),
              Text(
                label,
                style: UITextStyles.labelLarge.copyWith(
                  color: selected
                      ? UIConstants.primaryDark
                      : UIConstants.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactFilter(String label) {
    final selected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) => setState(() => _selectedFilter = label),
        selectedColor: UIConstants.primaryLight,
        backgroundColor: UIConstants.surfaceColor,
        labelStyle: UITextStyles.labelMedium.copyWith(
          color: selected ? UIConstants.primaryDark : UIConstants.textPrimary,
          fontWeight: FontWeight.w800,
        ),
        side: BorderSide(
          color: selected ? UIConstants.primaryColor : UIConstants.dividerColor,
        ),
      ),
    );
  }

  Widget _buildToggleChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        onSelected: (_) => onTap(),
        label: Text(label),
        avatar: Icon(
          selected ? Icons.check_circle_rounded : Icons.auto_awesome_outlined,
          size: 16,
        ),
        selectedColor: const Color(0xFFDFFFF0),
        backgroundColor: UIConstants.surfaceColor,
        side: BorderSide(
          color: selected ? UIConstants.primaryColor : UIConstants.dividerColor,
        ),
      ),
    );
  }

  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile.adaptive(
      dense: true,
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: UITextStyles.labelLarge),
      activeColor: UIConstants.primaryColor,
    );
  }

  Widget _buildAdvisorPanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF07111F),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF32FF7E)),
          const SizedBox(height: 10),
          Text(
            'ShopGPT suggests adding milk, greens, and breakfast items before 8 PM.',
            style: UITextStyles.bodySmall.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<ProductModel> products, bool isWide) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : 2,
        mainAxisExtent: isWide ? 314 : 300,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => _MarketplaceProductCard(product: products[index]),
        childCount: products.length,
      ),
    );
  }

  Widget _buildLoadingGrid(bool isWide) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : 2,
        mainAxisExtent: isWide ? 314 : 300,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => Container(
          decoration: BoxDecoration(
            color: UIConstants.surfaceColor,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        childCount: 8,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: UIConstants.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: UIConstants.dividerColor),
        ),
        child: Column(
          children: [
            const Icon(Icons.inventory_2_outlined,
                size: 48, color: UIConstants.aiBlue),
            const SizedBox(height: 12),
            Text('No products matched', style: UITextStyles.headlineMedium),
            const SizedBox(height: 6),
            Text(
              'Try clearing filters or searching another grocery item.',
              style: UITextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPill(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: UIConstants.primaryLight,
        borderRadius: BorderRadius.circular(UIConstants.radiusRound),
      ),
      child: Text(
        '$count items',
        style: UITextStyles.labelMedium.copyWith(
          color: UIConstants.primaryDark,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildGlowChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE9FFF3),
        borderRadius: BorderRadius.circular(UIConstants.radiusRound),
        border: Border.all(color: const Color(0xFF32FF7E)),
      ),
      child: Text(
        label,
        style: UITextStyles.labelSmall.copyWith(
          color: UIConstants.primaryDark,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  List<ProductModel> _productsFromState(ProductState state) {
    if (state is ProductLoaded) return state.products;
    if (state is ProductSearchResults) return state.products;
    if (state is CategoryProductsLoaded) return state.products;
    return const [];
  }

  List<ProductModel> _filteredProducts(List<ProductModel> products) {
    final categoryFiltered = products.where((product) {
      final text =
          '${product.categoryId} ${product.name} ${product.description} ${product.tags.join(' ')}'
              .toLowerCase();
      switch (_selectedFilter) {
        case 'Dairy':
          return text.contains('milk') ||
              text.contains('dairy') ||
              text.contains('yogurt');
        case 'Produce':
          return text.contains('fruit') ||
              text.contains('veg') ||
              text.contains('organic') ||
              text.contains('avocado');
        case 'Bakery':
          return text.contains('bakery') ||
              text.contains('bread') ||
              text.contains('sourdough');
        default:
          return true;
      }
    }).where((product) {
      final tags = product.tags.map((tag) => tag.toLowerCase()).join(' ');
      if (_organicOnly && !tags.contains('organic')) return false;
      if (_localOnly &&
          !tags.contains('local') &&
          !product.description.toLowerCase().contains('fresh')) {
        return false;
      }
      if (_flashDealsOnly && !product.hasDiscount) return false;
      return true;
    }).toList();

    return categoryFiltered;
  }
}

class _MarketplaceProductCard extends StatelessWidget {
  final ProductModel product;

  const _MarketplaceProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : '';

    return InkWell(
      onTap: () => context.go(RouteConstants.productDetail, extra: product),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: UIConstants.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: UIConstants.dividerColor),
          boxShadow: [
            BoxShadow(
              color: UIConstants.inkColor.withOpacity(0.06),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: imageUrl.isEmpty
                          ? Container(
                              color: const Color(0xFFE9F6F4),
                              child: const Icon(Icons.shopping_bag_outlined),
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFE9F6F4),
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _SmallBadge(
                      label: product.hasDiscount
                          ? '${product.discountPercentage.toStringAsFixed(0)}% OFF'
                          : 'AI PICK',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: UITextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.unit,
                    style: UITextStyles.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Rs ${product.finalPrice.toStringAsFixed(0)}',
                          style: UITextStyles.headlineSmall.copyWith(
                            color: UIConstants.primaryDark,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      BlocBuilder<CartBloc, CartState>(
                        builder: (context, state) {
                          final quantity = state is CartLoaded
                              ? state.cart.items[product.id]?.quantity ?? 0
                              : 0;
                          if (quantity > 0) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: UIConstants.primaryLight,
                                borderRadius: BorderRadius.circular(
                                  UIConstants.radiusRound,
                                ),
                              ),
                              child: Text(
                                '$quantity added',
                                style: UITextStyles.labelSmall.copyWith(
                                  color: UIConstants.primaryDark,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            );
                          }
                          return IconButton.filled(
                            onPressed: () => context
                                .read<CartBloc>()
                                .add(AddToCart(product, 1)),
                            icon: const Icon(Icons.add_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: UIConstants.primaryDark,
                              foregroundColor: Colors.white,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String label;

  const _SmallBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF32FF7E),
        borderRadius: BorderRadius.circular(UIConstants.radiusRound),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF32FF7E).withOpacity(0.32),
            blurRadius: 16,
          ),
        ],
      ),
      child: Text(
        label,
        style: UITextStyles.labelSmall.copyWith(
          color: UIConstants.inkColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String value;
  final String label;

  const _HeroMetric(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.60),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: UITextStyles.headlineLarge.copyWith(
              color: UIConstants.primaryDark,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(label, style: UITextStyles.labelSmall),
        ],
      ),
    );
  }
}
