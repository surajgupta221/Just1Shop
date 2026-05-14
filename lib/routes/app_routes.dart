// lib/routes/app_routes.dart
import 'package:go_router/go_router.dart';
import '../core/constants/route_constants.dart';
import '../presentation/customer/screens/splash_screen_new.dart';
import '../presentation/customer/screens/auth_screen_new.dart';
import '../presentation/customer/screens/home_screen_new.dart';
import '../presentation/customer/screens/product_detail_screen.dart';
import '../presentation/customer/screens/cart_screen_new.dart';
import '../presentation/customer/screens/checkout_screen_new.dart';
import '../presentation/customer/screens/order_history_screen.dart';
import '../presentation/customer/screens/profile_screen_new.dart';
import '../../data/models/product_model.dart';

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
        path: RouteConstants.orderHistory,
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: RouteConstants.profile,
        builder: (context, state) => const ProfileScreenModern(),
      ),
    ],
  );
}
