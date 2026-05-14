// lib/data/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../core/services/auth_service.dart';

class AuthRepository {
  // No longer needs an instance since AuthService methods are static
  AuthRepository();

  Future<UserCredential?> signInWithPhone(
      String phoneNumber, String verificationId, String smsCode) async {
    return await AuthService.signInWithPhone(
        phoneNumber, verificationId, smsCode);
  }

  void sendOTP() {
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91XXXXXXXXXX",
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {
        print(e.message);
      },
      codeSent: (String verificationId, int? resendToken) {
        print("OTP Sent");
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(PhoneAuthCredential) verificationCompleted,
    Function(FirebaseAuthException) verificationFailed,
    Function(String, int?) codeSent,
    Function(String) codeAutoRetrievalTimeout,
  ) async {
    return await AuthService.verifyPhoneNumber(
      phoneNumber,
      verificationCompleted,
      verificationFailed,
      codeSent,
      codeAutoRetrievalTimeout,
    );
  }

  Future<void> createUserProfile(UserModel user) async {
    return await AuthService.createUserProfile(user);
  }

  Future<UserModel?> getUserProfile(String userId) async {
    return await AuthService.getUserProfile(userId);
  }

  Future<void> signOut() async {
    return await AuthService.signOut();
  }

  User? getCurrentUser() {
    return AuthService.getCurrentUser();
  }

  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();
}
