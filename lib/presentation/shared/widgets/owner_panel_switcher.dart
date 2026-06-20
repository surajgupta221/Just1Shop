import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../blocs/auth/auth_bloc.dart';

class OwnerPanelSwitcher extends StatelessWidget {
  final bool onDark;
  final bool compact;

  const OwnerPanelSwitcher({
    Key? key,
    this.onDark = false,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated ||
            state.userProfile?.role != AppConstants.roleOwner) {
          return const SizedBox.shrink();
        }

        final foreground = onDark ? Colors.white : UIConstants.inkColor;
        final background =
            onDark ? Colors.white.withOpacity(0.14) : const Color(0xFFEAF5FF);
        final borderColor =
            onDark ? Colors.white.withOpacity(0.26) : const Color(0xFFD8E8F8);

        return PopupMenuButton<String>(
          tooltip: 'Switch panel preview',
          onSelected: (route) => context.go(route),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: '/owner-dashboard',
              child: _PanelMenuItem(
                icon: Icons.workspace_premium_outlined,
                title: 'Owner Panel',
                subtitle: 'Business analytics',
              ),
            ),
            PopupMenuItem(
              value: '/admin-dashboard',
              child: _PanelMenuItem(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Admin Panel',
                subtitle: 'Store controls',
              ),
            ),
            PopupMenuItem(
              value: '/delivery-dashboard',
              child: _PanelMenuItem(
                icon: Icons.delivery_dining_outlined,
                title: 'Delivery Boy Panel',
                subtitle: 'Delivery workflow',
              ),
            ),
            PopupMenuItem(
              value: '/home',
              child: _PanelMenuItem(
                icon: Icons.shopping_bag_outlined,
                title: 'User Panel',
                subtitle: 'Customer shopping',
              ),
            ),
          ],
          child: Container(
            height: compact ? 38 : 42,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? UIConstants.paddingS : UIConstants.paddingM,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(UIConstants.radiusRound),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.dashboard_customize_outlined,
                  size: compact ? 18 : 20,
                  color: foreground,
                ),
                if (!compact) ...[
                  const SizedBox(width: UIConstants.paddingXS),
                  Text(
                    'Switch Panel',
                    style: UITextStyles.labelMedium.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
                const SizedBox(width: UIConstants.paddingXXS),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: foreground,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PanelMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _PanelMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: UIConstants.aiBlue),
        const SizedBox(width: UIConstants.paddingS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: UITextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(subtitle, style: UITextStyles.bodySmall),
          ],
        ),
      ],
    );
  }
}
