import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_service.dart';
import 'login_page.dart';
import '../screens/home_screen.dart';
import '../screens/goal_setup_screen.dart';
import '../services/firestore_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final authService = AuthService();
  final firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return const LoginPage();
          }

          return FutureBuilder<Map<String, dynamic>?>(
            future: firestoreService.getUserProfile(user.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final profile = profileSnapshot.data;
              final setupComplete = profile?['setupComplete'] == true;

              if (!setupComplete) {
                return const GoalSetupScreen();
              }

              return const HomeScreen();
            },
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
