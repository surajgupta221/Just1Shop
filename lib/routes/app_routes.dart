// lib/routes/app_routes.dart
import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../presentation/customer/screens/splash_screen_new.dart';
import '../presentation/customer/screens/auth_screen_new.dart';
import '../presentation/customer/screens/home_screen_new.dart';
import '../presentation/customer/screens/product_listing_screen.dart';
import '../presentation/customer/screens/product_detail_screen.dart';
import '../presentation/customer/screens/cart_screen_new.dart';
import '../presentation/customer/screens/checkout_screen_new.dart';
import '../presentation/customer/screens/wallet_screen.dart';
import '../presentation/customer/screens/order_history_screen.dart';
import '../presentation/customer/screens/order_tracking_screen.dart';
import '../presentation/customer/screens/profile_screen_new.dart';
import '../presentation/customer/screens/ai_assistant_screen.dart';
import '../presentation/customer/screens/add_address_screen.dart';
import '../presentation/admin/screens/owner_dashboard_screen.dart';
import '../presentation/admin/screens/admin_dashboard_screen.dart';
import '../presentation/delivery/screens/delivery_dashboard_screen.dart';
import '../presentation/delivery/screens/delivery_tracking_screen.dart';
import '../../data/models/product_model.dart';
import '../../data/models/order_model.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: RouteConstants.splash,
    routes: [
      // Auth Routes
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashScreenModern(),
      ),
      GoRoute(
        path: RouteConstants.auth,
        builder: (context, state) => const AuthScreenModern(),
      ),

      // Customer Routes
      GoRoute(
        path: RouteConstants.home,
        builder: (context, state) => const HomeScreenModern(),
      ),
      GoRoute(
        path: RouteConstants.productListing,
        builder: (context, state) => const ProductListingScreen(),
      ),
      GoRoute(
        path: RouteConstants.productDetail,
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return ProductDetailScreen(product: product);
        },
      ),
      GoRoute(
        path: RouteConstants.cart,
        builder: (context, state) => const CartScreenModern(),
      ),
      GoRoute(
        path: RouteConstants.checkout,
        builder: (context, state) => const CheckoutScreenModern(),
      ),
      GoRoute(
        path: RouteConstants.wallet,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: RouteConstants.orderHistory,
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/order-tracking',
        builder: (context, state) {
          final order = state.extra as OrderModel;
          return OrderTrackingScreen(order: order);
        },
      ),
      GoRoute(
        path: RouteConstants.profile,
        builder: (context, state) => const ProfileScreenModern(),
      ),
      GoRoute(
        path: RouteConstants.aiAssistant,
        builder: (context, state) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: RouteConstants.addAddress,
        builder: (context, state) => const AddAddressScreen(),
      ),

      // Owner Dashboard Route
      GoRoute(
        path: '/owner-dashboard',
        builder: (context, state) => const OwnerDashboardScreen(),
      ),

      // Admin Dashboard Route
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // Delivery Dashboard Route
      GoRoute(
        path: '/delivery-dashboard',
        builder: (context, state) => const DeliveryDashboardScreen(),
      ),

      // Delivery Tracking Route
      GoRoute(
        path: '/delivery-tracking',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return DeliveryTrackingScreen(
            deliveryBoyId: args['deliveryBoyId'] as String,
            orderId: args['orderId'] as String,
            customerName: args['customerName'] as String,
            deliveryAddress: args['deliveryAddress'] as String,
          );
        },
      ),
    ],
  );
}
