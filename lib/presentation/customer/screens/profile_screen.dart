// lib/presentation/customer/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../core/widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            final userProfile = state.userProfile;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green[100],
                    child: Text(
                      userProfile?.name.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Info
                  Text(
                    userProfile?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.phoneNumber ?? user.email ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Menu Items
                  _buildMenuItem(
                    icon: Icons.location_on,
                    title: 'Addresses',
                    subtitle:
                        '${userProfile?.addresses.length ?? 0} saved addresses',
                    onTap: () => Navigator.pushNamed(context, '/address'),
                  ),

                  _buildMenuItem(
                    icon: Icons.receipt_long,
                    title: 'Order History',
                    subtitle: 'View your past orders',
                    onTap: () => Navigator.pushNamed(context, '/order-history'),
                  ),

                  _buildMenuItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Manage notification preferences',
                    onTap: () {
                      // TODO: Implement notifications screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Notifications feature coming soon!')),
                      );
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    onTap: () {
                      // TODO: Implement help screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Help & Support coming soon!')),
                      );
                    },
                  ),

                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'App version and information',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Just1Shop',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 Just1Shop',
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Logout Button
                  CustomButton(
                    text: 'Logout',
                    backgroundColor: Colors.red,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content:
                              const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<AuthBloc>().add(SignOut());
                                Navigator.pop(context);
                              },
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Please login to view profile'));
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
