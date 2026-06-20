// lib/presentation/customer/screens/auth_screen_new.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/ui_constants.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../widgets/just1shop_logo.dart';

class AuthScreenModern extends StatefulWidget {
  const AuthScreenModern({Key? key}) : super(key: key);

  @override
  State<AuthScreenModern> createState() => _AuthScreenModernState();
}

class _AuthScreenModernState extends State<AuthScreenModern> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final String _selectedCountryCode = '+91';
  bool _isLoading = false;
  bool _isOtpSent = false;
  String? _verificationId;
  String? _phoneNumber;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
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
              _verificationId = state.verificationId;
              _phoneNumber = state.phoneNumber;
              setState(() {
                _isLoading = false;
                _isOtpSent = true;
              });
              _showInfo(
                'OTP requested. Please use only the latest OTP for verification.',
              );
            } else if (state is AuthAuthenticated) {
              final userRole =
                  state.userProfile?.role ?? AppConstants.roleCustomer;
              switch (userRole) {
                case AppConstants.roleOwner:
                  context.go('/owner-dashboard');
                  break;
                case AppConstants.roleAdmin:
                  context.go('/admin-dashboard');
                  break;
                case AppConstants.roleDelivery:
                  context.go('/delivery-dashboard');
                  break;
                default:
                  context.go('/home');
              }
            } else if (state is AuthError) {
              setState(() => _isLoading = false);
              _showError(state.message);
            } else if (state is PhoneVerificationError) {
              setState(() => _isLoading = false);
              _showError(state.message);
            }
          },
          builder: (context, state) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 820;

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          isWide ? UIConstants.paddingXL : UIConstants.paddingM,
                      vertical: UIConstants.paddingL,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1120),
                      child: isWide
                          ? Row(
                              children: [
                                Expanded(child: _buildHeroPanel(isWide)),
                                const SizedBox(width: UIConstants.paddingXL),
                                SizedBox(
                                  width: 430,
                                  child: _buildAuthPanel(context, state),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildHeroPanel(isWide),
                                const SizedBox(height: UIConstants.paddingL),
                                _buildAuthPanel(context, state),
                              ],
                            ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroPanel(bool isWide) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isWide ? 28 : 22),
      child: AspectRatio(
        aspectRatio: isWide ? 0.92 : 1.58,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/banner.webp',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    UIConstants.inkColor.withOpacity(0.05),
                    UIConstants.inkColor.withOpacity(0.30),
                    UIConstants.inkColor.withOpacity(0.82),
                  ],
                ),
              ),
            ),
            Positioned(
              left: UIConstants.paddingL,
              right: UIConstants.paddingL,
              bottom: UIConstants.paddingL,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBrandMark(compact: !isWide),
                  const SizedBox(height: UIConstants.paddingM),
                  Text(
                    'Fresh essentials, smart delivery.',
                    style: UITextStyles.displaySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: UIConstants.paddingXS),
                  Text(
                    'Built for just1shop.com, Android, and fast local commerce.',
                    style: UITextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.86),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthPanel(BuildContext context, AuthState state) {
    return Container(
      padding: const EdgeInsets.all(UIConstants.paddingL),
      decoration: BoxDecoration(
        color: UIConstants.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: UIConstants.dividerColor),
        boxShadow: [
          BoxShadow(
            color: UIConstants.inkColor.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: UIConstants.paddingXL),
          Text(
            _isOtpSent ? 'Verify your OTP' : 'Login with mobile',
            style: UITextStyles.headlineLarge.copyWith(
              color: UIConstants.inkColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: UIConstants.paddingXS),
          Text(
            _isOtpSent
                ? 'Code sent to ${_phoneController.text}'
                : 'Enter mobile number. Just1Shop will open the right dashboard automatically.',
            style: UITextStyles.bodyMedium.copyWith(
              color: UIConstants.textSecondary,
            ),
          ),
          const SizedBox(height: UIConstants.paddingL),
          _buildPhoneInputSection(context, state),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _buildBrandMark(compact: true, dark: true),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.paddingS,
            vertical: UIConstants.paddingXXS,
          ),
          decoration: BoxDecoration(
            color: UIConstants.primaryLight,
            borderRadius: BorderRadius.circular(UIConstants.radiusRound),
          ),
          child: Text(
            'Under 24h',
            style: UITextStyles.labelMedium.copyWith(
              color: UIConstants.primaryDark,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrandMark({bool compact = false, bool dark = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Just1ShopLogo(size: compact ? 46 : 54),
        const SizedBox(width: UIConstants.paddingS),
        Text(
          'Just1Shop',
          style: (compact
                  ? UITextStyles.headlineSmall
                  : UITextStyles.headlineLarge)
              .copyWith(
            color: dark ? UIConstants.inkColor : Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInputSection(BuildContext context, AuthState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: !_isOtpSent
              ? Column(
                  key: const ValueKey('phone'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mobile number', style: UITextStyles.labelLarge),
                    const SizedBox(height: UIConstants.paddingS),
                    _buildPhoneInputField(),
                    const SizedBox(height: UIConstants.paddingS),
                    Text(
                      'Owner, Admin, Delivery, and User access is detected from the mobile number after OTP. If this is a Firebase test number, use the test OTP configured in Firebase.',
                      style: UITextStyles.bodySmall.copyWith(
                        color: UIConstants.textSecondary,
                      ),
                    ),
                    const SizedBox(height: UIConstants.paddingL),
                    _buildGradientButton('Send OTP', () => _sendOtp(context)),
                  ],
                )
              : Column(
                  key: const ValueKey('otp'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('6-digit OTP', style: UITextStyles.labelLarge),
                    const SizedBox(height: UIConstants.paddingS),
                    _buildOtpInputField(),
                    const SizedBox(height: UIConstants.paddingL),
                    _buildGradientButton(
                      'Verify OTP',
                      () => _verifyOtp(context),
                    ),
                    const SizedBox(height: UIConstants.paddingM),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : () => _sendOtp(context),
                        child: const Text('Resend OTP'),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: _isLoading ? null : _resetOtpState,
                        child: const Text('Change Phone Number'),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildPhoneInputField() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: UIConstants.backgroundColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusL),
        border: Border.all(color: UIConstants.borderColor),
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
            height: 26,
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        hintText: '000000',
        hintStyle: UITextStyles.headlineLarge.copyWith(
          color: UIConstants.textTertiary,
          letterSpacing: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: const BorderSide(color: UIConstants.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: const BorderSide(color: UIConstants.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: const BorderSide(color: UIConstants.aiBlue, width: 2),
        ),
        counterText: '',
        filled: true,
        fillColor: UIConstants.backgroundColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: UIConstants.paddingL),
      ),
      style: UITextStyles.headlineLarge.copyWith(letterSpacing: 10),
    );
  }

  Widget _buildGradientButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _isLoading ? null : UIConstants.actionGradient,
          color: _isLoading ? UIConstants.textTertiary : null,
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          boxShadow: [
            if (!_isLoading)
              BoxShadow(
                color: UIConstants.primaryColor.withOpacity(0.28),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.radiusL),
            ),
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
                  label,
                  style: UITextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
        ),
      ),
    );
  }

  void _sendOtp(BuildContext context) {
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phone)) {
      _showError('Please enter a valid Indian mobile number');
      return;
    }

    setState(() => _isLoading = true);
    final phoneNumber = _selectedCountryCode + phone;
    setState(() {
      _verificationId = null;
      _phoneNumber = phoneNumber;
      _isOtpSent = false;
      _otpController.clear();
    });
    context.read<AuthBloc>().add(
          VerifyPhoneNumber(
            phoneNumber,
            (credential) {},
            (exception) {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            },
            (verificationId, resendToken) {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            },
            (verificationId) {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            },
          ),
        );
  }

  void _verifyOtp(BuildContext context) {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      _showError('Please enter a valid 6-digit OTP');
      return;
    }

    if (_verificationId == null) {
      _showError('Verification ID not found. Please try again.');
      return;
    }

    setState(() => _isLoading = true);

    context.read<AuthBloc>().add(
          SignInWithPhone(
            _phoneNumber ?? _selectedCountryCode + _phoneController.text,
            _verificationId!,
            otp,
          ),
        );
  }

  void _resetOtpState() {
    setState(() {
      _isOtpSent = false;
      _isLoading = false;
      _verificationId = null;
      _phoneNumber = null;
      _otpController.clear();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: UIConstants.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: UIConstants.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
