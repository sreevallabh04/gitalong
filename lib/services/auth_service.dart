import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException(this.message, {this.code});
  @override
  String toString() => 'AuthException([33m$code[0m): $message';
}

import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException(this.message, {this.code});
  @override
  String toString() => 'AuthException(\u001b[33m$code\u001b[0m): $message';
}

class AuthService {
  // Simulate a user for compatibility
  User? get currentUser => null;
  bool get isAuthenticated => false;
  Stream<User?> get authStateChanges => const Stream.empty();

  Future<void> signInWithEmailAndPassword(String email, String password) async {}
  Future<void> signOut() async {}
  Future<void> createAccount(String email, String password, String name) async {}
  Future<UserModel?> getCurrentUserProfile() async => null;
  Future<void> upsertUserProfile(UserModel user) async {}
  Future<void> updateUserRole(String userId, String newRole) async {}
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
