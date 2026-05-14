// lib/presentation/customer/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../presentation/blocs/auth/auth_bloc.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _verificationId;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is PhoneVerificationSuccess) {
            setState(() {
              _isOtpSent = true;
              _verificationId = state.verificationId;
              _isLoading = false;
            });
          } else if (state is AuthError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is PhoneVerificationError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Welcome to Just1Shop',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fresh groceries delivered in 10-30 mins',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 48),
                if (!_isOtpSent) ...[
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'Enter your 10-digit phone number',
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    validator: Validators.validatePhone,
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Send OTP',
                    isLoading: _isLoading,
                    onPressed: _sendOtp,
                  ),
                ] else ...[
                  CustomTextField(
                    controller: _otpController,
                    label: 'OTP',
                    hint: 'Enter 6-digit OTP',
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter OTP';
                      }
                      if (value.length != 6) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    },
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    validator: Validators.validateName,
                    prefixIcon: const Icon(Icons.person),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Verify & Continue',
                    isLoading: _isLoading,
                    onPressed: _verifyOtp,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isOtpSent = false;
                        _otpController.clear();
                        _nameController.clear();
                      });
                    },
                    child: const Text('Change Phone Number'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(
          VerifyPhoneNumber(
            '+91$phone',
            (credential) async {
              // Auto verification
              final userCredential =
                  await FirebaseAuth.instance.signInWithCredential(credential);
              if (userCredential.user != null) {
                // Create user profile if needed
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            (error) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error.message ?? 'Verification failed')),
              );
            },
            (verificationId, forceResendingToken) {
              setState(() {
                _isOtpSent = true;
                _verificationId = verificationId;
                _isLoading = false;
              });
            },
            (verificationId) {
              // Auto retrieval timeout
            },
          ),
        );
  }

  void _verifyOtp() {
    final otp = _otpController.text.trim();
    final name = _nameController.text.trim();

    if (otp.isEmpty || otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification ID not found')),
      );
      return;
    }

    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(
          SignInWithPhone(
            _phoneController.text.trim(),
            _verificationId!,
            otp,
          ),
        );
  }
}
