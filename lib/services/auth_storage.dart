import 'dart:convert';
import 'dart:developer' as developer;

import 'package:bcrypt/bcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/account.dart';
import '../models/family_member.dart';
import '../models/user.dart';
import 'local_database.dart';

class AuthStorage {
  static const String _sessionKey = 'localdb.session.v2';

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
    final db = LocalDatabase.instance;
    final dbInstance = await db.database;
    final rows = await dbInstance.query('accounts', limit: 1);
    return rows.isNotEmpty;
  }

  static Future<({bool ok, Session? session, String? message})> loginUser({
    required String email,
    required String mobile,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedMobile = mobile.trim();
    final identifier = trimmedEmail.isNotEmpty ? trimmedEmail : trimmedMobile;

    if (identifier.isEmpty || password.isEmpty) {
      return (
        ok: false,
        session: null,
        message: 'Please enter email or mobile number and password.'
      );
    }

    if (trimmedEmail.isNotEmpty && !trimmedEmail.contains('@')) {
      // If it looks like a phone or user ID, don't reject it yet
      if (!RegExp(r'^\d{10,15}$').hasMatch(trimmedEmail)) {
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
      final db = LocalDatabase.instance;

      // Find account by email or phone
      final dbInstance = await db.database;
      final accountRows = await dbInstance.query(
        'accounts',
        where: 'email = ? AND phone = ?',
        whereArgs: [trimmedEmail.toLowerCase(), trimmedMobile],
      );

      if (accountRows.isEmpty) {
        return (
          ok: false,
          session: null,
          message: 'Account not found. Please sign up.'
        );
      }

      final account = Account.fromMap(accountRows.first);
      final storedHash = account.passwordHash;

      // Verify password
      final passwordOk = storedHash.startsWith(r'$2')
          ? BCrypt.checkpw(password, storedHash)
          : storedHash == password;

      if (!passwordOk) {
        return (ok: false, session: null, message: 'Invalid credentials');
      }

      // Get member details
      final member = await db.getFamilyMemberById(account.memberId);
      if (member == null) {
        return (
          ok: false,
          session: null,
          message: 'Member not found. Please contact support.'
        );
      }

      final displayName = member.name.trim().isNotEmpty
          ? member.name
          : (member.email?.trim().isNotEmpty ?? false)
              ? member.email!
              : (member.phone?.trim().isNotEmpty ?? false)
                  ? member.phone!
                  : 'User';
      final session = Session(
        userId: account.accountId, // For backward compatibility
        accountId: account.accountId,
        email: member.email ?? '',
        name: displayName,
        mobile: member.phone ?? '',
        memberId: member.memberId,
      );
      await _saveSession(session);

      return (ok: true, session: session, message: null);
    } catch (e) {
      developer.log('Login error: $e', name: 'AuthStorage');
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

    if (identifier.isEmpty || newPassword.isEmpty) {
      return (
        ok: false,
        message: 'Please provide email/mobile and new password.',
      );
    }

    try {
      final db = LocalDatabase.instance;
      final dbInstance = await db.database;

      // Find account
      final accountRows = await dbInstance.query(
        'accounts',
        where: 'emailOrPhone = ?',
        whereArgs: [identifier.toLowerCase()],
      );

      if (accountRows.isEmpty) {
        return (ok: false, message: 'No user found for that email/mobile.');
      }

      final account = Account.fromMap(accountRows.first);
      final hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

      // Update password
      await dbInstance.update(
        'accounts',
        {'passwordHash': hashedPassword},
        where: 'accountId = ?',
        whereArgs: [account.accountId],
      );

      return (ok: true, message: null);
    } catch (e) {
      developer.log('Reset password error: $e', name: 'AuthStorage');
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
      return (
        ok: false,
        session: null,
        message: 'Please fill all required fields.'
      );
    }

    if (trimmedEmail.isNotEmpty && !trimmedEmail.contains('@')) {
      return (ok: false, session: null, message: 'Please enter a valid email.');
    }

    if (trimmedMobile.isNotEmpty && !_isValidMobile(trimmedMobile)) {
      return (
        ok: false,
        session: null,
        message: 'Please enter a valid mobile number.'
      );
    }

    try {
      final db = LocalDatabase.instance;
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      String? accountId;
      try {
        // Try to activate a pending member first
        accountId = await db.signup(
          trimmedName,
          trimmedEmail,
          trimmedMobile,
          hashedPassword,
        );
      } on Exception catch (e) {
        if (e.toString().contains('Account already exists')) {
          return (
            ok: false,
            session: null,
            message: 'Account already exists. Please login.'
          );
        }
        // Other exceptions during signup attempt should be reported.
        developer.log('Error during signup activation: $e',
            name: 'AuthStorage');
        return (
          ok: false,
          session: null,
          message: 'An error occurred during signup.'
        );
      }

      if (accountId == null) {
        return (
          ok: false,
          session: null,
          message:
              'No matching family profile found. Ask the family admin to add you first.'
        );
      }

      // If we have an accountId either from activation or creation, create session.
      final account = await db.getAccountById(accountId);
      final member = await db.getFamilyMemberById(account!.memberId);
      if (member != null && member.name.trim().isEmpty && trimmedName.isNotEmpty) {
        await db.updateFamilyMember(member.copyWith(name: trimmedName));
      }
      final updatedMember =
          await db.getFamilyMemberById(account.memberId);
      final displayName =
          (updatedMember?.name.trim().isNotEmpty ?? false)
              ? updatedMember!.name
              : trimmedName;

      final session = Session(
        userId: accountId,
        accountId: accountId,
        email: updatedMember?.email ?? trimmedEmail,
        name: displayName,
        mobile: updatedMember?.phone ?? trimmedMobile,
        memberId: account.memberId,
      );
      await _saveSession(session);

      return (ok: true, session: session, message: null);
    } catch (e) {
      developer.log('Signup error: $e', name: 'AuthStorage');
      return (
        ok: false,
        session: null,
        message: 'An error occurred during signup: ${e.toString()}'
      );
    }
  }

  static String _generateAccountId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final random = (DateTime.now().microsecond % 10000).toRadixString(36);
    return 'ACC-$timestamp-$random'.toUpperCase();
  }

  static String _generateFamilyId() {
    final rand =
        (DateTime.now().microsecond % 10000).toRadixString(36).toUpperCase();
    final time =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    return 'FAM-$time-$rand';
  }

  static String _generateMemberId() {
    final rand =
        (DateTime.now().microsecond % 10000).toRadixString(36).toUpperCase();
    final time =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    return 'F-$time-$rand';
  }

  static bool _isValidMobile(String value) {
    final trimmed = value.trim();
    return RegExp(r'^\d{10,15}$').hasMatch(trimmed);
  }

  static Future<void> _saveSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }
}
