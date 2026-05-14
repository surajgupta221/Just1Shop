// lib/presentation/customer/screens/home_screen_new.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/ui_constants.dart';
import '../../blocs/product/product_bloc.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../widgets/product_card_modern.dart';
import '../widgets/category_card_modern.dart';
import '../widgets/banner_carousel.dart';
import 'order_history_screen.dart';
import 'profile_screen_new.dart';

class HomeScreenModern extends StatefulWidget {
  const HomeScreenModern({Key? key}) : super(key: key);

  @override
  State<HomeScreenModern> createState() => _HomeScreenModernState();
}

class _HomeScreenModernState extends State<HomeScreenModern> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<Widget> _screens = [
    const HomeContentModern(),
    const OrderHistoryScreen(),
    const ProfileScreenModern(),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: UIConstants.surfaceColor,
        selectedItemColor: UIConstants.primaryColor,
        unselectedItemColor: UIConstants.textTertiary,
        selectedLabelStyle: UITextStyles.labelMedium.copyWith(
          color: UIConstants.primaryColor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: UITextStyles.labelSmall,
        items: [
          _buildNavItem(Icons.home_rounded, 'Home', 0),
          _buildNavItem(Icons.receipt_long_rounded, 'Orders', 1),
          _buildNavItem(Icons.person_rounded, 'Profile', 2),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? UIConstants.primaryLight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(UIConstants.radiusM),
        ),
        child: Icon(icon, size: 24),
      ),
      label: label,
    );
  }
}

class HomeContentModern extends StatefulWidget {
  const HomeContentModern({Key? key}) : super(key: key);

  @override
  State<HomeContentModern> createState() => _HomeContentModernState();
}

class _HomeContentModernState extends State<HomeContentModern> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load products on init
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Header with delivery location
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          pinned: true,
          backgroundColor: UIConstants.surfaceColor,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              color: UIConstants.surfaceColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(UIConstants.paddingM),
                    child: _buildHeader(),
                  ),
                  _buildSearchBar(),
                ],
              ),
            ),
          ),
        ),

        // Delivery info
        SliverToBoxAdapter(
          child: _buildDeliveryInfo(),
        ),

        // Banners Carousel
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingM),
            child: _buildBannersSection(),
          ),
        ),

        // Categories
        SliverToBoxAdapter(
          child: _buildCategoriesSection(),
        ),

        // Products
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.paddingM),
            child: Text(
              'Popular Items',
              style: UITextStyles.headlineLarge,
            ),
          ),
        ),

        // Product Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: UIConstants.paddingM),
          sliver: _buildProductsGrid(),
        ),

        // Bottom spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: UIConstants.paddingL),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: UIConstants.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deliver to',
                          style: UITextStyles.bodySmall,
                        ),
                        Text(
                          'Your Location',
                          style: UITextStyles.headlineSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          children: [
            const Icon(Icons.shopping_bag_rounded, size: 24),
            const SizedBox(height: 4),
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                int itemCount = 0;
                if (state is CartLoaded) {
                  itemCount = state.cart.itemCount;
                }
                return Text(
                  '$itemCount',
                  style: UITextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UIConstants.paddingM),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          if (value.isNotEmpty) {
            context.read<ProductBloc>().add(SearchProducts(value));
          } else {
            context.read<ProductBloc>().add(LoadProducts());
          }
        },
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: UITextStyles.bodyMedium.copyWith(
            color: UIConstants.textTertiary,
          ),
          prefixIcon:
              const Icon(Icons.search_rounded, color: UIConstants.textTertiary),
          filled: true,
          fillColor: UIConstants.backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusL),
            borderSide: const BorderSide(color: UIConstants.dividerColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusL),
            borderSide: const BorderSide(color: UIConstants.dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusL),
            borderSide:
                const BorderSide(color: UIConstants.primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingM,
            vertical: UIConstants.paddingS,
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: UIConstants.paddingM),
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.primaryLight,
        borderRadius: BorderRadius.circular(UIConstants.radiusM),
        border: Border.all(color: UIConstants.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded,
              color: UIConstants.primaryColor, size: 20),
          const SizedBox(width: UIConstants.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚡ 10-15 mins', style: UITextStyles.labelLarge),
                Text(
                  'Speedy delivery to your doorstep',
                  style: UITextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannersSection() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoaded) {
          return BannerCarousel(banners: state.banners);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCategoriesSection() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingM),
                child: Text(
                  'Shop by Category',
                  style: UITextStyles.headlineLarge,
                ),
              ),
              const SizedBox(height: UIConstants.paddingM),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                        left: index == 0
                            ? UIConstants.paddingM
                            : UIConstants.paddingS,
                        right: index == 4 ? UIConstants.paddingM : 0,
                      ),
                      child: CategoryCardModern(
                        categoryName: 'Category ${index + 1}',
                        icon: Icons.category_rounded,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProductsGrid() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.5,
              crossAxisSpacing: UIConstants.paddingM,
              mainAxisSpacing: UIConstants.paddingM,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildProductSkeleton(),
              childCount: 6,
            ),
          );
        } else if (state is ProductLoaded) {
          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.5,
              crossAxisSpacing: UIConstants.paddingM,
              mainAxisSpacing: UIConstants.paddingM,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  ProductCardModern(product: state.products[index]),
              childCount: state.products.length,
            ),
          );
        } else if (state is ProductError) {
          return SliverToBoxAdapter(
            child: Center(
              child: Text(
                'Error: ${state.message}',
                style: UITextStyles.bodyMedium
                    .copyWith(color: UIConstants.errorColor),
              ),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildProductSkeleton() {
    return Container(
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        boxShadow: UIConstants.shadowsM,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: UIConstants.dividerColor,
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(UIConstants.paddingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    color: UIConstants.dividerColor,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 60,
                    color: UIConstants.dividerColor,
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
