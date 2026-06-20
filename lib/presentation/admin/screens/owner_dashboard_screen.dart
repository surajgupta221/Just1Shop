import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/staff_export_service.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/user_model.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../customer/widgets/just1shop_logo.dart';
import '../../shared/widgets/owner_panel_switcher.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _staffRole = AppConstants.roleAdmin;
  bool _savingStaff = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FF),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.usersCollection.snapshots(),
          builder: (context, usersSnapshot) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.ordersCollection.snapshots(),
              builder: (context, ordersSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.productsCollection.snapshots(),
                  builder: (context, productsSnapshot) {
                    final users = _usersFromSnapshot(usersSnapshot.data);
                    final orders = _ordersFromSnapshot(ordersSnapshot.data);
                    final products =
                        _productsFromSnapshot(productsSnapshot.data);
                    final staff = _staffUsers(users);
                    final errors = [
                      usersSnapshot.error,
                      ordersSnapshot.error,
                      productsSnapshot.error,
                    ].whereType<Object>().toList();

                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(child: _buildTopBar(context)),
                        SliverPadding(
                          padding: const EdgeInsets.all(UIConstants.paddingM),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                for (final error in errors)
                                  _buildAccessWarning(error.toString()),
                                _buildOverviewCard(users, orders, products),
                                const SizedBox(height: UIConstants.paddingM),
                                _buildMetricGrid(
                                    users, orders, products, staff),
                                const SizedBox(height: UIConstants.paddingM),
                                _buildAnalyticsCards(orders, products),
                                const SizedBox(height: UIConstants.paddingM),
                                _buildOrderManagement(orders),
                                const SizedBox(height: UIConstants.paddingM),
                                _buildManagementTools(staff),
                                const SizedBox(height: UIConstants.paddingM),
                                _buildBusinessTables(products, orders),
                                const SizedBox(height: UIConstants.paddingM),
                                _buildStaffTable(staff),
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

  Widget _buildTopBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingM,
        vertical: UIConstants.paddingS,
      ),
      decoration: BoxDecoration(
        color: UIConstants.aiBlue,
        borderRadius: BorderRadius.circular(UIConstants.radiusXXL),
        boxShadow: [
          BoxShadow(
            color: UIConstants.aiBlue.withOpacity(0.24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          const Just1ShopLogo(size: 42),
          const SizedBox(width: UIConstants.paddingS),
          Expanded(
            child: Text(
              'Just1Shop Owner',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: UITextStyles.headlineLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const OwnerPanelSwitcher(onDark: true),
          const SizedBox(width: UIConstants.paddingXS),
          IconButton(
            tooltip: 'Logout',
            color: Colors.white,
            onPressed: () {
              context.read<AuthBloc>().add(SignOut());
              context.go('/auth');
            },
            icon: const Icon(Icons.menu_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(
    List<UserModel> users,
    List<OrderModel> orders,
    List<ProductModel> products,
  ) {
    final revenue = orders.fold<double>(
      0,
      (sum, order) => sum + order.finalAmount,
    );
    final activeOrders = orders
        .where((order) =>
            order.status != AppConstants.orderDelivered &&
            order.status != AppConstants.orderCancelled)
        .length;

    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: UIConstants.shadowsL,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                color: UIConstants.aiBlue,
              ),
              const SizedBox(width: UIConstants.paddingS),
              Text(
                'Owner',
                style: UITextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              _buildStatusChip('Live'),
            ],
          ),
          const SizedBox(height: UIConstants.paddingM),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(UIConstants.paddingL),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B8DFF), Color(0xFF0062E6)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revenue Overview',
                  style: UITextStyles.labelMedium.copyWith(
                    color: Colors.white.withOpacity(0.82),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: UIConstants.paddingXS),
                Text(
                  _money(revenue),
                  style: UITextStyles.displayLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: UIConstants.paddingS),
                Text(
                  '$activeOrders active orders • ${products.length} catalog items • ${users.length} profiles',
                  style: UITextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.82),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: UIConstants.paddingM),
          Wrap(
            spacing: UIConstants.paddingS,
            runSpacing: UIConstants.paddingS,
            children: const [
              _OwnerTab(icon: Icons.dashboard_outlined, label: 'Overview'),
              _OwnerTab(icon: Icons.auto_graph_outlined, label: 'Sales'),
              _OwnerTab(icon: Icons.inventory_2_outlined, label: 'Inventory'),
              _OwnerTab(icon: Icons.receipt_long_outlined, label: 'Orders'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(
    List<UserModel> users,
    List<OrderModel> orders,
    List<ProductModel> products,
    List<UserModel> staff,
  ) {
    final revenue =
        orders.fold<double>(0, (sum, order) => sum + order.finalAmount);
    final inventory =
        products.fold<int>(0, (sum, product) => sum + product.stock);
    final delivery =
        staff.where((user) => user.role == AppConstants.roleDelivery).length;
    final admins =
        staff.where((user) => user.role == AppConstants.roleAdmin).length;

    final metrics = [
      _MetricData('Revenue', _money(revenue), Icons.payments_outlined),
      _MetricData(
          'Orders', orders.length.toString(), Icons.shopping_bag_outlined),
      _MetricData('Inventory', inventory.toString(), Icons.inventory_outlined),
      _MetricData('Team', '$admins/$delivery', Icons.groups_2_outlined),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 760 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: metrics.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 118,
            crossAxisSpacing: UIConstants.paddingS,
            mainAxisSpacing: UIConstants.paddingS,
          ),
          itemBuilder: (context, index) => _buildMetric(metrics[index]),
        );
      },
    );
  }

  Widget _buildMetric(_MetricData metric) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: const Color(0xFFD8E8F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(metric.icon, color: UIConstants.aiBlue),
          Text(
            metric.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: UITextStyles.headlineLarge.copyWith(
              color: UIConstants.inkColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(metric.label, style: UITextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCards(
    List<OrderModel> orders,
    List<ProductModel> products,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;
        final cards = [
          Expanded(
            child: _buildChartCard(
              title: 'Sales Overview',
              value: _money(orders.fold<double>(
                0,
                (sum, order) => sum + order.finalAmount,
              )),
              data: _chartDataFromOrders(orders),
            ),
          ),
          Expanded(
            child: _buildChartCard(
              title: 'Inventory Health',
              value: '${products.where((p) => p.stock > 0).length} active',
              data: _chartDataFromProducts(products),
            ),
          ),
        ];

        if (isWide) {
          return Row(
            children: [
              cards[0],
              const SizedBox(width: UIConstants.paddingM),
              cards[1],
            ],
          );
        }
        return Column(
          children: [
            cards[0],
            const SizedBox(height: UIConstants.paddingM),
            cards[1],
          ],
        );
      },
    );
  }

  Widget _buildChartCard({
    required String title,
    required String value,
    required List<double> data,
  }) {
    return Container(
      height: 214,
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: const Color(0xFFD8E8F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: UITextStyles.labelLarge),
          const SizedBox(height: UIConstants.paddingS),
          Expanded(
            child: CustomPaint(
              painter: _AreaChartPainter(data),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: UIConstants.paddingS),
          Center(
            child: Text(
              value,
              style: UITextStyles.headlineMedium.copyWith(
                color: UIConstants.inkColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderManagement(List<OrderModel> orders) {
    final delivered = orders
        .where((order) => order.status == AppConstants.orderDelivered)
        .length;
    final active = math.max(orders.length - delivered, 0);
    final revenue =
        orders.fold<double>(0, (sum, order) => sum + order.finalAmount);
    final progress = orders.isEmpty ? 0.0 : active / math.max(orders.length, 1);

    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: const Color(0xFFD8E8F8)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 132,
            height: 132,
            child: CustomPaint(
              painter: _DonutChartPainter(progress),
              child: Center(
                child: Text(
                  active.toString(),
                  style: UITextStyles.headlineLarge.copyWith(
                    color: UIConstants.inkColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: UIConstants.paddingL),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Management',
                  style: UITextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: UIConstants.paddingXS),
                Text('Active orders awaiting fulfilment',
                    style: UITextStyles.bodySmall),
                const SizedBox(height: UIConstants.paddingM),
                Text(
                  _money(revenue),
                  style: UITextStyles.displaySmall.copyWith(
                    color: UIConstants.inkColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text('Total sales recorded', style: UITextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementTools(List<UserModel> staff) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: const Color(0xFFD8E8F8)),
      ),
      child: Wrap(
        spacing: UIConstants.paddingS,
        runSpacing: UIConstants.paddingS,
        children: [
          _buildActionButton(
            icon: Icons.person_add_alt_1_rounded,
            label: 'Grant Admin / Delivery Access',
            onPressed: _showAssignStaffSheet,
          ),
          _buildActionButton(
            icon: Icons.table_view_rounded,
            label: 'Export Staff Excel CSV',
            onPressed: staff.isEmpty ? null : () => _exportStaff(staff),
          ),
          _buildActionButton(
            icon: Icons.inventory_2_outlined,
            label: 'Inventory',
            onPressed: () => _showSnack('Inventory management selected.'),
          ),
          _buildActionButton(
            icon: Icons.receipt_long_outlined,
            label: 'Orders',
            onPressed: () => _showSnack('Order management selected.'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor:
            onPressed == null ? UIConstants.textTertiary : UIConstants.aiBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingM,
          vertical: UIConstants.paddingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
        ),
      ),
    );
  }

  Widget _buildBusinessTables(
    List<ProductModel> products,
    List<OrderModel> orders,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;
        final inventory = _buildSmallTable(
          title: 'Inventory Management',
          rows: products.take(4).map((product) {
            return _TableRowData(
              product.name,
              '${product.stock} ${product.unit}',
              product.stock <= 5 ? 'Low' : 'OK',
            );
          }).toList(),
          emptyText: 'No product records yet',
        );
        final orderTable = _buildSmallTable(
          title: 'Recent Orders',
          rows: orders.take(4).map((order) {
            return _TableRowData(
              order.id.isEmpty
                  ? 'Order'
                  : '#${order.id.substring(0, math.min(6, order.id.length))}',
              _money(order.finalAmount),
              _statusLabel(order.status),
            );
          }).toList(),
          emptyText: 'No order records yet',
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(child: inventory),
              const SizedBox(width: UIConstants.paddingM),
              Expanded(child: orderTable),
            ],
          );
        }
        return Column(
          children: [
            inventory,
            const SizedBox(height: UIConstants.paddingM),
            orderTable,
          ],
        );
      },
    );
  }

  Widget _buildSmallTable({
    required String title,
    required List<_TableRowData> rows,
    required String emptyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: const Color(0xFFD8E8F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: UITextStyles.headlineSmall
                .copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: UIConstants.paddingS),
          if (rows.isEmpty)
            Text(emptyText, style: UITextStyles.bodySmall)
          else
            ...rows.map(
              (row) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: UIConstants.paddingXS),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        row.primary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: UITextStyles.bodySmall.copyWith(
                          color: UIConstants.inkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(row.secondary, style: UITextStyles.bodySmall),
                    const SizedBox(width: UIConstants.paddingS),
                    _buildStatusChip(row.trailing),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStaffTable(List<UserModel> staff) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingM),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: const Color(0xFFD8E8F8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Admin and Delivery Team',
                  style: UITextStyles.headlineMedium.copyWith(
                    color: UIConstants.inkColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _buildStatusChip('${staff.length} records'),
            ],
          ),
          const SizedBox(height: UIConstants.paddingM),
          if (staff.isEmpty)
            _buildEmptyStaff()
          else
            ...staff.map(_buildStaffRow),
        ],
      ),
    );
  }

  Widget _buildEmptyStaff() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
      ),
      child: Column(
        children: [
          const Icon(Icons.group_add_outlined,
              color: UIConstants.aiBlue, size: 38),
          const SizedBox(height: UIConstants.paddingS),
          Text(
            'No staff assigned yet',
            style:
                UITextStyles.labelLarge.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: UIConstants.paddingXXS),
          Text(
            'Add an Admin or Delivery Boy mobile number. Their role opens automatically after OTP login.',
            textAlign: TextAlign.center,
            style: UITextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildStaffRow(UserModel user) {
    final isAdmin = user.role == AppConstants.roleAdmin;
    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.paddingS),
      padding: const EdgeInsets.all(UIConstants.paddingS),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(color: const Color(0xFFD8E8F8)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                isAdmin ? UIConstants.aiBlue : UIConstants.primaryLight,
            foregroundColor: isAdmin ? Colors.white : UIConstants.primaryDark,
            child: Icon(isAdmin
                ? Icons.admin_panel_settings_outlined
                : Icons.delivery_dining_outlined),
          ),
          const SizedBox(width: UIConstants.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isEmpty ? 'Unnamed staff' : user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UITextStyles.labelLarge
                      .copyWith(fontWeight: FontWeight.w900),
                ),
                Text('+91 ${user.phone}', style: UITextStyles.bodySmall),
              ],
            ),
          ),
          _buildStatusChip(isAdmin ? 'ADMIN' : 'DELIVERY'),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label) {
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
        'Firestore access needs Owner read permission. $message',
        style: UITextStyles.bodySmall.copyWith(color: const Color(0xFF9A3412)),
      ),
    );
  }

  void _showAssignStaffSheet() {
    _nameController.clear();
    _phoneController.clear();
    _staffRole = AppConstants.roleAdmin;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: UIConstants.paddingM,
                right: UIConstants.paddingM,
                bottom: MediaQuery.of(context).viewInsets.bottom +
                    UIConstants.paddingM,
              ),
              child: Container(
                padding: const EdgeInsets.all(UIConstants.paddingL),
                decoration: BoxDecoration(
                  color: UIConstants.surfaceColor,
                  borderRadius: BorderRadius.circular(UIConstants.radiusXXL),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grant Staff Access',
                      style: UITextStyles.headlineLarge.copyWith(
                        color: UIConstants.inkColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: UIConstants.paddingXS),
                    Text(
                      'Owner mobile +91 ${AppConstants.ownerPhone} controls this. After saving, this phone number opens the correct dashboard automatically after OTP.',
                      style: UITextStyles.bodySmall,
                    ),
                    const SizedBox(height: UIConstants.paddingM),
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: UIConstants.paddingS),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        labelText: '10-digit mobile number',
                        prefixIcon: Icon(Icons.phone_android_outlined),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: UIConstants.paddingS),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: AppConstants.roleAdmin,
                          label: Text('Admin'),
                          icon: Icon(Icons.admin_panel_settings_outlined),
                        ),
                        ButtonSegment(
                          value: AppConstants.roleDelivery,
                          label: Text('Delivery'),
                          icon: Icon(Icons.delivery_dining_outlined),
                        ),
                      ],
                      selected: {_staffRole},
                      onSelectionChanged: (values) {
                        setModalState(() => _staffRole = values.first);
                      },
                    ),
                    const SizedBox(height: UIConstants.paddingL),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _savingStaff
                            ? null
                            : () => _saveStaff(context, setModalState),
                        icon: _savingStaff
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.verified_user_outlined),
                        label: Text(
                          _savingStaff ? 'Saving...' : 'Grant Access',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveStaff(
    BuildContext sheetContext,
    StateSetter setModalState,
  ) async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.length < 2) {
      _showSnack('Please enter staff name.');
      return;
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      _showSnack('Please enter a valid Indian mobile number.');
      return;
    }
    if (AppConstants.isOwnerPhone(phone)) {
      _showSnack(
          'This is the Owner number. Add a different Admin or Delivery number.');
      return;
    }

    setModalState(() => _savingStaff = true);

    final now = Timestamp.now();
    final docId = 'staff_$phone';

    await FirebaseService.usersCollection.doc(docId).set({
      'id': docId,
      'name': name,
      'phone': phone,
      'email': null,
      'role': _staffRole,
      'addresses': [],
      'status': 'active',
      'assignedBy': AppConstants.roleOwner,
      'createdAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));

    setModalState(() => _savingStaff = false);
    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }
    _showSnack(
      '$name can now login with OTP. Just1Shop will open ${_staffRole == AppConstants.roleAdmin ? 'Admin' : 'Delivery Boy'} automatically.',
    );
  }

  Future<void> _exportStaff(List<UserModel> staff) async {
    final csv = _buildStaffCsv(staff);
    final message = await exportStaffCsv(
      csv: csv,
      filename: 'just1shop_staff_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    _showSnack(message);
  }

  String _buildStaffCsv(List<UserModel> staff) {
    final rows = [
      ['Name', 'Phone', 'Role', 'Email', 'Created At', 'Updated At'],
      ...staff.map(
        (user) => [
          user.name,
          user.phone,
          user.role,
          user.email ?? '',
          user.createdAt.toIso8601String(),
          user.updatedAt.toIso8601String(),
        ],
      ),
    ];

    return rows.map((row) => row.map(_csvCell).join(',')).join('\n');
  }

  String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  List<UserModel> _usersFromSnapshot(QuerySnapshot? snapshot) {
    if (snapshot == null) return [];
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  List<OrderModel> _ordersFromSnapshot(QuerySnapshot? snapshot) {
    if (snapshot == null) return [];
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<ProductModel> _productsFromSnapshot(QuerySnapshot? snapshot) {
    if (snapshot == null) return [];
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.stock.compareTo(b.stock));
  }

  List<UserModel> _staffUsers(List<UserModel> users) {
    final byPhone = <String, UserModel>{};
    for (final user in users) {
      if (user.role == AppConstants.roleAdmin ||
          user.role == AppConstants.roleDelivery) {
        byPhone[user.phone] = user;
      }
    }
    final staff = byPhone.values.toList()
      ..sort((a, b) => a.role.compareTo(b.role));
    return staff;
  }

  List<double> _chartDataFromOrders(List<OrderModel> orders) {
    if (orders.isEmpty) return const [4, 7, 5, 9, 12, 8, 11];
    return orders
        .take(7)
        .map((order) => math.max(order.finalAmount / 100, 1).toDouble())
        .toList()
        .reversed
        .toList();
  }

  List<double> _chartDataFromProducts(List<ProductModel> products) {
    if (products.isEmpty) return const [12, 8, 14, 9, 18, 15, 20];
    return products.take(7).map((product) => product.stock.toDouble()).toList();
  }

  String _statusLabel(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  String _money(num value) {
    if (value >= 100000) return 'Rs ${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return 'Rs ${(value / 1000).toStringAsFixed(1)}K';
    return 'Rs ${value.toStringAsFixed(0)}';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _OwnerTab extends StatelessWidget {
  final IconData icon;
  final String label;

  const _OwnerTab({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingS,
        vertical: UIConstants.paddingXS,
      ),
      decoration: BoxDecoration(
        color:
            label == 'Overview' ? UIConstants.aiBlue : const Color(0xFFF4FAFF),
        borderRadius: BorderRadius.circular(UIConstants.radiusRound),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: label == 'Overview' ? Colors.white : UIConstants.aiBlue,
          ),
          const SizedBox(width: UIConstants.paddingXXS),
          Text(
            label,
            style: UITextStyles.labelSmall.copyWith(
              color: label == 'Overview' ? Colors.white : UIConstants.aiBlue,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final String label;
  final String value;
  final IconData icon;

  const _MetricData(this.label, this.value, this.icon);
}

class _TableRowData {
  final String primary;
  final String secondary;
  final String trailing;

  const _TableRowData(this.primary, this.secondary, this.trailing);
}

class _AreaChartPainter extends CustomPainter {
  final List<double> data;

  _AreaChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final values = data.isEmpty ? const [1.0] : data;
    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    final range = math.max(maxValue - minValue, 1);
    final step =
        values.length == 1 ? size.width : size.width / (values.length - 1);
    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < values.length; i++) {
      final x = i * step;
      final normalized = (values[i] - minValue) / range;
      final y =
          size.height - (normalized * size.height * 0.78) - size.height * 0.10;
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          UIConstants.aiBlue.withOpacity(0.34),
          UIConstants.aiBlue.withOpacity(0.04),
        ],
      ).createShader(Offset.zero & size);
    final linePaint = Paint()
      ..color = UIConstants.aiBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

class _DonutChartPainter extends CustomPainter {
  final double progress;

  _DonutChartPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = size.width * 0.13;
    final bg = Paint()
      ..color = const Color(0xFFE4EEF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final fg = Paint()
      ..color = UIConstants.aiBlue
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;

    canvas.drawArc(rect.deflate(stroke), -math.pi / 2, math.pi * 2, false, bg);
    canvas.drawArc(
      rect.deflate(stroke),
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0, 1),
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
