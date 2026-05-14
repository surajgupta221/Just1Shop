// lib/core/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  static Future<UserCredential?> signInWithPhone(
    String phoneNumber,
    String verificationId,
    String smsCode,
  ) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential =
          await FirebaseService.auth.signInWithCredential(credential);

      return userCredential;
    } catch (e) {
      throw e;
    }
  }

  static Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(PhoneAuthCredential) verificationCompleted,
    Function(FirebaseAuthException) verificationFailed,
    Function(String, int?) codeSent,
    Function(String) codeAutoRetrievalTimeout,
  ) async {
    await FirebaseService.auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  static Future<void> createUserProfile(UserModel user) async {
    try {
      await FirebaseService.usersCollection.doc(user.id).set(user.toMap());
    } catch (e) {
      throw e;
    }
  }

  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      DocumentSnapshot doc =
          await FirebaseService.usersCollection.doc(userId).get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw e;
    }
  }

  static Future<void> signOut() async {
    await FirebaseService.auth.signOut();
  }

  static User? getCurrentUser() {
    return FirebaseService.auth.currentUser;
  }
}
