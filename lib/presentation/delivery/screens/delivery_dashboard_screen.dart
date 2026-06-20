import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/services/firebase_service.dart';
import '../../../data/models/order_model.dart';
import '../../../data/models/user_model.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../shared/widgets/owner_panel_switcher.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({Key? key}) : super(key: key);

  @override
  State<DeliveryDashboardScreen> createState() =>
      _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FF),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseService.ordersCollection.snapshots(),
          builder: (context, snapshot) {
            final orders = _ordersFromSnapshot(snapshot.data);
            final activeOrders = orders
                .where((order) =>
                    order.status != AppConstants.orderDelivered &&
                    order.status != AppConstants.orderCancelled)
                .toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildBlueAppBar(context)),
                SliverToBoxAdapter(child: _buildTabs()),
                SliverPadding(
                  padding: const EdgeInsets.all(UIConstants.paddingM),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        if (snapshot.hasError)
                          _buildAccessWarning(snapshot.error.toString()),
                        _buildSectionHeader(
                          'Active Delivery Orders',
                          '${activeOrders.length}',
                        ),
                        const SizedBox(height: UIConstants.paddingS),
                        _buildOrdersList(activeOrders),
                        const SizedBox(height: UIConstants.paddingM),
                        _buildSectionHeader('Map Navigation', 'Route'),
                        const SizedBox(height: UIConstants.paddingS),
                        _buildMapPanel(activeOrders),
                        const SizedBox(height: UIConstants.paddingM),
                        _buildDeliveryActions(activeOrders),
                        const SizedBox(height: 92),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: UIConstants.aiBlue,
        foregroundColor: Colors.white,
        onPressed: () => _showSnack('Add pickup / delivery action selected.'),
        child: const Icon(Icons.add_rounded, size: 34),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBlueAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF004DFF), Color(0xFF0B8DFF)],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(22),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            color: Colors.white,
            tooltip: 'Back',
            onPressed: () => context.go('/auth'),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              'Delivery Boy',
              textAlign: TextAlign.center,
              style: UITextStyles.headlineLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const OwnerPanelSwitcher(onDark: true, compact: true),
          IconButton(
            tooltip: 'Logout',
            color: Colors.white,
            onPressed: () {
              context.read<AuthBloc>().add(SignOut());
              context.go('/auth');
            },
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    const tabs = ['Deliveries', 'Navigation', 'Estimate', 'Ledger'];
    return Container(
      color: UIConstants.surfaceColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final active = _selectedTab == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Column(
                children: [
                  Text(
                    tabs[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: UITextStyles.labelLarge.copyWith(
                      color: active
                          ? UIConstants.aiBlue
                          : UIConstants.textSecondary,
                      fontWeight: active ? FontWeight.w900 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: UIConstants.paddingS),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 4,
                    width: active ? 76 : 0,
                    decoration: BoxDecoration(
                      color: UIConstants.aiBlue,
                      borderRadius:
                          BorderRadius.circular(UIConstants.radiusRound),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String trailing) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: UITextStyles.labelLarge.copyWith(
              color: UIConstants.inkColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          trailing,
          style: UITextStyles.labelMedium.copyWith(
            color: UIConstants.aiBlue,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: UIConstants.paddingXS),
        const Icon(Icons.more_horiz_rounded, color: UIConstants.aiBlue),
      ],
    );
  }

  Widget _buildOrdersList(List<OrderModel> orders) {
    final displayOrders =
        orders.isEmpty ? _fallbackOrders() : orders.take(6).toList();
    return Column(
      children: displayOrders.map(_buildDeliveryOrder).toList(),
    );
  }

  Widget _buildDeliveryOrder(OrderModel order) {
    final color = _statusColor(order.status);
    final itemName =
        order.items.isEmpty ? 'Grocery Bundle' : order.items.first.name;

    return Container(
      margin: const EdgeInsets.only(bottom: UIConstants.paddingS),
      padding: const EdgeInsets.all(UIConstants.paddingS),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(color: const Color(0xFFD8E8F8)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_shipping_rounded, color: color),
          ),
          const SizedBox(width: UIConstants.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UITextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  _shortAddress(order.deliveryAddress.address),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: UITextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _statusLabel(order.status),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: UITextStyles.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                _shortId(order.id),
                style: UITextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapPanel(List<OrderModel> activeOrders) {
    final active = activeOrders.isNotEmpty ? activeOrders.first : null;
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusXL),
        border: Border.all(color: const Color(0xFFD8E8F8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          CustomPaint(
            painter: _DeliveryMapPainter(),
            child: const SizedBox.expand(),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Container(
              padding: const EdgeInsets.all(UIConstants.paddingS),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(UIConstants.radiusL),
                border: Border.all(color: const Color(0xFFD8E8F8)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.navigation_rounded,
                      color: UIConstants.aiBlue),
                  const SizedBox(width: UIConstants.paddingS),
                  Expanded(
                    child: Text(
                      active == null
                          ? 'Route ready when order is assigned'
                          : 'Navigate to ${_shortAddress(active.deliveryAddress.address)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: UITextStyles.labelMedium.copyWith(
                        color: UIConstants.inkColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: UIConstants.aiBlue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryActions(List<OrderModel> activeOrders) {
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
            'Delivery Management',
            style: UITextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: UIConstants.paddingM),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: 'Picked Up',
                  icon: Icons.inventory_2_outlined,
                  color: UIConstants.aiBlue,
                ),
              ),
              const SizedBox(width: UIConstants.paddingS),
              Expanded(
                child: _buildActionButton(
                  label: 'Delivered',
                  icon: Icons.verified_outlined,
                  color: UIConstants.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: UIConstants.paddingS),
          _buildActionButton(
            label: activeOrders.isEmpty
                ? 'No route active'
                : 'Share live status with customer',
            icon: Icons.share_location_outlined,
            color: UIConstants.inkColor,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    bool fullWidth = false,
  }) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: FilledButton.icon(
        onPressed: () => _showSnack('$label selected.'),
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: UIConstants.paddingS),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusL),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: UIConstants.surfaceColor,
      shape: const CircularNotchedRectangle(),
      notchMargin: 9,
      child: SizedBox(
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _DeliveryNavItem(
                icon: Icons.home_outlined, label: 'Orders', active: true),
            _DeliveryNavItem(icon: Icons.route_outlined, label: 'Route'),
            SizedBox(width: 62),
            _DeliveryNavItem(
                icon: Icons.receipt_long_outlined, label: 'Active'),
            _DeliveryNavItem(icon: Icons.person_outline, label: 'Profile'),
          ],
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
        'Firestore access needs Delivery read permission. $message',
        style: UITextStyles.bodySmall.copyWith(color: const Color(0xFF9A3412)),
      ),
    );
  }

  List<OrderModel> _ordersFromSnapshot(QuerySnapshot? snapshot) {
    if (snapshot == null) return [];
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<OrderModel> _fallbackOrders() {
    final now = DateTime.now();
    return [
      _demoOrder('ORD-9012', 'Ravi Sharma', 'out_for_delivery', now),
      _demoOrder('ORD-8120', 'Anita Devi', 'packed', now),
      _demoOrder('ORD-7331', 'Neha Kumari', 'placed', now),
    ];
  }

  OrderModel _demoOrder(
    String id,
    String customer,
    String status,
    DateTime now,
  ) {
    return OrderModel(
      id: id,
      userId: 'demo',
      items: [
        OrderItem(
          productId: 'bundle',
          name: '$customer Grocery Pack',
          price: 499,
          quantity: 1,
          image: '',
          unit: 'pack',
        ),
      ],
      totalAmount: 499,
      discountAmount: 0,
      deliveryCharge: 0,
      finalAmount: 499,
      paymentMethod: 'cod',
      paymentStatus: 'pending',
      deliveryAddress: AddressModel(
        id: 'demo',
        name: customer,
        address: 'Customer location • 1.8 km',
        landmark: '',
        pincode: '',
        isDefault: true,
      ),
      status: status,
      orderDate: now,
      deliveryDate: now.add(const Duration(minutes: 42)),
      statusHistory: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case AppConstants.orderOutForDelivery:
        return UIConstants.aiBlue;
      case AppConstants.orderPacked:
        return UIConstants.warningColor;
      case AppConstants.orderDelivered:
        return UIConstants.primaryColor;
      default:
        return const Color(0xFFE94B5E);
    }
  }

  String _statusLabel(String status) {
    return status.replaceAll('_', ' ').toUpperCase();
  }

  String _shortId(String id) {
    if (id.isEmpty) return '#ORDER';
    return '#${id.substring(0, math.min(6, id.length)).toUpperCase()}';
  }

  String _shortAddress(String address) {
    if (address.trim().isEmpty) return 'Customer location pending';
    return address;
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

class _DeliveryNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _DeliveryNavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon,
            color: active ? UIConstants.aiBlue : UIConstants.textTertiary),
        Text(
          label,
          style: UITextStyles.labelSmall.copyWith(
            color: active ? UIConstants.aiBlue : UIConstants.textTertiary,
            fontWeight: active ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DeliveryMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFE1E9F2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final routePaint = Paint()
      ..color = UIConstants.aiBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final greenPaint = Paint()..color = const Color(0xFF7BD87D);
    final yellowPaint = Paint()..color = const Color(0xFFFFD35A);

    canvas.drawColor(const Color(0xFFF5F8FB), BlendMode.src);
    for (var i = 0; i < 5; i++) {
      final y = size.height * (0.18 + i * 0.16);
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 24), roadPaint);
    }
    for (var i = 0; i < 4; i++) {
      final x = size.width * (0.18 + i * 0.22);
      canvas.drawLine(Offset(x, 0), Offset(x - 30, size.height), roadPaint);
    }

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.75)
      ..lineTo(size.width * 0.36, size.height * 0.56)
      ..lineTo(size.width * 0.55, size.height * 0.62)
      ..lineTo(size.width * 0.80, size.height * 0.32);
    canvas.drawPath(path, routePaint);
    canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.75), 9, yellowPaint);
    canvas.drawCircle(
        Offset(size.width * 0.80, size.height * 0.32), 10, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
