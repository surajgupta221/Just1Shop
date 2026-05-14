// lib/presentation/blocs/auth/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  const SignInWithPhone(this.phoneNumber, this.verificationId, this.smsCode);

  @override
  List<Object?> get props => [phoneNumber, verificationId, smsCode];
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

  const PhoneVerificationSuccess(this.verificationId);

  @override
  List<Object?> get props => [verificationId];
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

  void _onCheckAuthStatus(
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

  void _onSignInWithPhone(
      SignInWithPhone event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final userCredential = await _authRepository.signInWithPhone(
        event.phoneNumber,
        event.verificationId,
        event.smsCode,
      );

      if (userCredential != null) {
        final userProfile =
            await _authRepository.getUserProfile(userCredential.user!.uid);
        emit(AuthAuthenticated(userCredential.user!, userProfile));
      } else {
        emit(const AuthError('Sign in failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onVerifyPhoneNumber(
      VerifyPhoneNumber event, Emitter<AuthState> emit) async {
    emit(PhoneVerificationLoading());
    try {
      await _authRepository.verifyPhoneNumber(
        event.phoneNumber,
        event.verificationCompleted,
        event.verificationFailed,
        event.codeSent,
        event.codeAutoRetrievalTimeout,
      );
    } catch (e) {
      emit(PhoneVerificationError(e.toString()));
    }
  }

  void _onCreateUserProfile(
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

  void _onLoadUserProfile(
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

  void _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
