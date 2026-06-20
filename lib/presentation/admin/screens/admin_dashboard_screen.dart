import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/user_model.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../customer/widgets/just1shop_logo.dart';
import '../../shared/widgets/owner_panel_switcher.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.surfaceColor,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.usersCollection.snapshots(),
          builder: (context, usersSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.productsCollection.snapshots(),
              builder: (context, productsSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.ordersCollection.snapshots(),
                  builder: (context, ordersSnapshot) {
                    final users = _usersFromSnapshot(usersSnapshot.data);
                    final products =
                        _productsFromSnapshot(productsSnapshot.data);
                    final orders = _ordersFromSnapshot(ordersSnapshot.data);
                    final errors = [
                      usersSnapshot.error,
                      productsSnapshot.error,
                      ordersSnapshot.error,
                    ].whereType<Object>().toList();

                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: _buildTopChrome(context)),
                        SliverToBoxAdapter(child: _buildAdminHeader(context)),
                        SliverToBoxAdapter(child: _buildBlueIdentityBar()),
                        SliverPadding(
                          padding: const EdgeInsets.all(UIConstants.paddingM),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                for (final error in errors)
                                  _buildAccessWarning(error.toString()),
                                _buildCommandTitle(),
                                const SizedBox(height: UIConstants.paddingM),
                                _buildPrimaryControls(users, products, orders),
                                const SizedBox(height: UIConstants.paddingM),
                                _buildCatalogRow(products),
                                const SizedBox(height: UIConstants.paddingM),
                                _buildOrderMonitoring(orders),
                                const SizedBox(height: UIConstants.paddingM),
                                _buildManagementList(users, products, orders),
                                const SizedBox(height: UIConstants.paddingL),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopChrome(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingM,
        vertical: UIConstants.paddingS,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(UIConstants.radiusXXL),
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          const SizedBox(width: UIConstants.paddingM),
          const Icon(Icons.shopping_bag_rounded, size: 18),
          const SizedBox(width: UIConstants.paddingS),
          Expanded(
            child: Text(
              'Just1Shop',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UITextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const OwnerPanelSwitcher(compact: true),
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              context.read<AuthBloc>().add(SignOut());
              context.go('/auth');
            },
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
      child: Row(
        children: [
          const Icon(Icons.menu_rounded, size: 32),
          const SizedBox(width: UIConstants.paddingM),
          Expanded(
            child: Text(
              'Admin',
              style: UITextStyles.displaySmall.copyWith(
                color: UIConstants.inkColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const Just1ShopLogo(size: 42),
        ],
      ),
    );
  }

  Widget _buildBlueIdentityBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(UIConstants.paddingM),
      color: UIConstants.aiBlue,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/images/logo.png'),
          ),
          const SizedBox(width: UIConstants.paddingS),
          Expanded(
            child: Text(
              'Product catalog, user management, order monitoring',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UITextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Icon(Icons.keyboard_arrow_right_rounded, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildCommandTitle() {
    return Text(
      'Program Command',
      style: UITextStyles.displaySmall.copyWith(
        color: UIConstants.inkColor,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildPrimaryControls(
    List<UserModel> users,
    List<ProductModel> products,
    List<OrderModel> orders,
  ) {
    final controls = [
      _AdminControl(
        'User Management',
        '${users.length} profiles',
        Icons.groups_2_outlined,
        true,
      ),
      _AdminControl(
        'Category Controls',
        '${products.map((p) => p.categoryId).toSet().length} categories',
        Icons.category_outlined,
        false,
      ),
      _AdminControl(
        'Product Catalog',
        '${products.length} items',
        Icons.add_box_outlined,
        false,
      ),
      _AdminControl(
        'Order Panels',
        '${orders.length} orders',
        Icons.receipt_long_outlined,
        true,
      ),
      _AdminControl(
        'Vendor Controls',
        'Suppliers & pricing',
        Icons.storefront_outlined,
        false,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controls.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 720 ? 3 : 2,
            mainAxisExtent: 76,
            crossAxisSpacing: UIConstants.paddingS,
            mainAxisSpacing: UIConstants.paddingS,
          ),
          itemBuilder: (context, index) => _buildControlButton(controls[index]),
        );
      },
    );
  }

  Widget _buildControlButton(_AdminControl control) {
    final filled = control.filled;
    return InkWell(
      borderRadius: BorderRadius.circular(UIConstants.radiusL),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingS,
          vertical: UIConstants.paddingXS,
        ),
        decoration: BoxDecoration(
          color: filled ? UIConstants.aiBlue : const Color(0xFFF7FAFF),
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          border: Border.all(
            color: filled ? UIConstants.aiBlue : const Color(0xFFE4EEF8),
          ),
          boxShadow: filled ? UIConstants.shadowsM : null,
        ),
        child: Row(
          children: [
            Icon(
              control.icon,
              color: filled ? Colors.white : UIConstants.aiBlue,
            ),
            const SizedBox(width: UIConstants.paddingS),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    control.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UITextStyles.labelLarge.copyWith(
                      color: filled ? Colors.white : UIConstants.inkColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    control.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UITextStyles.bodySmall.copyWith(
                      color: filled
                          ? Colors.white.withOpacity(0.78)
                          : UIConstants.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogRow(List<ProductModel> products) {
    final lowStock = products.where((product) => product.stock <= 5).length;
    final active = products.where((product) => product.isActive).length;
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: const Color(0xFFE4EEF8)),
        boxShadow: UIConstants.shadowsM,
      ),
      child: Row(
        children: [
          const Icon(Icons.add_circle_outline_rounded,
              color: UIConstants.aiBlue),
          const SizedBox(width: UIConstants.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Catalog',
                  style: UITextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$active active items • $lowStock low stock',
                  style: UITextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: UIConstants.aiBlue),
        ],
      ),
    );
  }

  Widget _buildOrderMonitoring(List<OrderModel> orders) {
    final activeOrders = orders
        .where((order) =>
            order.status != AppConstants.orderDelivered &&
            order.status != AppConstants.orderCancelled)
        .toList();

    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: const Color(0xFFE4EEF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Monitoring',
            style: UITextStyles.headlineLarge.copyWith(
              color: UIConstants.inkColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: UIConstants.paddingM),
          if (activeOrders.isEmpty)
            _buildMonitoringRow(
              icon: Icons.check_circle_outline,
              title: 'No active orders',
              detail: 'Queue is clear',
              status: 'OK',
            )
          else
            ...activeOrders.take(4).map(
                  (order) => _buildMonitoringRow(
                    icon: Icons.local_shipping_outlined,
                    title: order.items.isEmpty
                        ? 'Order ${_shortId(order.id)}'
                        : order.items.first.name,
                    detail: _shortAddress(order.deliveryAddress.address),
                    status: _statusLabel(order.status),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildMonitoringRow({
    required IconData icon,
    required String title,
    required String detail,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingS),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE4EEF8)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: UIConstants.aiBlue, size: 28),
          const SizedBox(width: UIConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UITextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  detail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UITextStyles.bodySmall,
                ),
              ],
            ),
          ),
          _buildChip(status),
        ],
      ),
    );
  }

  Widget _buildManagementList(
    List<UserModel> users,
    List<ProductModel> products,
    List<OrderModel> orders,
  ) {
    final rows = [
      _ManagementRow('Users', '${users.length} accounts', Icons.person_outline),
      _ManagementRow(
        'Categories',
        '${products.map((p) => p.categoryId).toSet().length} groups',
        Icons.category_outlined,
      ),
      _ManagementRow(
          'Vendor Control', 'Supplier pricing', Icons.handshake_outlined),
      _ManagementRow('Lender Control', 'Payment and cash flow',
          Icons.account_balance_outlined),
    ];

    return Column(
      children: rows
          .map(
            (row) => Container(
              margin: const EdgeInsets.only(bottom: UIConstants.paddingS),
              padding: const EdgeInsets.all(UIConstants.paddingM),
              decoration: BoxDecoration(
                color: UIConstants.surfaceColor,
                borderRadius: BorderRadius.circular(UIConstants.radiusL),
                border: Border.all(color: const Color(0xFFE4EEF8)),
              ),
              child: Row(
                children: [
                  Icon(row.icon, color: UIConstants.aiBlue),
                  const SizedBox(width: UIConstants.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.title,
                          style: UITextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(row.subtitle, style: UITextStyles.bodySmall),
                      ],
                    ),
                  ),
                  const Icon(Icons.add_rounded,
                      color: UIConstants.textTertiary),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAccessWarning(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.paddingM),
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Text(
        'Firestore access needs Admin read permission. $message',
        style: UITextStyles.bodySmall.copyWith(color: const Color(0xFF9A3412)),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingS,
        vertical: UIConstants.paddingXXS,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5FF),
        borderRadius: BorderRadius.circular(UIConstants.radiusRound),
      ),
      child: Text(
        label,
        style: UITextStyles.labelSmall.copyWith(
          color: UIConstants.aiBlue,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  static List<UserModel> _usersFromSnapshot(QuerySnapshot? snapshot) {
    if (snapshot == null) return [];
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  static List<ProductModel> _productsFromSnapshot(QuerySnapshot? snapshot) {
    if (snapshot == null) return [];
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  static List<OrderModel> _ordersFromSnapshot(QuerySnapshot? snapshot) {
    if (snapshot == null) return [];
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static String _shortId(String id) {
    if (id.isEmpty) return '#ORDER';
    return '#${id.substring(0, math.min(6, id.length)).toUpperCase()}';
  }

  static String _shortAddress(String address) {
    if (address.trim().isEmpty) return 'Customer location pending';
    return address;
  }

  static String _statusLabel(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }
}

class _AdminControl {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool filled;

  const _AdminControl(this.title, this.subtitle, this.icon, this.filled);
}

class _ManagementRow {
  final String title;
  final String subtitle;
  final IconData icon;

  const _ManagementRow(this.title, this.subtitle, this.icon);
}
