import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../widgets/just1shop_logo.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: UIConstants.surfaceColor,
        leading: IconButton(
          onPressed: () => context.go(RouteConstants.home),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: UIConstants.inkColor,
        ),
        title: Text(
          'Just1Shop Money',
          style: UITextStyles.headlineLarge.copyWith(
            color: UIConstants.inkColor,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.go(RouteConstants.cart),
            icon: const Icon(Icons.shopping_cart_rounded),
            color: UIConstants.primaryDark,
            tooltip: 'Cart',
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final name = state is AuthAuthenticated
              ? (state.userProfile?.name.trim().isNotEmpty == true
                  ? state.userProfile!.name
                  : 'Just1Shop member')
              : 'Just1Shop member';

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 880;
              final content = [
                _buildWalletHero(name),
                const SizedBox(height: 16),
                _buildActions(context),
                const SizedBox(height: 16),
                _buildGiftCards(),
                const SizedBox(height: 16),
                _buildTransactions(),
              ];

              if (!isWide) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: content,
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(children: content.take(3).toList()),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _buildLoyaltyPanel(),
                          const SizedBox(height: 16),
                          _buildTransactions(),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildWalletHero(String name) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF07111F), Color(0xFF063D43), Color(0xFF07715E)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: UIConstants.primaryDark.withOpacity(0.24),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Just1ShopLogo(size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: UITextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _buildGlowChip('PREMIUM'),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Available balance',
            style: UITextStyles.labelMedium.copyWith(
              color: Colors.white.withOpacity(0.72),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Rs 1,240',
            style: UITextStyles.displayLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildWalletMetric('2,850', 'Loyalty pts'),
              const SizedBox(width: 12),
              _buildWalletMetric('Rs 180', 'Rewards ready'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            icon: Icons.add_card_rounded,
            title: 'Add Money',
            subtitle: 'UPI, Card, Netbanking',
            onTap: () => _showSoon(context, 'Add money'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionTile(
            icon: Icons.card_giftcard_rounded,
            title: 'Gift Card',
            subtitle: 'Redeem or buy',
            onTap: () => _showSoon(context, 'Gift card'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: UIConstants.surfaceColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: UIConstants.dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: UIConstants.aiBlue),
            const SizedBox(height: 12),
            Text(title, style: UITextStyles.labelLarge),
            const SizedBox(height: 4),
            Text(subtitle, style: UITextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftCards() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: UIConstants.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.redeem_rounded, color: UIConstants.primaryDark),
              const SizedBox(width: 10),
              Text(
                'Gift cards',
                style: UITextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              _buildGlowChip('NEW'),
            ],
          ),
          const SizedBox(height: 14),
          _buildGiftRow('Fresh Start Card', 'Rs 500', 'Best for weekly orders'),
          _buildGiftRow(
              'Family Grocery Card', 'Rs 2,000', 'High value monthly pack'),
        ],
      ),
    );
  }

  Widget _buildLoyaltyPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE2FBFF), Color(0xFFEFFFF5)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: UIConstants.primaryColor.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium membership',
            style: UITextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Free delivery, smart restock recommendations, and priority support are active.',
            style: UITextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(UIConstants.radiusRound),
            child: const LinearProgressIndicator(
              minHeight: 9,
              value: 0.78,
              backgroundColor: Color(0xFFDDE8F0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF32FF7E)),
            ),
          ),
          const SizedBox(height: 8),
          Text('780 points to Elite', style: UITextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildTransactions() {
    final items = const [
      _Transaction('Smart cart cashback', '+ Rs 80', 'Today'),
      _Transaction('Wallet payment', '- Rs 420', 'Yesterday'),
      _Transaction('Gift card redeemed', '+ Rs 500', 'May 28'),
    ];

    return Container(
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
            'Transaction history',
            style: UITextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(_buildTransactionRow),
        ],
      ),
    );
  }

  Widget _buildWalletMetric(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: UITextStyles.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: UITextStyles.labelSmall.copyWith(
                color: Colors.white.withOpacity(0.70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGiftRow(String title, String amount, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: UIConstants.backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: UIConstants.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: UIConstants.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.card_giftcard_rounded,
                color: UIConstants.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: UITextStyles.labelLarge),
                Text(subtitle, style: UITextStyles.bodySmall),
              ],
            ),
          ),
          Text(
            amount,
            style: UITextStyles.labelLarge.copyWith(
              color: UIConstants.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionRow(_Transaction item) {
    final isCredit = item.amount.startsWith('+');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                isCredit ? UIConstants.primaryLight : const Color(0xFFFFECE8),
            child: Icon(
              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward,
              color:
                  isCredit ? UIConstants.primaryDark : UIConstants.accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: UITextStyles.labelLarge),
                Text(item.date, style: UITextStyles.bodySmall),
              ],
            ),
          ),
          Text(
            item.amount,
            style: UITextStyles.labelLarge.copyWith(
              color:
                  isCredit ? UIConstants.primaryDark : UIConstants.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF32FF7E),
        borderRadius: BorderRadius.circular(UIConstants.radiusRound),
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

  void _showSoon(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title flow is ready for payment gateway wiring.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _Transaction {
  final String title;
  final String amount;
  final String date;

  const _Transaction(this.title, this.amount, this.date);
}
