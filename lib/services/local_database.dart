import 'dart:async';
import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/account.dart';
import '../models/family_member.dart';

/// Result of checking if an account exists
enum AccountCheckResult { exists, pending, notFound }

class LocalDatabase {
  static const _databaseName = 'healthcare_app.db';
  static const _databaseVersion = 3;

  static final LocalDatabase instance = LocalDatabase._privateConstructor();
  Database? _database;

  LocalDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Check if account exists by email/phone
  /// Returns: exists, pending (family member found), or notFound
  Future<AccountCheckResult> checkAccountExists(
      String email, String phone) async {
    final db = await database;

    // Check if account with this email/phone exists
    final accountRows = await db.query(
      'accounts',
      where: 'email = ? OR phone = ? OR emailOrPhone = ? OR emailOrPhone = ?',
      whereArgs: [email, phone, email, phone],
    );
    if (accountRows.isNotEmpty) {
      return AccountCheckResult.exists;
    }

    // Check if pending family member with this email/phone exists
    final memberRows = await db.query(
      'family_members',
      where: '(email = ? OR phone = ?) AND hasAccount = 0',
      whereArgs: [email, phone],
    );
    if (memberRows.isNotEmpty) {
      return AccountCheckResult.pending;
    }

    return AccountCheckResult.notFound;
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) await db.close();
    _database = null;
  }

  Future<void> createAccount(Account account) async {
    final db = await database;
    await db.transaction((txn) async {
      final memberRows = await txn.query(
        'family_members',
        where: 'memberId = ?',
        whereArgs: [account.memberId],
      );
      if (memberRows.isEmpty) {
        throw StateError(
            'No FamilyMember found for memberId=${account.memberId}');
      }

      final existing = await txn.query(
        'accounts',
        where: 'memberId = ?',
        whereArgs: [account.memberId],
      );
      if (existing.isNotEmpty) {
        throw StateError(
            'Account already exists for memberId=${account.memberId}');
      }

      final member = memberRows.first;
      final email = member['email'] as String?;
      final phone = member['phone'] as String?;
      await txn.insert('accounts', {
        ...account.toMap(),
        'email': email,
        'phone': phone,
      });

      await txn.update(
        'family_members',
        {'hasAccount': 1},
        where: 'memberId = ?',
        whereArgs: [account.memberId],
      );
    });
  }

  /// DEPRECATED: Use signup() instead
  /// Create account by linking to existing family member (via email/phone)
  /// Returns SignupResult with success status and optional accountId
  Future<SignupResult> createAccountWithEmailPhone(
    String email,
    String phone,
    String passwordHash,
  ) async {
    final db = await database;

    if (email.isEmpty || phone.isEmpty) {
      return SignupResult(false, null, 'Email and phone required');
    }

    return await db.transaction((txn) async {
      // Find family member with matching email or phone
      final memberRows = await txn.query(
        'family_members',
        where: '(email = ? OR phone = ?) AND hasAccount = 0',
        whereArgs: [email, phone],
      );

      if (memberRows.isEmpty) {
        return SignupResult(false, null, 'No pending family member found');
      }

      final memberId = memberRows.first['memberId'] as String;
      final accountId = _generateId();

      // Create account
      await txn.insert('accounts', {
        'accountId': accountId,
        'memberId': memberId,
        'emailOrPhone': email,
        'email': email,
        'phone': phone,
        'passwordHash': passwordHash,
      });

      // Update family member to mark as having account
      await txn.update(
        'family_members',
        {'hasAccount': 1},
        where: 'memberId = ?',
        whereArgs: [memberId],
      );

      return SignupResult(true, accountId, 'Success');
    });
  }

  Future<void> deleteAccount(String accountId) async {
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.query(
        'accounts',
        where: 'accountId = ?',
        whereArgs: [accountId],
      );
      if (rows.isEmpty) return;

      final memberId = rows.first['memberId'] as String;

      await txn.delete(
        'accounts',
        where: 'accountId = ?',
        whereArgs: [accountId],
      );

      await txn.update(
        'family_members',
        {'hasAccount': 0},
        where: 'memberId = ?',
        whereArgs: [memberId],
      );
    });
  }

  Future<void> deleteFamilyMember(String memberId) async {
    final db = await database;
    await db.delete(
      'family_members',
      where: 'memberId = ?',
      whereArgs: [memberId],
    );
  }

  Future<Account?> getAccountById(String accountId) async {
    final db = await database;
    final rows = await db.query(
      'accounts',
      where: 'accountId = ?',
      whereArgs: [accountId],
    );
    if (rows.isEmpty) return null;
    return Account.fromMap(rows.first);
  }

  Future<Account?> getAccountByMemberId(String memberId) async {
    final db = await database;
    final rows = await db.query(
      'accounts',
      where: 'memberId = ?',
      whereArgs: [memberId],
    );
    if (rows.isEmpty) return null;
    return Account.fromMap(rows.first);
  }

  Future<FamilyMember?> getFamilyMemberById(String memberId) async {
    final db = await database;
    final rows = await db.query(
      'family_members',
      where: 'memberId = ?',
      whereArgs: [memberId],
    );
    if (rows.isEmpty) return null;
    return FamilyMember.fromMap(rows.first);
  }

  /// PRIMARY METHOD: Get family members for current account
  /// Finds current user's memberId from accountId, gets their familyId,
  /// and returns ALL family_members with same familyId EXCEPT current user
  Future<List<FamilyMember>> getFamilyMembersForCurrentAccount(String currentAccountId) async {
    final db = await database;
    final personRows = await db.query('accounts', columns: ['memberId'], where: 'accountId = ?', whereArgs: [currentAccountId]);
    if (personRows.isEmpty) return [];
    final currentMemberId = personRows.first['memberId'] as String;
    final familyRows = await db.query('family_members', columns: ['familyId'], where: 'memberId = ?', whereArgs: [currentMemberId]);
    final familyId = familyRows.isNotEmpty ? familyRows.first['familyId'] as String : null;
    if (familyId == null) return [];
    final rows = await db.query('family_members', where: 'familyId = ? AND memberId != ?', whereArgs: [familyId, currentMemberId]);
    return rows.map((r) => FamilyMember.fromMap(r)).toList();
  }

  Future<void> insertFamilyMember(FamilyMember member,
      {String? currentAccountId}) async {
    final db = await database;
    FamilyMember memberToInsert = member;

    // If currentAccountId provided, ensure member has same familyId
    if (currentAccountId != null) {
      final familyId = await _getFamilyIdForAccount(currentAccountId);
      if (familyId != null && member.familyId.isEmpty) {
        memberToInsert = member.copyWith(familyId: familyId);
      }
    }

    await db.insert(
      'family_members',
      memberToInsert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> signup(String email, String phone, String password) async {
    if (email.isEmpty || phone.isEmpty) {
      throw Exception('Email and phone required');
    }

    final db = await database;
    return await db.transaction((txn) async {
      // check accounts WHERE email=? OR phone=? -> exists error
      final existing = await txn.query(
        'accounts',
        where: 'email = ? OR phone = ?',
        whereArgs: [email, phone],
      );
      if (existing.isNotEmpty) {
        throw Exception('Account already exists');
      }

      // find family_members WHERE email=? AND phone=? -> activate
      final memberRows = await txn.query(
        'family_members',
        where: 'email = ? AND phone = ? AND hasAccount = 0',
        whereArgs: [email, phone],
      );
      if (memberRows.isEmpty) {
        return null;
      }

      final memberId = memberRows.first['memberId'] as String;
      final accountId = _generateId();

      await txn.insert('accounts', {
        'accountId': accountId,
        'memberId': memberId,
        'emailOrPhone': email,
        'email': email,
        'phone': phone,
        'passwordHash': password,
      });

      await txn.update(
        'family_members',
        {'hasAccount': 1},
        where: 'memberId = ?',
        whereArgs: [memberId],
      );

      // return accountId
      return accountId;
    });
  }

  Future<void> updateFamilyMember(FamilyMember member) async {
    final db = await database;
    await db.update(
      'family_members',
      member.toMap(),
      where: 'memberId = ?',
      whereArgs: [member.memberId],
    );
  }

  /// Generate a unique ID
  String _generateId() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(16, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Get familyId for an account
  Future<String?> _getFamilyIdForAccount(String currentAccountId) async {
    final db = await database;
    final accountRows = await db.query('accounts',
        columns: ['memberId'],
        where: 'accountId = ?',
        whereArgs: [currentAccountId]);
    if (accountRows.isEmpty) return null;

    final memberId = accountRows.first['memberId'] as String;
    final memberRows = await db.query('family_members',
        columns: ['familyId'], where: 'memberId = ?', whereArgs: [memberId]);
    if (memberRows.isEmpty) return null;

    return memberRows.first['familyId'] as String?;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Helper method to assign familyIds during migration
  /// Groups members by parent hierarchy
  Future<void> _migrateFamilyIds(Database db) async {
    final members = await db.query('family_members');

    final hasAnyParent =
        members.any((m) => (m['parentId'] as String?)?.isNotEmpty ?? false);

    // If old data never used parentId, treat everything as one family.
    if (!hasAnyParent) {
      final familyId = _generateId();
      for (final member in members) {
        final memberId = member['memberId'] as String;
        final existing = member['familyId'] as String? ?? '';
        if (existing.isNotEmpty) continue;
        await db.update(
          'family_members',
          {'familyId': familyId},
          where: 'memberId = ?',
          whereArgs: [memberId],
        );
      }
      return;
    }

    final familyCache = <String, String>{};
    for (final member in members) {
      final memberId = member['memberId'] as String;
      final existing = member['familyId'] as String? ?? '';
      if (existing.isNotEmpty) {
        familyCache[memberId] = existing;
      }
    }

    Future<String> resolveFamilyId(String memberId) async {
      final cached = familyCache[memberId];
      if (cached != null && cached.isNotEmpty) return cached;

      final rows = await db.query(
        'family_members',
        where: 'memberId = ?',
        whereArgs: [memberId],
        limit: 1,
      );
      if (rows.isEmpty) {
        final generated = _generateId();
        familyCache[memberId] = generated;
        return generated;
      }

      final row = rows.first;
      final existing = row['familyId'] as String? ?? '';
      if (existing.isNotEmpty) {
        familyCache[memberId] = existing;
        return existing;
      }

      final parentId = row['parentId'] as String?;
      String familyId;
      if (parentId == null || parentId.isEmpty) {
        familyId = _generateId();
      } else {
        familyId = await resolveFamilyId(parentId);
      }

      await db.update(
        'family_members',
        {'familyId': familyId},
        where: 'memberId = ?',
        whereArgs: [memberId],
      );
      familyCache[memberId] = familyId;
      return familyId;
    }

    for (final member in members) {
      final memberId = member['memberId'] as String;
      final existing = member['familyId'] as String? ?? '';
      if (existing.isNotEmpty) continue;
      await resolveFamilyId(memberId);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create family_members table (version 3 schema)
    await db.execute('''
      CREATE TABLE family_members (
        memberId TEXT PRIMARY KEY,
        familyId TEXT NOT NULL,
        name TEXT NOT NULL,
        relation TEXT NOT NULL,
        parentId TEXT,
        phone TEXT,
        email TEXT,
        hasAccount INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(parentId) REFERENCES family_members(memberId) ON DELETE SET NULL
      )
    ''');

    // Create index on familyId for faster queries
    await db.execute('''
      CREATE INDEX idx_family_members_familyId ON family_members(familyId)
    ''');

    // Create accounts table
    await db.execute('''
      CREATE TABLE accounts (
        accountId TEXT PRIMARY KEY,
        memberId TEXT UNIQUE NOT NULL,
        emailOrPhone TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        passwordHash TEXT NOT NULL,
        FOREIGN KEY(memberId) REFERENCES family_members(memberId) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration from v1 to v2: Add familyId column
    if (oldVersion < 2) {
      final tableInfo = await db.rawQuery("PRAGMA table_info(family_members)");
      final hasColumn = tableInfo.any((col) => col['name'] == 'familyId');

      if (!hasColumn) {
        await db.execute('''
          ALTER TABLE family_members ADD COLUMN familyId TEXT
        ''');

        // Migrate existing data: assign familyId based on parentId hierarchy
        await _migrateFamilyIds(db);

        // Add NOT NULL constraint by recreating table
        await db.transaction((txn) async {
          // Create temporary table with NOT NULL constraint
          await txn.execute('''
            CREATE TABLE family_members_new (
              memberId TEXT PRIMARY KEY,
              familyId TEXT NOT NULL,
              name TEXT NOT NULL,
              relation TEXT NOT NULL,
              parentId TEXT,
              phone TEXT,
              email TEXT,
              hasAccount INTEGER NOT NULL DEFAULT 0,
              FOREIGN KEY(parentId) REFERENCES family_members(memberId) ON DELETE SET NULL
            )
          ''');

          // Copy data
          await txn.execute('''
            INSERT INTO family_members_new
            SELECT memberId, familyId, name, relation, parentId, phone, email, hasAccount
            FROM family_members
          ''');

          // Drop old table
          await txn.execute('DROP TABLE family_members');

          // Rename new table
          await txn.execute(
              'ALTER TABLE family_members_new RENAME TO family_members');

          // Recreate index
          await txn.execute('''
            CREATE INDEX idx_family_members_familyId ON family_members(familyId)
          ''');
        });
      }
    }

    // Migration from v2 to v3: Add email + phone to accounts
    if (oldVersion < 3) {
      final accountsTableInfo =
          await db.rawQuery("PRAGMA table_info(accounts)");
      final hasEmailColumn =
          accountsTableInfo.any((col) => col['name'] == 'email');
      final hasPhoneColumn =
          accountsTableInfo.any((col) => col['name'] == 'phone');

      if (!hasEmailColumn) {
        await db.execute('ALTER TABLE accounts ADD COLUMN email TEXT');
      }
      if (!hasPhoneColumn) {
        await db.execute('ALTER TABLE accounts ADD COLUMN phone TEXT');
      }

      final hasEmailOrPhoneColumn =
          accountsTableInfo.any((col) => col['name'] == 'emailOrPhone');
      if (hasEmailOrPhoneColumn) {
        final rows = await db.query(
          'accounts',
          columns: ['accountId', 'emailOrPhone', 'email', 'phone'],
        );
        for (final row in rows) {
          final accountId = row['accountId'] as String;
          final emailOrPhone = row['emailOrPhone'] as String? ?? '';
          final email = row['email'] as String?;
          final phone = row['phone'] as String?;
          if ((email == null || email.isEmpty) &&
              (phone == null || phone.isEmpty) &&
              emailOrPhone.isNotEmpty) {
            final isEmail = emailOrPhone.contains('@');
            await db.update(
              'accounts',
              {
                'email': isEmail ? emailOrPhone : null,
                'phone': isEmail ? null : emailOrPhone,
              },
              where: 'accountId = ?',
              whereArgs: [accountId],
            );
          }
        }
      }
    }
  }
}

/// Signup result
class SignupResult {
  final bool success;
  final String? accountId;
  final String message;
  SignupResult(this.success, this.accountId, this.message);
}
