// lib/presentation/customer/screens/auth_screen_new.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/ui_constants.dart';
import '../../blocs/auth/auth_bloc.dart';

class AuthScreenModern extends StatefulWidget {
  const AuthScreenModern({Key? key}) : super(key: key);

  @override
  State<AuthScreenModern> createState() => _AuthScreenModernState();
}

class _AuthScreenModernState extends State<AuthScreenModern>
    with TickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  late TabController _tabController;
  String _selectedCountryCode = '+91';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      body: SafeArea(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is PhoneVerificationSuccess) {
              _tabController.animateTo(1,
                  duration: const Duration(milliseconds: 300));
            } else if (state is AuthAuthenticated) {
              Navigator.pushReplacementNamed(context, '/home');
            } else if (state is AuthError) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: UIConstants.errorColor,
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildAuthContent(context, state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: UIConstants.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.shopping_bag_rounded,
            size: 50,
            color: UIConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Just1Shop',
          style: UITextStyles.displaySmall.copyWith(
            color: UIConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Groceries Delivered in 10-15 Minutes',
          style: UITextStyles.bodyMedium.copyWith(
            color: UIConstants.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthContent(BuildContext context, AuthState state) {
    return Container(
      margin: const EdgeInsets.all(UIConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign in to Continue',
            style: UITextStyles.headlineLarge,
          ),
          const SizedBox(height: UIConstants.paddingM),
          _buildPhoneInputSection(context, state),
        ],
      ),
    );
  }

  Widget _buildPhoneInputSection(BuildContext context, AuthState state) {
    bool isOtpSent = state is PhoneVerificationSuccess;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isOtpSent) ...[
          Text(
            'Enter Your Phone Number',
            style: UITextStyles.labelLarge,
          ),
          const SizedBox(height: UIConstants.paddingM),
          _buildPhoneInputField(),
          const SizedBox(height: UIConstants.paddingL),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _sendOtp(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: UIConstants.primaryColor,
                disabledBackgroundColor: UIConstants.textTertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusL),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Send OTP',
                      style: UITextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ] else ...[
          Text(
            'Enter OTP',
            style: UITextStyles.labelLarge,
          ),
          const SizedBox(height: UIConstants.paddingM),
          Text(
            'We sent an OTP to ${_phoneController.text}',
            style: UITextStyles.bodySmall,
          ),
          const SizedBox(height: UIConstants.paddingM),
          _buildOtpInputField(),
          const SizedBox(height: UIConstants.paddingL),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _verifyOtp(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: UIConstants.primaryColor,
                disabledBackgroundColor: UIConstants.textTertiary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusL),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Verify OTP',
                      style: UITextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: UIConstants.paddingM),
          Center(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(0,
                  duration: const Duration(milliseconds: 300)),
              child: Text(
                'Change Phone Number',
                style: UITextStyles.labelMedium.copyWith(
                  color: UIConstants.primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneInputField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(color: UIConstants.dividerColor),
      ),
      child: Row(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: UIConstants.paddingM),
            child: Text(_selectedCountryCode, style: UITextStyles.labelLarge),
          ),
          Container(
            width: 1,
            color: UIConstants.dividerColor,
            height: 24,
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                hintText: 'Enter 10-digit number',
                hintStyle: UITextStyles.bodyMedium.copyWith(
                  color: UIConstants.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.paddingM,
                  vertical: UIConstants.paddingS,
                ),
                counterText: '',
              ),
              style: UITextStyles.labelLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInputField() {
    return TextField(
      controller: _otpController,
      keyboardType: TextInputType.number,
      maxLength: 6,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: '000000',
        hintStyle: UITextStyles.headlineLarge.copyWith(
          color: UIConstants.dividerColor,
          letterSpacing: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: const BorderSide(color: UIConstants.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: const BorderSide(color: UIConstants.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide:
              const BorderSide(color: UIConstants.primaryColor, width: 2),
        ),
        counterText: '',
        filled: true,
        fillColor: UIConstants.backgroundColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: UIConstants.paddingL),
      ),
      style: UITextStyles.headlineLarge.copyWith(
        letterSpacing: 12,
      ),
    );
  }

  void _sendOtp(BuildContext context) {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit phone number'),
          backgroundColor: UIConstants.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final phoneNumber = _selectedCountryCode + _phoneController.text;
    context.read<AuthBloc>().add(
          VerifyPhoneNumber(
            phoneNumber,
            (credential) {},
            (exception) => setState(() => _isLoading = false),
            (verificationId, resendToken) {
              setState(() => _isLoading = false);
            },
            (verificationId) => setState(() => _isLoading = false),
          ),
        );
  }

  void _verifyOtp(BuildContext context) {
    if (_otpController.text.isEmpty || _otpController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid OTP'),
          backgroundColor: UIConstants.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    // This would be handled by AuthBloc in actual implementation
  }
}
