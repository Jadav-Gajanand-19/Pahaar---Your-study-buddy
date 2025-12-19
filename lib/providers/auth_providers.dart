import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/features/auth/data/auth_service.dart';

// Provides an instance of our AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provides a stream of the user's authentication state
// This is the most important provider for auth.
final authStateChangeProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});