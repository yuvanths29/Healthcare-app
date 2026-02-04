import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/auth_storage.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<Session?>>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AsyncValue<Session?>> {
  AuthNotifier() : super(const AsyncValue.loading()) {
    print('AuthNotifier: initializing, loading session...');
    _loadSession();
  }

  Future<({bool ok, String? message})> login({
    required String email,
    required String mobile,
    required String password,
  }) async {
    try {
      final identifier = email.isNotEmpty ? email : mobile;

      if (identifier.isEmpty || password.isEmpty) {
        return (
          ok: false,
          message: 'Please enter email or mobile number and password.'
        );
      }

      try {
        final result = await AuthStorage.loginUser(
          email: email,
          mobile: mobile,
          password: password,
        );

        if (result.ok && result.session != null) {
          state = AsyncValue.data(result.session);
          return (ok: true, message: null);
        }

        return (ok: false, message: result.message);
      } catch (e) {
        developer.log('Login error: $e', name: 'AuthProvider');
        return (ok: false, message: 'An error occurred during login');
      }
    } catch (e) {
      developer.log('Login error: $e', name: 'AuthProvider');
      return (ok: false, message: 'An error occurred during login');
    }
  }

  Future<void> logout() async {
    await AuthStorage.logout();
    state = const AsyncValue.data(null);
  }

  void refreshSession() {
    _loadSession();
  }

  Future<({bool ok, String? message})> signUp({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    final result = await AuthStorage.signUpUser(
      name: name,
      email: email,
      mobile: mobile,
      password: password,
    );
    if (!result.ok) {
      return (ok: false, message: result.message);
    }

    final session = result.session;
    if (session == null) {
      state = const AsyncValue.data(null);
      return (ok: false, message: 'Signup failed. Please try again.');
    }

    state = AsyncValue.data(session);
    return (ok: true, message: null);
  }

  Future<void> _loadSession() async {
    try {
      // Add a timeout to prevent infinite loading
      final session = await AuthStorage.getSession().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print(
              'AuthNotifier: Auth initialization timeout - proceeding without session');
          developer.log(
              'Auth initialization timeout - proceeding without session',
              name: 'AuthProvider');
          return null;
        },
      );
      print('AuthNotifier: Session loaded: $session');
      state = AsyncValue.data(session);
    } catch (e) {
      print('AuthNotifier: Auth error: $e');
      developer.log('Auth error: $e', name: 'AuthProvider');
      // On error, set state to null instead of error to allow app to continue
      state = const AsyncValue.data(null);
    }
  }
}
