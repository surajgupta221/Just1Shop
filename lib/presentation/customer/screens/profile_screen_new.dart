// lib/presentation/customer/screens/profile_screen_new.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/ui_constants.dart';
import '../../blocs/auth/auth_bloc.dart';

class ProfileScreenModern extends StatefulWidget {
  const ProfileScreenModern({Key? key}) : super(key: key);

  @override
  State<ProfileScreenModern> createState() => _ProfileScreenModernState();
}

class _ProfileScreenModernState extends State<ProfileScreenModern> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/auth');
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated && state.userProfile != null) {
              final user = state.userProfile!;
              return _buildProfileContent(context, user);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, dynamic user) {
    return CustomScrollView(
      slivers: [
        // Profile Header
        SliverAppBar(
          expandedHeight: 180,
          pinned: true,
          backgroundColor: UIConstants.primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                color: UIConstants.primaryColor,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingM,
                  vertical: UIConstants.paddingL,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: UIConstants.shadowsL,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: UIConstants.primaryColor,
                          ),
                        ),
                        const SizedBox(width: UIConstants.paddingL),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName ?? 'Guest User',
                                style: UITextStyles.headlineLarge.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.phoneNumber ?? '',
                                style: UITextStyles.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Profile Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(UIConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // My Orders Section
                _buildSectionHeader('My Orders'),
                const SizedBox(height: UIConstants.paddingM),
                _buildQuickAccessCard(
                  'Active Orders',
                  Icons.local_shipping_rounded,
                  Colors.blue,
                  () => context.go('/order-history'),
                ),
                const SizedBox(height: UIConstants.paddingM),
                _buildQuickAccessCard(
                  'Order History',
                  Icons.history_rounded,
                  Colors.purple,
                  () => context.go('/order-history'),
                ),
                const SizedBox(height: UIConstants.paddingL),

                // Addresses Section
                _buildSectionHeader('My Addresses'),
                const SizedBox(height: UIConstants.paddingM),
                ..._buildAddressCards(user),
                const SizedBox(height: UIConstants.paddingM),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/add-address'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add New Address'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIConstants.primaryLight,
                      foregroundColor: UIConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: UIConstants.paddingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusL),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.paddingL),

                // Settings Section
                _buildSectionHeader('Settings'),
                const SizedBox(height: UIConstants.paddingM),
                _buildSettingsTile(
                  'Notifications',
                  Icons.notifications_rounded,
                  () {},
                ),
                const SizedBox(height: UIConstants.paddingS),
                _buildSettingsTile(
                  'Payment Methods',
                  Icons.credit_card_rounded,
                  () {},
                ),
                const SizedBox(height: UIConstants.paddingS),
                _buildSettingsTile(
                  'About Us',
                  Icons.info_rounded,
                  () {},
                ),
                const SizedBox(height: UIConstants.paddingS),
                _buildSettingsTile(
                  'Help & Support',
                  Icons.help_rounded,
                  () {},
                ),
                const SizedBox(height: UIConstants.paddingL),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _showLogoutDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: UIConstants.errorColor.withOpacity(0.1),
                      foregroundColor: UIConstants.errorColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusL),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Logout',
                      style: UITextStyles.headlineSmall.copyWith(
                        color: UIConstants.errorColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: UIConstants.paddingL),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: UITextStyles.headlineSmall,
    );
  }

  Widget _buildQuickAccessCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(UIConstants.paddingM),
        decoration: BoxDecoration(
          color: UIConstants.surfaceColor,
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          boxShadow: UIConstants.shadowsM,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(UIConstants.radiusM),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: UIConstants.paddingM),
            Expanded(
              child: Text(
                title,
                style: UITextStyles.labelLarge,
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAddressCards(dynamic user) {
    if (user.addresses.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(UIConstants.paddingM),
          decoration: BoxDecoration(
            color: UIConstants.backgroundColor,
            borderRadius: BorderRadius.circular(UIConstants.radiusL),
            border: Border.all(color: UIConstants.dividerColor),
          ),
          child: Center(
            child: Text(
              'No addresses added yet',
              style: UITextStyles.bodyMedium.copyWith(
                color: UIConstants.textSecondary,
              ),
            ),
          ),
        ),
      ];
    }

    return user.addresses.map<Widget>((address) {
      return Container(
        margin: const EdgeInsets.only(bottom: UIConstants.paddingM),
        padding: const EdgeInsets.all(UIConstants.paddingM),
        decoration: BoxDecoration(
          color: UIConstants.surfaceColor,
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          border: Border.all(
            color: address.isDefault ?? false
                ? UIConstants.primaryColor
                : UIConstants.dividerColor,
            width: address.isDefault ?? false ? 2 : 1,
          ),
          boxShadow: UIConstants.shadowsM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getAddressIcon(address.type),
                  color: UIConstants.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: UIConstants.paddingS),
                Text(
                  address.name,
                  style: UITextStyles.labelLarge,
                ),
                const Spacer(),
                if (address.isDefault ?? false)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.paddingS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: UIConstants.primaryLight,
                      borderRadius: BorderRadius.circular(UIConstants.radiusS),
                    ),
                    child: Text(
                      'Default',
                      style: UITextStyles.labelSmall.copyWith(
                        color: UIConstants.primaryColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: UIConstants.paddingS),
            Text(
              address.address,
              style: UITextStyles.bodySmall,
            ),
            Text(
              '${address.landmark}, ${address.pincode}',
              style: UITextStyles.bodySmall.copyWith(
                color: UIConstants.textSecondary,
              ),
            ),
            const SizedBox(height: UIConstants.paddingM),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: UIConstants.dividerColor),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusM),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: UIConstants.paddingS),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.delete_rounded),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: UIConstants.errorColor),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(UIConstants.radiusM),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSettingsTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(UIConstants.paddingM),
        decoration: BoxDecoration(
          color: UIConstants.surfaceColor,
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          boxShadow: UIConstants.shadowsM,
        ),
        child: Row(
          children: [
            Icon(icon, color: UIConstants.primaryColor),
            const SizedBox(width: UIConstants.paddingM),
            Expanded(
              child: Text(title, style: UITextStyles.labelLarge),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  IconData _getAddressIcon(String? type) {
    switch (type) {
      case 'home':
        return Icons.home_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'other':
      default:
        return Icons.location_on_rounded;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
        ),
        title: Text(
          'Logout',
          style: UITextStyles.headlineLarge,
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: UITextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: UITextStyles.labelLarge.copyWith(
                color: UIConstants.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(SignOut());
            },
            child: Text(
              'Logout',
              style: UITextStyles.labelLarge.copyWith(
                color: UIConstants.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
