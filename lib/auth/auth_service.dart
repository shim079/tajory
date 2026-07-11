import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService.register error: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService.register error: $e');
      rethrow;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('AuthService.login error: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('AuthService.login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('AuthService.logout error: $e');
      rethrow;
    }
  }
}
