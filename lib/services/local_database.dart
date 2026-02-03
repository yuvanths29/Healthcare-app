import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/account.dart';
import '../models/family_member.dart';

class LocalDatabase {
  static const _databaseName = 'healthcare_app.db';
  static const _databaseVersion = 1;

  static final LocalDatabase instance = LocalDatabase._privateConstructor();
  Database? _database;

  LocalDatabase._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
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

      await txn.insert('accounts', account.toMap());

      await txn.update(
        'family_members',
        {'hasAccount': 1},
        where: 'memberId = ?',
        whereArgs: [account.memberId],
      );
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

  Future<List<FamilyMember>> getAllFamilyMembers() async {
    final db = await database;
    final rows = await db.query('family_members');
    return rows.map((r) => FamilyMember.fromMap(r)).toList();
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

  Future<void> insertFamilyMember(FamilyMember member) async {
    final db = await database;
    await db.insert(
      'family_members',
      member.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE family_members (
        memberId TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        relation TEXT NOT NULL,
        parentId TEXT,
        phone TEXT,
        email TEXT,
        hasAccount INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY(parentId) REFERENCES family_members(memberId) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE accounts (
        accountId TEXT PRIMARY KEY,
        memberId TEXT UNIQUE NOT NULL,
        emailOrPhone TEXT NOT NULL,
        passwordHash TEXT NOT NULL,
        FOREIGN KEY(memberId) REFERENCES family_members(memberId) ON DELETE CASCADE
      )
    ''');
  }
}
