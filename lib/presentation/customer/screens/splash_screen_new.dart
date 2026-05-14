// lib/presentation/customer/screens/splash_screen_new.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/ui_constants.dart';
import '../../blocs/auth/auth_bloc.dart';

class SplashScreenModern extends StatefulWidget {
  const SplashScreenModern({Key? key}) : super(key: key);

  @override
  State<SplashScreenModern> createState() => _SplashScreenModernState();
}

class _SplashScreenModernState extends State<SplashScreenModern>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Start animations
    _scaleController.forward();
    _slideController.forward();
    _fadeController.forward();

    // Check auth after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.read<AuthBloc>().add(CheckAuthStatus());
      }
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.primaryColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/home');
          } else if (state is AuthUnauthenticated) {
            context.go('/auth');
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0, end: 1).animate(
                  CurvedAnimation(
                      parent: _scaleController, curve: Curves.elasticOut),
                ),
                child: _buildLogo(),
              ),
              const SizedBox(height: 40),
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                      parent: _slideController, curve: Curves.easeOut),
                ),
                child: FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                        parent: _fadeController, curve: Curves.easeInOut),
                  ),
                  child: _buildAppNameAndTagline(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.shopping_bag_rounded,
        size: 60,
        color: UIConstants.primaryColor,
      ),
    );
  }

  Widget _buildAppNameAndTagline() {
    return Column(
      children: [
        Text(
          'Just1Shop',
          style: UITextStyles.displayMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Groceries Delivered in 10-15 Minutes',
          style: UITextStyles.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: 200,
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation(
                Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
