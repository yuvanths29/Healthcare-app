import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import 'local_auth_service.dart';

class AuthStorage {
  static const String _sessionKey = 'localdb.session.v1';
  static bool _dbInitialized = false;

  static Future<Session?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;

    try {
      final Map<String, dynamic> parsed = jsonDecode(raw);
      return Session.fromJson(parsed);
    } catch (e) {
      return null;
    }
  }

  static Future<void> initializeDatabase() async {
    if (_dbInitialized) return;
    try {
      await LocalAuthService().initialize();
      _dbInitialized = true;
    } catch (e) {
      print('Error initializing local auth database: $e');
    }
  }

  static Future<({bool ok, Session? session, String? message})> loginUser({
    required String email,
    required String password,
  }) async {
    await initializeDatabase();

    final identifier = email.trim();
    final lowerEmail = identifier.toLowerCase();

    if (identifier.isEmpty || password.isEmpty) {
      return (
        ok: false,
        session: null,
        message: 'Please enter email/user id and password.'
      );
    }

    try {
      final authService = LocalAuthService();

      // Try to authenticate with email and password
      User? user = await authService.authenticateUser(lowerEmail, password);

      // If not found by email, try by userId
      if (user == null) {
        user = await authService.getUserById(identifier);
        if (user != null && user.password != password) {
          user = null;
        }
      }

      if (user == null) {
        return (ok: false, session: null, message: 'Invalid email or password');
      }

      final session = Session(
        userId: user.userId,
        email: user.email,
        name: user.name,
      );
      await _saveSession(session);

      return (ok: true, session: session, message: null);
    } catch (e) {
      print('Login error: $e');
      return (
        ok: false,
        session: null,
        message: 'An error occurred during login'
      );
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  static Future<({bool ok, String? message})> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    await initializeDatabase();

    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedEmail.isEmpty || newPassword.isEmpty) {
      return (ok: false, message: 'Please provide email and new password.');
    }

    try {
      final authService = LocalAuthService();
      final success = await authService.updatePassword(
        email: trimmedEmail,
        newPassword: newPassword,
      );

      if (!success) {
        return (ok: false, message: 'No user found for that email.');
      }

      return (ok: true, message: null);
    } catch (e) {
      print('Reset password error: $e');
      return (ok: false, message: 'An error occurred during password reset.');
    }
  }

  static Future<({bool ok, Session? session, String? message})> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    await initializeDatabase();

    final trimmedEmail = email.trim().toLowerCase();
    final trimmedName = name.trim();

    if (trimmedName.isEmpty || trimmedEmail.isEmpty || password.isEmpty) {
      return (ok: false, session: null, message: 'Please fill all fields.');
    }

    try {
      final authService = LocalAuthService();

      // Check if user already exists
      final userExists = await authService.userExists(trimmedEmail);
      if (userExists) {
        return (
          ok: false,
          session: null,
          message: 'User already exists. Please login.'
        );
      }

      // Create new user in database
      final user = await authService.createUser(
        name: trimmedName,
        email: trimmedEmail,
        password: password,
      );

      final session = Session(
        userId: user.userId,
        email: user.email,
        name: user.name,
      );
      await _saveSession(session);

      return (ok: true, session: session, message: null);
    } catch (e) {
      print('Signup error: $e');
      if (e.toString().contains('UNIQUE constraint failed')) {
        return (
          ok: false,
          session: null,
          message: 'User already exists. Please login.'
        );
      }
      return (
        ok: false,
        session: null,
        message: 'An error occurred during signup.'
      );
    }
  }

  static Future<void> _saveSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }
}
