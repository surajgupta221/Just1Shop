// lib/presentation/blocs/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SignInWithPhone extends AuthEvent {
  final String phoneNumber;
  final String verificationId;
  final String smsCode;

  const SignInWithPhone(
    this.phoneNumber,
    this.verificationId,
    this.smsCode,
  );

  @override
  List<Object?> get props => [
        phoneNumber,
        verificationId,
        smsCode,
      ];
}

class VerifyPhoneNumber extends AuthEvent {
  final String phoneNumber;
  final Function(PhoneAuthCredential) verificationCompleted;
  final Function(FirebaseAuthException) verificationFailed;
  final Function(String, int?) codeSent;
  final Function(String) codeAutoRetrievalTimeout;

  const VerifyPhoneNumber(
    this.phoneNumber,
    this.verificationCompleted,
    this.verificationFailed,
    this.codeSent,
    this.codeAutoRetrievalTimeout,
  );

  @override
  List<Object?> get props => [phoneNumber];
}

class CreateUserProfile extends AuthEvent {
  final UserModel user;

  const CreateUserProfile(this.user);

  @override
  List<Object?> get props => [user];
}

class LoadUserProfile extends AuthEvent {
  final String userId;

  const LoadUserProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SignOut extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final UserModel? userProfile;

  const AuthAuthenticated(this.user, this.userProfile);

  @override
  List<Object?> get props => [user, userProfile];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class PhoneVerificationLoading extends AuthState {}

class PhoneVerificationSuccess extends AuthState {
  final String verificationId;
  final String phoneNumber;

  const PhoneVerificationSuccess(this.verificationId, this.phoneNumber);

  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

class PhoneVerificationError extends AuthState {
  final String message;

  const PhoneVerificationError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInWithPhone>(_onSignInWithPhone);
    on<VerifyPhoneNumber>(_onVerifyPhoneNumber);
    on<CreateUserProfile>(_onCreateUserProfile);
    on<LoadUserProfile>(_onLoadUserProfile);
    on<SignOut>(_onSignOut);
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = _authRepository.getCurrentUser();
      if (user != null) {
        final userProfile = await _authRepository.getUserProfile(user.uid);
        emit(AuthAuthenticated(user, userProfile));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithPhone(
      SignInWithPhone event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authRepository.signInWithPhone(
        event.phoneNumber,
        event.verificationId,
        event.smsCode,
      );

      if (userCredential != null && userCredential.user != null) {
        final uid = userCredential.user!.uid;

        final phoneWithoutCountryCode =
            AppConstants.normalizeIndianMobile(event.phoneNumber);
        final isConfiguredOwner = AppConstants.isOwnerPhone(event.phoneNumber);

        // Check if user profile exists
        var userProfile = await _authRepository.getUserProfile(uid);

        // Fallback lookup for manually pre-created profiles keyed by phone.
        final phoneProfile = userProfile ??
            await _authRepository.getUserProfileByPhone(event.phoneNumber);

        if (phoneProfile == null) {
          userProfile = UserModel(
            id: uid,
            name: isConfiguredOwner ? 'Just1Shop Owner' : '',
            phone: phoneWithoutCountryCode,
            email: null,
            role: isConfiguredOwner
                ? AppConstants.roleOwner
                : AppConstants.roleCustomer,
            addresses: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _authRepository.createUserProfile(userProfile);
        } else {
          userProfile = phoneProfile;
          if (isConfiguredOwner && userProfile.role != AppConstants.roleOwner) {
            userProfile = userProfile.copyWith(
              id: uid,
              name: userProfile.name.trim().isEmpty
                  ? 'Just1Shop Owner'
                  : userProfile.name,
              phone: phoneWithoutCountryCode,
              role: AppConstants.roleOwner,
              updatedAt: DateTime.now(),
            );
            await _authRepository.createUserProfile(userProfile);
            emit(AuthAuthenticated(userCredential.user!, userProfile));
            return;
          }

          if (userProfile.id != uid) {
            userProfile = userProfile.copyWith(
              id: uid,
              phone: phoneWithoutCountryCode,
              updatedAt: DateTime.now(),
            );
            await _authRepository.createUserProfile(userProfile);
          }
        }

        emit(AuthAuthenticated(userCredential.user!, userProfile));
      } else {
        emit(const AuthError('Sign in failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyPhoneNumber(
      VerifyPhoneNumber event, Emitter<AuthState> emit) async {
    emit(PhoneVerificationLoading());
    try {
      // Create wrapper callbacks that emit states
      void onVerificationCompleted(PhoneAuthCredential credential) {
        event.verificationCompleted(credential);
      }

      void onVerificationFailed(FirebaseAuthException e) {
        emit(PhoneVerificationError(_friendlyFirebaseAuthMessage(e)));
        event.verificationFailed(e);
      }

      void onCodeSent(String verificationId, int? resendToken) {
        // Emit success state with verificationId and phoneNumber
        emit(PhoneVerificationSuccess(verificationId, event.phoneNumber));
        event.codeSent(verificationId, resendToken);
      }

      void onCodeAutoRetrievalTimeout(String verificationId) {
        event.codeAutoRetrievalTimeout(verificationId);
      }

      await _authRepository.verifyPhoneNumber(
        event.phoneNumber,
        onVerificationCompleted,
        onVerificationFailed,
        onCodeSent,
        onCodeAutoRetrievalTimeout,
      );
    } catch (e) {
      emit(PhoneVerificationError(e.toString()));
    }
  }

  String _friendlyFirebaseAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Please enter a valid 10-digit Indian mobile number.';
      case 'operation-not-allowed':
        return 'Phone sign-in is not enabled in Firebase Authentication. Enable Authentication > Sign-in method > Phone.';
      case 'too-many-requests':
        return 'Too many OTP requests. Please wait and try again later.';
      case 'quota-exceeded':
        return 'OTP quota is exhausted for this Firebase project.';
      case 'captcha-check-failed':
      case 'invalid-verification-id':
        return 'Phone verification failed. Complete the reCAPTCHA and request OTP again.';
      case 'invalid-app-credential':
        return 'Firebase rejected the web app verification. Add just1shop.web.app and just1shop.com in Authentication > Settings > Authorized domains.';
      case 'session-expired':
        return 'OTP session expired. Please request OTP again and enter the latest code.';
      case 'app-not-authorized':
      case 'missing-client-identifier':
        return 'This Android app is not authorised for Firebase Phone Auth. Add the app SHA-1/SHA-256 certificate in Firebase, download the updated google-services.json, then rebuild the APK.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Enter the latest code from SMS. If this number is configured as a Firebase test number, SMS is not sent and you must use the test code set in Firebase.';
      case 'network-request-failed':
        return 'Network error while sending OTP. Check internet connection and try again.';
      default:
        return e.message ?? 'Phone verification failed. Please try again.';
    }
  }

  Future<void> _onCreateUserProfile(
      CreateUserProfile event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.createUserProfile(event.user);
      final user = _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user, event.user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLoadUserProfile(
      LoadUserProfile event, Emitter<AuthState> emit) async {
    try {
      final user = _authRepository.getCurrentUser();
      final userProfile = await _authRepository.getUserProfile(event.userId);
      if (user != null) {
        emit(AuthAuthenticated(user, userProfile));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
