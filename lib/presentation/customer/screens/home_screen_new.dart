// lib/presentation/customer/screens/home_screen_new.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../../data/models/product_model.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/product/product_bloc.dart';
import 'order_history_screen.dart';
import 'profile_screen_new.dart';

class HomeScreenModern extends StatefulWidget {
  const HomeScreenModern({Key? key}) : super(key: key);

  @override
  State<HomeScreenModern> createState() => _HomeScreenModernState();
}

class _HomeScreenModernState extends State<HomeScreenModern> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeContentModern(),
    OrderHistoryScreen(),
    ProfileScreenModern(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text('You are already on Home')),
          );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: _screens[_selectedIndex],
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex == 0
          ? 0
          : _selectedIndex == 1
              ? 2
              : 3,
      onTap: (index) {
        if (index == 1) {
          context.go(RouteConstants.cart);
          return;
        }
        if (index == 0) setState(() => _selectedIndex = 0);
        if (index == 2) setState(() => _selectedIndex = 1);
        if (index == 3) setState(() => _selectedIndex = 2);
      },
      type: BottomNavigationBarType.fixed,
      elevation: 10,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF2546D8),
      unselectedItemColor: UIConstants.textTertiary,
      selectedLabelStyle: UITextStyles.labelSmall.copyWith(
        fontWeight: FontWeight.w900,
      ),
      unselectedLabelStyle: UITextStyles.labelSmall,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_rounded),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_rounded),
          label: 'Orders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profile',
        ),
      ],
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
  final TextEditingController _pincodeController = TextEditingController();
  final List<_MarketTab> _tabs = const [
    _MarketTab('All', Icons.shopping_bag_outlined),
    _MarketTab('Summer', Icons.wb_sunny_outlined),
    _MarketTab('Deals', Icons.local_offer_outlined),
    _MarketTab('Fresh', Icons.apple_outlined),
    _MarketTab('Rice', Icons.grass_outlined),
    _MarketTab('Categories', Icons.grid_view_rounded),
    _MarketTab('Kirana', Icons.delivery_dining_rounded),
  ];

  int _selectedTab = 0;
  String _deliveryAddress =
      'Home - Sahid Bhagat Singh Nagar, Ranchi, Jharkhand';
  String? _pincodeMessage;

  @override
  void initState() {
    super.initState();
    final productBloc = context.read<ProductBloc>();
    productBloc.add(LoadProducts());
    productBloc.add(LoadCategories());
    productBloc.add(LoadBanners());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final products = _productsFromState(state);
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildMarketHeader()),
            SliverToBoxAdapter(child: _buildBodyForTab(products)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      },
    );
  }

  Widget _buildMarketHeader() {
    final theme = _themeForTab(_tabs[_selectedTab].label);
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        0,
      ),
      decoration: BoxDecoration(
        color: theme.headerColor,
        image: theme.headerImage == null
            ? null
            : DecorationImage(
                image: NetworkImage(theme.headerImage!),
                fit: BoxFit.cover,
                opacity: 0.22,
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _showLocationSheet,
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Delivery on hold',
                            style: UITextStyles.headlineLarge.copyWith(
                              color: theme.onHeaderColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.not_interested_rounded,
                            color: theme.onHeaderColor.withOpacity(0.75),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _deliveryAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: UITextStyles.bodyMedium.copyWith(
                                color: theme.onHeaderColor.withOpacity(0.88),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: theme.onHeaderColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: () => context.go(RouteConstants.aiAssistant),
                icon: const Icon(Icons.auto_awesome_rounded),
                tooltip: 'Just1Shop AI',
                style: IconButton.styleFrom(
                  backgroundColor: theme.onHeaderColor.withOpacity(0.16),
                  foregroundColor: theme.onHeaderColor,
                  fixedSize: const Size(50, 50),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => context.go(RouteConstants.profile),
                icon: const Icon(Icons.person_outline_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: theme.onHeaderColor.withOpacity(0.16),
                  foregroundColor: theme.onHeaderColor,
                  fixedSize: const Size(50, 50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildSearchBar(),
          const SizedBox(height: 18),
          SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final selected = index == _selectedTab;
                return _CategoryTabButton(
                  tab: tab,
                  selected: selected,
                  color: theme.onHeaderColor,
                  activeColor: theme.activeColor,
                  onTap: () => setState(() => _selectedTab = index),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemCount: _tabs.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onTap: () => context.go(RouteConstants.productListing),
      onChanged: (value) {
        if (value.trim().isEmpty) {
          context.read<ProductBloc>().add(LoadProducts());
        } else {
          context.read<ProductBloc>().add(SearchProducts(value));
        }
      },
      decoration: InputDecoration(
        hintText: 'Search for "Milk"',
        prefixIcon: const Icon(Icons.search_rounded, size: 30),
        suffixIcon: IconButton(
          onPressed: () => _showVoiceHint(),
          icon: const Icon(Icons.mic_none_rounded, size: 30),
        ),
        filled: true,
        fillColor: Colors.white,
        hintStyle: UITextStyles.headlineMedium.copyWith(
          color: UIConstants.textTertiary,
          fontWeight: FontWeight.w400,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE4E7EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2546D8), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildBodyForTab(List<ProductModel> products) {
    final label = _tabs[_selectedTab].label;
    if (label == 'Categories') {
      return _buildCategoriesPage();
    }
    if (label == 'Kirana') {
      return _buildKiranaPage();
    }

    final sections = _sectionsForTab(label, products);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroForTab(label),
        for (final section in sections)
          _ProductShelf(
            title: section.title,
            products: section.products,
            onViewAll: () => context.go(RouteConstants.productListing),
          ),
        if (label == 'All') ...[
          _buildFreeDeliveryBanner(),
          _buildShopByStore(),
        ],
      ],
    );
  }

  Widget _buildHeroForTab(String label) {
    final hero = _heroForTab(label);
    if (hero == null) return const SizedBox(height: 14);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
      decoration: BoxDecoration(
        gradient: hero.gradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hero.badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                hero.badge!,
                style: UITextStyles.labelMedium.copyWith(
                  color: hero.textColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            hero.title,
            style: UITextStyles.displayLarge.copyWith(
              color: hero.textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hero.subtitle,
            style: UITextStyles.headlineSmall.copyWith(
              color: hero.textColor.withOpacity(0.86),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: hero.chips
                .map(
                  (chip) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.90),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chip,
                      style: UITextStyles.labelMedium.copyWith(
                        color: hero.textColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesPage() {
    final groups = [
      _CategoryGroup('Fruits & Vegetables', const [
        _MarketCategory('Fruits', Icons.apple_rounded, Color(0xFFDFF8C7)),
        _MarketCategory('Vegetables', Icons.eco_rounded, Color(0xFFDFF8C7)),
        _MarketCategory('Onion & Potato', Icons.spa_rounded, Color(0xFFE7F9D1)),
      ]),
      _CategoryGroup('Dairy & Breakfast', const [
        _MarketCategory(
            'Milk & Fresh', Icons.local_drink_rounded, Color(0xFFEAF7FF)),
        _MarketCategory(
            'Bread & Buns', Icons.bakery_dining_rounded, Color(0xFFEAF7FF)),
        _MarketCategory('Breakfast & Cereals', Icons.breakfast_dining_rounded,
            Color(0xFFEAF7FF)),
        _MarketCategory(
            'Jams & Spreads', Icons.cookie_rounded, Color(0xFFEAF7FF)),
      ]),
      _CategoryGroup('Grocery', const [
        _MarketCategory(
            'Atta, Besan & Sooji', Icons.rice_bowl_rounded, Color(0xFFFFF2EA)),
        _MarketCategory(
            'Oils & Ghee', Icons.water_drop_rounded, Color(0xFFFFF2EA)),
        _MarketCategory('Pulses', Icons.grain_rounded, Color(0xFFFFF2EA)),
        _MarketCategory(
            'Cereals & Rice', Icons.grass_rounded, Color(0xFFFFF2EA)),
      ]),
      _CategoryGroup('Beauty & Personal Care', const [
        _MarketCategory(
            'Soaps & Body Washes', Icons.soap_rounded, Color(0xFFFFEEF1)),
        _MarketCategory(
            'Skin & Face Care', Icons.face_rounded, Color(0xFFFFEEF1)),
        _MarketCategory(
            'Hair Care', Icons.content_cut_rounded, Color(0xFFFFEEF1)),
        _MarketCategory(
            'Dental Care', Icons.health_and_safety_rounded, Color(0xFFFFEEF1)),
      ]),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final group in groups) ...[
            Text(
              group.title,
              style: UITextStyles.displaySmall.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: group.items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisExtent: 132,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
              ),
              itemBuilder: (context, index) =>
                  _MarketCategoryTile(category: group.items[index]),
            ),
            const SizedBox(height: 28),
          ],
          _buildShopByStore(),
        ],
      ),
    );
  }

  Widget _buildKiranaPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeroForTab('Kirana'),
        Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.86,
            children: const [
              _AssuredCategoryCard(
                title: 'Rice & Rice Products',
                icon: Icons.rice_bowl_rounded,
                image:
                    'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=600&q=80',
              ),
              _AssuredCategoryCard(
                title: 'Dal & Pulses',
                icon: Icons.grain_rounded,
                image:
                    'https://images.unsplash.com/photo-1515543904379-3d757afe72e4?auto=format&fit=crop&w=600&q=80',
              ),
              _AssuredCategoryCard(
                title: 'Oil, Ghee & Butter',
                icon: Icons.water_drop_rounded,
                image:
                    'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=600&q=80',
              ),
              _AssuredCategoryCard(
                title: 'Atta, Flours & Sooji',
                icon: Icons.bakery_dining_rounded,
                image:
                    'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?auto=format&fit=crop&w=600&q=80',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFreeDeliveryBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 22),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0267E8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Shop for Rs 399 and get Rs 50 FREE',
              style: UITextStyles.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bannerCheck('Rs 0 Delivery Fee'),
              _bannerCheck('Rs 0 Handling Fee'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bannerCheck(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 17),
        const SizedBox(width: 5),
        Text(
          text,
          style: UITextStyles.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildShopByStore() {
    const stores = [
      _MarketCategory('Kitchen Care', Icons.kitchen_rounded, Color(0xFFFFE0C7)),
      _MarketCategory(
          'Cleaning', Icons.cleaning_services_rounded, Color(0xFFDDFBE7)),
      _MarketCategory(
          'Pooja Store', Icons.light_mode_rounded, Color(0xFFFFF2A8)),
      _MarketCategory('Pet Store', Icons.pets_rounded, Color(0xFFD1F7FA)),
      _MarketCategory(
          'Home Furnishing', Icons.chair_rounded, Color(0xFFD9ECFF)),
      _MarketCategory(
          'Electronic Store', Icons.headphones_rounded, Color(0xFFD6FAF6)),
      _MarketCategory(
          'Premium Store', Icons.workspace_premium_rounded, Color(0xFFFFEDB3)),
      _MarketCategory(
          'Stationery Store', Icons.edit_note_rounded, Color(0xFFFFE6C7)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shop By Store',
            style: UITextStyles.displaySmall.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stores.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisExtent: 130,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) =>
                _StoreBubble(category: stores[index]),
          ),
        ],
      ),
    );
  }

  void _showLocationSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) => Container(
            padding: EdgeInsets.fromLTRB(
              18,
              18,
              18,
              MediaQuery.of(context).padding.bottom + 18,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: UIConstants.dividerColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_disabled_outlined,
                          color: Color(0xFFFFA000), size: 34),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Device Location Disabled',
                              style: UITextStyles.headlineSmall.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Enable location for easy delivery',
                              style: UITextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2546D8),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Enable'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Select Delivery Location',
                  style: UITextStyles.headlineLarge.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for area, street name...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: UIConstants.dividerColor),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pincodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'Enter delivery PIN code',
                    prefixIcon: const Icon(Icons.pin_drop_outlined),
                    suffixIcon: TextButton(
                      onPressed: () {
                        _checkDeliveryPincode(
                          refresh: () => setModalState(() {}),
                        );
                      },
                      child: const Text('Check'),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: UIConstants.dividerColor),
                    ),
                  ),
                ),
                if (_pincodeMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _pincodeMessage!.contains('active')
                          ? const Color(0xFFE8FFF4)
                          : const Color(0xFFFFF1F1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _pincodeMessage!,
                      style: UITextStyles.labelMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _LocationActionTile(
                  icon: Icons.my_location_rounded,
                  title: 'Use Current Location',
                  subtitle: 'Recommended',
                  onTap: () {
                    setState(() {
                      _deliveryAddress =
                          'Home - Sahid Bhagat Singh Nagar, Ranchi';
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Saved Addresses',
                  style: UITextStyles.headlineLarge.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                _SavedAddressTile(
                  title: 'Home',
                  address:
                      'Sahid Bhagat Singh Nagar, South Redma, Doranda, Ranchi, Jharkhand 834002',
                  onTap: () {
                    setState(() {
                      _deliveryAddress =
                          'Home - Sahid Bhagat Singh Nagar, Ranchi';
                    });
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go(RouteConstants.addAddress);
                  },
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Add new address'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showVoiceHint() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Voice search will open here.')),
      );
  }

  Future<void> _checkDeliveryPincode({VoidCallback? refresh}) async {
    final pincode = _pincodeController.text.trim();
    final activePins = {'834002', '834001', '834003'};
    if (pincode.length != 6) {
      setState(() {
        _pincodeMessage = 'Enter a valid 6 digit PIN code.';
      });
      refresh?.call();
      return;
    }

    setState(() {
      _pincodeMessage = 'Checking delivery availability for $pincode...';
    });
    refresh?.call();

    try {
      final doc =
          await FirebaseService.deliveryZonesCollection.doc(pincode).get();
      final data = doc.data() as Map<String, dynamic>?;
      final isActive = doc.exists && (data?['isActive'] ?? true) == true;
      setState(() {
        if (isActive) {
          final city = (data?['city'] ?? '').toString();
          _pincodeMessage =
              'Delivery is active in $pincode${city.isEmpty ? '' : ' - $city'}.';
          _deliveryAddress = 'PIN $pincode - Serviceable delivery area';
        } else {
          _pincodeMessage =
              'Delivery is not active in $pincode yet. Add it from Admin > Delivery PIN Codes.';
        }
      });
    } catch (_) {
      setState(() {
        if (activePins.contains(pincode)) {
          _pincodeMessage =
              'Delivery is active in $pincode. Admin can add more PIN codes anytime.';
          _deliveryAddress = 'PIN $pincode - Serviceable delivery area';
        } else {
          _pincodeMessage =
              'Delivery is not active in $pincode yet. Add it from Admin > Delivery PIN Codes.';
        }
      });
    }
    refresh?.call();
  }

  List<ProductModel> _productsFromState(ProductState state) {
    if (state is ProductLoaded) return state.products;
    if (state is ProductSearchResults) return state.products;
    if (state is CategoryProductsLoaded) return state.products;
    return const [];
  }

  List<_ShelfData> _sectionsForTab(String label, List<ProductModel> products) {
    final source = products.isEmpty ? _marketFallbackProducts : products;
    final deals = source.where((product) => product.hasDiscount).toList();
    final fresh = _matchingProducts(source, const [
      'fruit',
      'fresh',
      'vegetable',
      'avocado',
      'yogurt',
      'milk',
    ]);
    final rice = _matchingProducts(source, const [
      'rice',
      'atta',
      'flour',
      'dal',
      'pulses',
      'grain',
    ]);
    final snacks = _matchingProducts(source, const [
      'drink',
      'juice',
      'snack',
      'cookie',
      'summer',
      'lassi',
    ]);

    switch (label) {
      case 'Summer':
        return [
          _ShelfData('Cold Drinks', snacks),
          _ShelfData('Cool Snacking Club', _cycled(source, 6)),
        ];
      case 'Deals':
        return [
          _ShelfData(
              'Bachat Bazaar', deals.isEmpty ? _cycled(source, 8) : deals),
          _ShelfData('50% Off', _cycled(source.reversed.toList(), 6)),
        ];
      case 'Fresh':
        return [
          _ShelfData('Buy Fruits at Best Prices!', fresh),
          _ShelfData('Daily Fresh', _cycled(source, 6)),
        ];
      case 'Rice':
        return [
          _ShelfData('Best Selling', rice),
          _ShelfData('Rice Mela', _cycled(source, 6)),
        ];
      default:
        return [
          _ShelfData('50% Off', deals.isEmpty ? _cycled(source, 5) : deals),
          _ShelfData('Handpicked for You', _cycled(source, 8)),
          _ShelfData('Seasonal Fruits & Vegetables', fresh),
        ];
    }
  }

  List<ProductModel> _matchingProducts(
    List<ProductModel> products,
    List<String> needles,
  ) {
    final matches = products.where((product) {
      final text =
          '${product.name} ${product.description} ${product.categoryId} ${product.tags.join(' ')}'
              .toLowerCase();
      return needles.any(text.contains);
    }).toList();
    return matches.isEmpty ? _cycled(products, 6) : matches;
  }

  List<ProductModel> _cycled(List<ProductModel> products, int count) {
    if (products.isEmpty) return _marketFallbackProducts.take(count).toList();
    return List.generate(count, (index) => products[index % products.length]);
  }

  _HeaderTheme _themeForTab(String label) {
    switch (label) {
      case 'Deals':
        return const _HeaderTheme(
          headerColor: Color(0xFF087D35),
          onHeaderColor: Colors.white,
          activeColor: Color(0xFF23E681),
        );
      case 'Fresh':
        return const _HeaderTheme(
          headerColor: Color(0xFF00543B),
          onHeaderColor: Colors.white,
          activeColor: Color(0xFF0AD879),
        );
      case 'Rice':
        return const _HeaderTheme(
          headerColor: Color(0xFFD09A78),
          onHeaderColor: Colors.white,
          activeColor: Color(0xFFFFB38C),
        );
      case 'Categories':
        return const _HeaderTheme(
          headerColor: Color(0xFFEFF1FF),
          onHeaderColor: Colors.black,
          activeColor: Color(0xFF2546D8),
        );
      case 'Kirana':
        return const _HeaderTheme(
          headerColor: Color(0xFFAED8FF),
          onHeaderColor: Colors.black,
          activeColor: Color(0xFF4D8CFF),
          headerImage:
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
        );
      case 'Summer':
        return const _HeaderTheme(
          headerColor: Color(0xFFBCEEFF),
          onHeaderColor: Colors.black,
          activeColor: Color(0xFF11C6F4),
          headerImage:
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
        );
      default:
        return const _HeaderTheme(
          headerColor: Color(0xFF24449C),
          onHeaderColor: Colors.white,
          activeColor: Color(0xFF2546D8),
        );
    }
  }

  _MarketHero? _heroForTab(String label) {
    switch (label) {
      case 'All':
        return const _MarketHero(
          title: '50% OFF',
          subtitle: 'Shop now and unlock daily grocery offers',
          badge: 'JUST FOR YOU',
          textColor: Colors.white,
          gradient: LinearGradient(
            colors: [Color(0xFF1439A4), Color(0xFF0675E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          chips: ['Room temperature', 'Fast checkout', 'Best sellers'],
        );
      case 'Summer':
        return const _MarketHero(
          title: 'Summer Madness',
          subtitle: 'Cold drinks, coolers, snacks and skin care',
          textColor: Color(0xFF7A3E18),
          gradient: LinearGradient(
            colors: [Color(0xFFE4F9FF), Color(0xFFFFE7B5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          chips: ['Cold Drinks & Juices', 'Ice Creams', 'Skin & Hair Care'],
        );
      case 'Deals':
        return const _MarketHero(
          title: 'Bachat Bazaar',
          subtitle: 'Handpicked low-price deals across your basket',
          textColor: Colors.white,
          gradient: LinearGradient(
            colors: [Color(0xFF007937), Color(0xFF09A54D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          chips: ['Lowest prices', 'Daily offers', 'Limited time'],
        );
      case 'Fresh':
        return const _MarketHero(
          title: 'Daily Fresh',
          subtitle: 'Your daily dose of fruits, vegetables and dairy',
          textColor: Colors.white,
          gradient: LinearGradient(
            colors: [Color(0xFF00543B), Color(0xFF008A57)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          chips: ['Fruits', 'Vegetables', 'Dairy', 'Onion & Potato'],
        );
      case 'Rice':
        return const _MarketHero(
          title: 'Rice Mall',
          subtitle: 'Apki pasand ka har chawal yahin milega!',
          badge: 'APNAMART ASSURED STYLE',
          textColor: Colors.white,
          gradient: LinearGradient(
            colors: [Color(0xFFD09A78), Color(0xFFE7B495)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          chips: ['Basmati Rice', 'Usna Rice', 'Arva Rice', 'Organic Rice'],
        );
      case 'Kirana':
        return const _MarketHero(
          title: 'Just1Shop Assured',
          subtitle: 'Best quality, assured prices, no questions asked returns',
          textColor: Color(0xFF073B73),
          gradient: LinearGradient(
            colors: [Color(0xFFE7F6FF), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          chips: ['Lowest Prices', '6 Step Quality Check', 'Easy Returns'],
        );
      default:
        return null;
    }
  }
}

class _CategoryTabButton extends StatelessWidget {
  final _MarketTab tab;
  final bool selected;
  final Color color;
  final Color activeColor;
  final VoidCallback onTap;

  const _CategoryTabButton({
    required this.tab,
    required this.selected,
    required this.color,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: selected ? activeColor : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                tab.icon,
                color: selected ? Colors.white : color,
                size: 34,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: UITextStyles.labelLarge.copyWith(
                color: selected ? activeColor : color,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 46 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductShelf extends StatelessWidget {
  final String title;
  final List<ProductModel> products;
  final VoidCallback onViewAll;

  const _ProductShelf({
    required this.title,
    required this.products,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 0, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: UITextStyles.displaySmall.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onViewAll,
                  label: const Text('View All'),
                  icon: const Icon(Icons.arrow_circle_right_outlined),
                  iconAlignment: IconAlignment.end,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2546D8),
                    textStyle: UITextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 294,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) =>
                  _MarketProductCard(product: products[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketProductCard extends StatelessWidget {
  final ProductModel product;

  const _MarketProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : '';
    return InkWell(
      onTap: () => context.go(RouteConstants.productDetail, extra: product),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 136,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 152,
                    width: 136,
                    color: const Color(0xFFF7F7F7),
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.shopping_bag_outlined, size: 44)
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.image_not_supported_outlined,
                              size: 42,
                            ),
                          ),
                  ),
                ),
                if (product.hasDiscount)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: 46,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE16A),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Text(
                        '${product.discountPercentage.toStringAsFixed(0)}%\nOFF',
                        textAlign: TextAlign.center,
                        style: UITextStyles.labelSmall.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  right: 7,
                  bottom: 7,
                  child: BlocBuilder<CartBloc, CartState>(
                    builder: (context, state) {
                      final quantity = state is CartLoaded
                          ? state.cart.items[product.id]?.quantity ?? 0
                          : 0;
                      if (quantity > 0) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2546D8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$quantity',
                            style: UITextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        );
                      }
                      return OutlinedButton(
                        onPressed: () =>
                            context.read<CartBloc>().add(AddToCart(product, 1)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2546D8),
                          side: const BorderSide(
                            color: Color(0xFF2546D8),
                            width: 1.5,
                          ),
                          minimumSize: const Size(72, 38),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'ADD',
                          style: UITextStyles.labelLarge.copyWith(
                            color: const Color(0xFF2546D8),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 42,
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: UITextStyles.labelLarge.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product.unit,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UITextStyles.bodySmall.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  'Rs ${product.finalPrice.toStringAsFixed(0)}',
                  style: UITextStyles.headlineSmall.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 5),
                if (product.hasDiscount)
                  Expanded(
                    child: Text(
                      'Rs ${product.price.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UITextStyles.bodySmall.copyWith(
                        decoration: TextDecoration.lineThrough,
                        color: UIConstants.textTertiary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketCategoryTile extends StatelessWidget {
  final _MarketCategory category;

  const _MarketCategoryTile({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(RouteConstants.productListing),
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            height: 82,
            width: double.infinity,
            decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(category.icon, size: 42, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            category.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: UITextStyles.labelMedium.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreBubble extends StatelessWidget {
  final _MarketCategory category;

  const _StoreBubble({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(RouteConstants.productListing),
      borderRadius: BorderRadius.circular(100),
      child: Column(
        children: [
          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
            child: Icon(category.icon, size: 38, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            category.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: UITextStyles.labelMedium.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssuredCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String image;

  const _AssuredCategoryCard({
    required this.title,
    required this.icon,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(RouteConstants.productListing),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: UIConstants.dividerColor),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.92),
                      Colors.white.withOpacity(0.54),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: const Color(0xFF073B73)),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: UITextStyles.headlineMedium.copyWith(
                      color: const Color(0xFF073B73),
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: const [
                      _MiniAssuredChip('Easy Returns'),
                      _MiniAssuredChip('Best Quality'),
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

class _MiniAssuredChip extends StatelessWidget {
  final String text;

  const _MiniAssuredChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECEBFF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: UITextStyles.labelSmall.copyWith(
          color: const Color(0xFF5C5A8B),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LocationActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LocationActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF2FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.my_location_rounded,
                color: Color(0xFF2546D8), size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: UITextStyles.headlineSmall.copyWith(
                      color: const Color(0xFF2546D8),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(subtitle, style: UITextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF2546D8), size: 34),
          ],
        ),
      ),
    );
  }
}

class _SavedAddressTile extends StatelessWidget {
  final String title;
  final String address;
  final VoidCallback onTap;

  const _SavedAddressTile({
    required this.title,
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.home_outlined, color: Color(0xFF2546D8)),
      title: Text(
        title,
        style: UITextStyles.headlineSmall.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        address,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style:
            UITextStyles.bodyMedium.copyWith(color: UIConstants.textSecondary),
      ),
    );
  }
}

class _MarketTab {
  final String label;
  final IconData icon;

  const _MarketTab(this.label, this.icon);
}

class _HeaderTheme {
  final Color headerColor;
  final Color onHeaderColor;
  final Color activeColor;
  final String? headerImage;

  const _HeaderTheme({
    required this.headerColor,
    required this.onHeaderColor,
    required this.activeColor,
    this.headerImage,
  });
}

class _MarketHero {
  final String title;
  final String subtitle;
  final String? badge;
  final Color textColor;
  final Gradient gradient;
  final List<String> chips;

  const _MarketHero({
    required this.title,
    required this.subtitle,
    this.badge,
    required this.textColor,
    required this.gradient,
    required this.chips,
  });
}

class _ShelfData {
  final String title;
  final List<ProductModel> products;

  const _ShelfData(this.title, this.products);
}

class _MarketCategory {
  final String title;
  final IconData icon;
  final Color color;

  const _MarketCategory(this.title, this.icon, this.color);
}

class _CategoryGroup {
  final String title;
  final List<_MarketCategory> items;

  const _CategoryGroup(this.title, this.items);
}

final DateTime _marketNow = DateTime(2026, 1, 1);

final List<ProductModel> _marketFallbackProducts = [
  ProductModel(
    id: 'market-sugar',
    name: 'White Crystal Sugar Loose - 1Kg',
    description: 'Daily grocery staple.',
    price: 60,
    discountPrice: 48,
    images: const [
      'https://images.unsplash.com/photo-1581441363689-1f3c3c414635?auto=format&fit=crop&w=600&q=80',
    ],
    categoryId: 'grocery',
    unit: '1 kg',
    stock: 100,
    isActive: true,
    tags: const ['grocery', 'sugar', 'deals'],
    createdAt: _marketNow,
    updatedAt: _marketNow,
  ),
  ProductModel(
    id: 'market-rice',
    name: 'Premium Usna Loose Rice 1Kg',
    description: 'Assured rice for daily meals.',
    price: 100,
    discountPrice: 39,
    images: const [
      'https://images.unsplash.com/photo-1586201375761-83865001e31c?auto=format&fit=crop&w=600&q=80',
    ],
    categoryId: 'rice',
    unit: '1 kg',
    stock: 80,
    isActive: true,
    tags: const ['rice', 'grain', 'kirana'],
    createdAt: _marketNow,
    updatedAt: _marketNow,
  ),
  ProductModel(
    id: 'market-paneer',
    name: 'Amul Malai Paneer - 200g',
    description: 'Fresh dairy paneer.',
    price: 95,
    discountPrice: 92,
    images: const [
      'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=600&q=80',
    ],
    categoryId: 'milk-dairy',
    unit: '200 g',
    stock: 40,
    isActive: true,
    tags: const ['fresh', 'dairy', 'paneer'],
    createdAt: _marketNow,
    updatedAt: _marketNow,
  ),
  ProductModel(
    id: 'market-onion',
    name: 'Pyaz (Onion)',
    description: 'Fresh vegetables.',
    price: 59,
    discountPrice: 30,
    images: const [
      'https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=600&q=80',
    ],
    categoryId: 'fruits-veg',
    unit: '1 kg',
    stock: 90,
    isActive: true,
    tags: const ['fresh', 'vegetable', 'onion'],
    createdAt: _marketNow,
    updatedAt: _marketNow,
  ),
  ProductModel(
    id: 'market-banana',
    name: 'Kela (Banana Robusta)',
    description: 'Fresh seasonal fruit.',
    price: 49,
    discountPrice: 21,
    images: const [
      'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?auto=format&fit=crop&w=600&q=80',
    ],
    categoryId: 'fruits-veg',
    unit: '3 pcs',
    stock: 120,
    isActive: true,
    tags: const ['fruit', 'fresh', 'banana'],
    createdAt: _marketNow,
    updatedAt: _marketNow,
  ),
  ProductModel(
    id: 'market-drink',
    name: '7up 2.25 Ltr',
    description: 'Summer cold drink.',
    price: 100,
    discountPrice: 75,
    images: const [
      'https://images.unsplash.com/photo-1629203851122-3726ecdf080e?auto=format&fit=crop&w=600&q=80',
    ],
    categoryId: 'summer',
    unit: '2 ltr',
    stock: 60,
    isActive: true,
    tags: const ['summer', 'drink', 'cold'],
    createdAt: _marketNow,
    updatedAt: _marketNow,
  ),
];
