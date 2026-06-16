// lib/presentation/customer/screens/profile_screen_new.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../data/models/user_model.dart';
import '../../blocs/auth/auth_bloc.dart';

class ProfileScreenModern extends StatefulWidget {
  const ProfileScreenModern({Key? key}) : super(key: key);

  @override
  State<ProfileScreenModern> createState() => _ProfileScreenModernState();
}

class _ProfileScreenModernState extends State<ProfileScreenModern> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckAuthStatus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go(RouteConstants.auth);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated && state.userProfile != null) {
              return _buildProfileContent(context, state.userProfile!);
            }
            if (state is AuthAuthenticated) {
              return _buildProfileContent(
                context,
                UserModel(
                  id: state.user.uid,
                  name: state.user.displayName ?? '',
                  phone: state.user.phoneNumber ?? '',
                  email: state.user.email,
                  role: 'customer',
                  addresses: const [],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
              );
            }
            if (state is AuthError) {
              return _buildProfileError(context, state.message);
            }
            if (state is AuthUnauthenticated) {
              return _buildSignInPrompt(context);
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel user) {
    final name = user.name.trim().isEmpty ? 'Just1Shop User' : user.name.trim();
    final phone = user.phone.trim().isEmpty ? '+91 7065926285' : user.phone;
    final initial = name.isEmpty ? 'J' : name[0].toUpperCase();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 2,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            onPressed: () => context.go(RouteConstants.home),
            icon: const Icon(Icons.arrow_back_rounded),
            color: Colors.black,
          ),
          title: Text(
            'Profile',
            style: UITextStyles.displaySmall.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 26, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFFF0F0F0),
                      child: Text(
                        initial,
                        style: UITextStyles.displayMedium.copyWith(
                          color: UIConstants.textSecondary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: UITextStyles.displayMedium.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phone,
                            style: UITextStyles.headlineMedium.copyWith(
                              color: UIConstants.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showProfileEditHint(context),
                      icon: const Icon(Icons.edit_outlined),
                      color: UIConstants.textSecondary,
                      iconSize: 34,
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                _buildNearestStoreCard(context),
                const SizedBox(height: 36),
                Text(
                  'More Details',
                  style: UITextStyles.headlineSmall.copyWith(
                    color: UIConstants.textSecondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                _ProfileMenuTile(
                  icon: Icons.shopping_cart_outlined,
                  title: 'My Orders',
                  onTap: () => context.go(RouteConstants.orderHistory),
                ),
                _ProfileMenuTile(
                  icon: Icons.bookmark_add_outlined,
                  title: 'Saved Addresses',
                  onTap: () => context.go(RouteConstants.addAddress),
                ),
                _ProfileMenuTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Help & support',
                  onTap: () =>
                      _showSimpleMessage(context, 'Support coming soon'),
                ),
                _ProfileMenuTile(
                  icon: Icons.translate_rounded,
                  title: 'Change Language',
                  onTap: () => _showSimpleMessage(
                      context, 'Language selector coming soon'),
                ),
                _ProfileMenuTile(
                  icon: Icons.star_border_rounded,
                  title: 'Rate Us',
                  onTap: () => _showSimpleMessage(
                      context, 'Thanks for rating Just1Shop'),
                ),
                _ProfileMenuTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About Us',
                  onTap: () =>
                      _showSimpleMessage(context, 'Just1Shop grocery delivery'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: UIConstants.errorColor,
                      side: BorderSide(
                        color: UIConstants.errorColor.withOpacity(0.35),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNearestStoreCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E5E5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.storefront_outlined,
                      color: UIConstants.textSecondary,
                      size: 34,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF1F9E28)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1F9E28),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Open Now',
                            style: UITextStyles.labelLarge.copyWith(
                              color: const Color(0xFF1F9E28),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  '1.8 kms • Closest Store',
                  style: UITextStyles.headlineSmall.copyWith(
                    color: UIConstants.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AM Hinoo Chowk RNC',
                  style: UITextStyles.displaySmall.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(
            height: 54,
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showStoresSheet(context),
                    icon: const Icon(Icons.chevron_right_rounded),
                    label: const Text('View More Stores'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2546D8),
                      textStyle: UITextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showSimpleMessage(
                        context, 'Directions will open with maps'),
                    icon: const Icon(Icons.navigation_outlined),
                    label: const Text('Directions'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2546D8),
                      textStyle: UITextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline_rounded, size: 72),
            const SizedBox(height: 16),
            Text(
              'Sign in to manage profile',
              style: UITextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteConstants.auth),
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_off_outlined, size: 58),
            const SizedBox(height: 14),
            Text('Profile could not load', style: UITextStyles.headlineMedium),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: UITextStyles.bodyMedium.copyWith(
                color: UIConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => context.read<AuthBloc>().add(CheckAuthStatus()),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStoresSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _StoreOptionTile(
                name: 'AM Hinoo Chowk RNC',
                distance: '1.8 kms',
                open: true,
              ),
              _StoreOptionTile(
                name: 'Just1Shop Doranda',
                distance: '2.4 kms',
                open: true,
              ),
              _StoreOptionTile(
                name: 'Just1Shop Main Road',
                distance: '4.1 kms',
                open: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSimpleMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showProfileEditHint(BuildContext context) {
    _showSimpleMessage(context, 'Profile edit form coming soon');
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(SignOut());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minLeadingWidth: 44,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      leading: Icon(icon, color: Colors.black, size: 32),
      title: Text(
        title,
        style: UITextStyles.displaySmall.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w900,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: UIConstants.textSecondary,
        size: 34,
      ),
    );
  }
}

class _StoreOptionTile extends StatelessWidget {
  final String name;
  final String distance;
  final bool open;

  const _StoreOptionTile({
    required this.name,
    required this.distance,
    required this.open,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.storefront_outlined),
      title: Text(name),
      subtitle: Text(distance),
      trailing: Text(
        open ? 'Open' : 'Closed',
        style: TextStyle(
          color: open ? UIConstants.successColor : UIConstants.errorColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
