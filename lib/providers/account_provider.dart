import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/account.dart';
import '../models/family_member.dart';
import '../services/local_database.dart';

final accountProvider =
    StateNotifierProvider<AccountNotifier, AsyncValue<Account?>>(
  (ref) => AccountNotifier(),
);

class AccountNotifier extends StateNotifier<AsyncValue<Account?>> {
  AccountNotifier() : super(const AsyncValue.data(null));

  Future<({bool success, String message})> createAccountForMember({
    required String memberId,
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      final db = LocalDatabase.instance;

      final member = await db.getFamilyMemberById(memberId);
      if (member == null) {
        return (success: false, message: 'Family member not found');
      }

      if (member.hasAccount) {
        return (
          success: false,
          message:
              'An account already exists for this family member. Each member can only have one account.'
        );
      }

      if (member.phone == null && member.email == null) {
        return (
          success: false,
          message:
              'This profile has no phone or email registered. Profiles without contact information cannot create accounts and remain view-only.'
        );
      }

      if (password.trim().isEmpty || password.length < 6) {
        return (
          success: false,
          message: 'Password must be at least 6 characters'
        );
      }

      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      final accountId = _generateAccountId();

      final account = Account(
        accountId: accountId,
        memberId: memberId,
        emailOrPhone: emailOrPhone,
        passwordHash: hashedPassword,
      );

      await db.createAccount(account);

      state = AsyncValue.data(account);

      return (success: true, message: 'Account created successfully');
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return (success: false, message: 'Error creating account: $e');
    }
  }

  Future<Account?> getAccountByMemberId(String memberId) async {
    try {
      final db = LocalDatabase.instance;
      return await db.getAccountByMemberId(memberId);
    } catch (e) {
      return null;
    }
  }

  Future<({Account? account, FamilyMember? member, String? error})>
      loginWithEmailOrPhone({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final db = LocalDatabase.instance;
      final members = await db.getAllFamilyMembers();

      final query = emailOrPhone.trim().toLowerCase();
      final matchingMember = members.firstWhere(
        (m) => (m.email?.trim().toLowerCase() == query ||
            m.phone?.trim().toLowerCase() == query),
        orElse: () => null as dynamic,
      ) as FamilyMember?;

      if (matchingMember == null) {
        return (account: null, member: null, error: 'Invalid credentials');
      }

      final account = await db.getAccountByMemberId(matchingMember.memberId);
      if (account == null) {
        return (account: null, member: null, error: 'Invalid credentials');
      }

      final passwordValid = BCrypt.checkpw(password, account.passwordHash);
      if (!passwordValid) {
        return (account: null, member: null, error: 'Invalid credentials');
      }

      return (account: account, member: matchingMember, error: null);
    } catch (e) {
      return (
        account: null,
        member: null,
        error: 'An error occurred during login'
      );
    }
  }

  Future<FamilyMember?> lookupFamilyMember(String phoneOrEmail) async {
    try {
      state = const AsyncValue.loading();
      final db = LocalDatabase.instance;
      final members = await db.getAllFamilyMembers();

      final query = phoneOrEmail.trim().toLowerCase();
      final matching = members.firstWhere(
        (m) => (m.phone?.trim().toLowerCase() == query ||
            m.email?.trim().toLowerCase() == query),
        orElse: () => null as dynamic,
      ) as FamilyMember?;

      return matching;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  Future<bool> verifyPassword(String accountId, String password) async {
    try {
      final db = LocalDatabase.instance;
      final account = await db.getAccountById(accountId);

      if (account == null) return false;

      return BCrypt.checkpw(password, account.passwordHash);
    } catch (e) {
      return false;
    }
  }

  String _generateAccountId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final random = (DateTime.now().microsecond % 10000).toRadixString(36);
    return 'A-$timestamp-$random'.toUpperCase();
  }
}
