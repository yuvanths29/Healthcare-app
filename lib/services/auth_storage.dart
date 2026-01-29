import 'dart:convert';

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

  static Future<({bool ok, Session? session, String? message})> loginUser({
    required String email,
    required String password,
  }) async {
    final identifier = email.trim();
    final lowerEmail = identifier.toLowerCase();

    if (identifier.isEmpty || password.isEmpty) {
      return (
        ok: false,
        session: null,
        message: 'Please enter email/user id and password.'
      );
    }

    final users = await _readUsers();
    User? user = users[lowerEmail];

    // Check if identifier is a userId
    if (user == null) {
      user = users.values.firstWhere(
        (u) => u.userId == identifier,
        orElse: () => User(userId: '', name: '', email: '', password: ''),
      );
      if (user.userId.isEmpty) user = null;
    }

    if (user == null || user.password != password) {
      return (ok: false, session: null, message: 'Invalid credentials');
    }

    final session = Session(
      userId: user.userId,
      email: user.email,
      name: user.name,
    );
    await _saveSession(session);

    return (ok: true, session: session, message: null);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  static Future<({bool ok, String? message})> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();

    if (trimmedEmail.isEmpty || newPassword.isEmpty) {
      return (ok: false, message: 'Please provide email and new password.');
    }

    final users = await _readUsers();
    final user = users[trimmedEmail];
    if (user == null) {
      return (ok: false, message: 'No user found for that email.');
    }

    users[trimmedEmail] = User(
      userId: user.userId,
      name: user.name,
      email: user.email,
      password: newPassword,
    );

    await _writeUsers(users);

    return (ok: true, message: null);
  }

  static Future<({bool ok, String? userId, String? message})> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    final trimmedName = name.trim();

    if (trimmedName.isEmpty || trimmedEmail.isEmpty || password.isEmpty) {
      return (ok: false, userId: null, message: 'Please fill all fields.');
    }

    final users = await _readUsers();
    if (users.containsKey(trimmedEmail)) {
      return (
        ok: false,
        userId: null,
        message: 'User already exists. Please login.'
      );
    }

    final userId = _createUserId();
    users[trimmedEmail] = User(
      userId: userId,
      name: trimmedName,
      email: trimmedEmail,
      password: password,
    );

    await _writeUsers(users);

    final session = Session(
      userId: userId,
      email: trimmedEmail,
      name: trimmedName,
    );
    await _saveSession(session);

    return (ok: true, userId: userId, message: null);
  }

  static String _createUserId() {
    final rand =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    final random =
        (DateTime.now().microsecond % 10000).toRadixString(36).toUpperCase();
    return 'U-$rand-$random';
  }

  static Future<Map<String, User>> _readUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null) return {};

    try {
      final Map<String, dynamic> parsed = jsonDecode(raw);
      final Map<String, User> users = {};

      parsed.forEach((email, userData) {
        if (userData is Map<String, dynamic>) {
          users[email] = User.fromJson(userData);
        }
      });

      return users;
    } catch (e) {
      return {};
    }
  }

  static Future<void> _saveSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  static Future<void> _writeUsers(Map<String, User> users) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> data = {};
    users.forEach((email, user) {
      data[email] = user.toJson();
    });
    await prefs.setString(_usersKey, jsonEncode(data));
  }
}
