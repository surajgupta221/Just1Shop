// lib/presentation/customer/screens/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../presentation/blocs/order/order_bloc.dart';
import '../../../core/widgets/error_widget.dart' as app_error;
import '../../../core/widgets/loading_widget.dart';
import '../widgets/order_card.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<OrderBloc>().add(LoadUserOrders(authState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: LoadingWidget());
          } else if (state is UserOrdersLoaded) {
            if (state.orders.isEmpty) {
              return _buildEmptyOrders();
            }
            return _buildOrdersList(state.orders);
          } else if (state is OrderError) {
            return app_error.ErrorWidget(
              message: state.message,
              onRetry: _loadOrders,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            ),
            child: const Text('Start Shopping'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List orders) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return OrderCard(order: orders[index]);
        },
      ),
    );
  }
}
