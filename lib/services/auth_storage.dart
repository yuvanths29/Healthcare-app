import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';

class AuthStorage {
  static const String _usersKey = 'localdb.users.v1';
  static const String _sessionKey = 'localdb.session.v1';

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

  static Future<bool> hasAnyUser() async {
    final users = await _getUsers();
    return users.isNotEmpty;
  }

  static Future<({bool ok, Session? session, String? message})> loginUser({
    required String email,
    required String mobile,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedMobile = mobile.trim();
    final identifier = trimmedEmail.isNotEmpty ? trimmedEmail : trimmedMobile;
    final lowerIdentifier = identifier.toLowerCase();

    if (identifier.isEmpty || password.isEmpty) {
      return (
        ok: false,
        session: null,
        message: 'Please enter email or mobile number and password.'
      );
    }

    if (trimmedEmail.isNotEmpty && !trimmedEmail.contains('@')) {
      // If it looks like a phone or user ID, don't reject it yet
      if (!RegExp(r'^\d{10,15}$').hasMatch(trimmedEmail) &&
          !trimmedEmail.toUpperCase().startsWith('U-')) {
        return (
          ok: false,
          session: null,
          message: 'Please enter a valid email.'
        );
      }
    }

    if (trimmedMobile.isNotEmpty && !_isValidMobile(trimmedMobile)) {
      return (
        ok: false,
        session: null,
        message: 'Please enter a valid mobile number.'
      );
    }

    try {
      final users = await _getUsers();
      final User? user = users.cast<User?>().firstWhere(
            (u) =>
                u != null &&
                (u.email.toLowerCase() == lowerIdentifier ||
                    u.mobile == identifier ||
                    u.userId.toUpperCase() == lowerIdentifier),
            orElse: () => null,
          );

      if (user == null) {
        return (
          ok: false,
          session: null,
          message: 'Account not found. Please sign up.'
        );
      }

      final stored = user.password;
      final passwordOk = stored.startsWith(r'$2')
          ? BCrypt.checkpw(password, stored)
          : stored == password;

      if (!passwordOk) {
        return (ok: false, session: null, message: 'Invalid credentials');
      }

      // If both email and mobile were entered, ensure they belong to same account
      if (trimmedEmail.isNotEmpty && trimmedMobile.isNotEmpty) {
        if (user.email.toLowerCase() != trimmedEmail.toLowerCase() &&
            user.mobile != trimmedMobile) {
          return (ok: false, session: null, message: 'Invalid credentials');
        }
      }

      final session = Session(
        userId: user.userId,
        email: user.email,
        name: user.name,
        mobile: user.mobile,
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
    final identifier = email.trim();
    final lowerIdentifier = identifier.toLowerCase();

    if (identifier.isEmpty || newPassword.isEmpty) {
      return (
        ok: false,
        message: 'Please provide email/mobile and new password.',
      );
    }

    try {
      final users = await _getUsers();
      final index = users.indexWhere(
        (u) =>
            u.email.toLowerCase() == lowerIdentifier || u.mobile == identifier,
      );

      if (index < 0) {
        return (ok: false, message: 'No user found for that email/mobile.');
      }

      final existing = users[index];
      final hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());
      users[index] = User(
        userId: existing.userId,
        name: existing.name,
        email: existing.email,
        mobile: existing.mobile,
        password: hashedPassword,
      );
      await _saveUsers(users);

      return (ok: true, message: null);
    } catch (e) {
      print('Reset password error: $e');
      return (ok: false, message: 'An error occurred during password reset.');
    }
  }

  static Future<void> saveSession(Session session) async {
    await _saveSession(session);
  }

  static Future<({bool ok, Session? session, String? message})> signUpUser({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedName = name.trim();
    final trimmedMobile = mobile.trim();

    if (trimmedName.isEmpty ||
        trimmedEmail.isEmpty ||
        trimmedMobile.isEmpty ||
        password.isEmpty) {
      return (ok: false, session: null, message: 'Please fill all fields.');
    }

    if (!trimmedEmail.contains('@')) {
      return (ok: false, session: null, message: 'Please enter a valid email.');
    }

    if (!_isValidMobile(trimmedMobile)) {
      return (
        ok: false,
        session: null,
        message: 'Please enter a valid mobile number.'
      );
    }

    try {
      final users = await _getUsers();

      final emailExists =
          users.any((u) => u.email.toLowerCase() == trimmedEmail);
      if (emailExists) {
        return (
          ok: false,
          session: null,
          message: 'User already exists. Please login.'
        );
      }

      final mobileExists = users.any((u) => u.mobile == trimmedMobile);
      if (mobileExists) {
        return (
          ok: false,
          session: null,
          message: 'Mobile number already exists. Please login.',
        );
      }

      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      final user = User(
        userId: _generateUserId(),
        name: trimmedName,
        email: trimmedEmail,
        mobile: trimmedMobile,
        password: hashedPassword,
      );

      users.add(user);
      await _saveUsers(users);

      final session = Session(
        userId: user.userId,
        email: user.email,
        name: user.name,
        mobile: user.mobile,
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

  static String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final random = (DateTime.now().microsecond % 10000).toRadixString(36);
    return 'U-$timestamp-$random'.toUpperCase();
  }

  static Future<List<User>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final parsed = jsonDecode(raw);
      if (parsed is! List) return [];
      return parsed
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .map(User.fromJson)
          .toList(growable: true);
    } catch (_) {
      return [];
    }
  }

  static bool _isValidMobile(String value) {
    final trimmed = value.trim();
    return RegExp(r'^\d{10,15}$').hasMatch(trimmed);
  }

  static Future<void> _saveSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  static Future<void> _saveUsers(List<User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, raw);
  }
}
