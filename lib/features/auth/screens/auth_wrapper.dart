import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prahar/features/auth/screens/login_screen.dart';
import 'package:prahar/features/auth/screens/main_screen.dart'; // Import the new MainScreen
import 'package:prahar/providers/auth_providers.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangeProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          // THIS IS THE CRITICAL CHANGE
          return const MainScreen();
        }
        return const LoginScreen();
      },
      loading: () {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stackTrace) {
        return Scaffold(
          body: Center(
            child: Text('Something went wrong: $error'),
          ),
        );
      },
    );
  }
}