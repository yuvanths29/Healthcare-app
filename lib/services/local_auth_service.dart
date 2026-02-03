import 'package:bcrypt/bcrypt.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';

class LocalAuthService {
  static const String _databaseName = 'healthcare_auth.db';
  static const String _tableName = 'users';
  static const int _databaseVersion = 2;

  static final LocalAuthService _instance = LocalAuthService._internal();

  late Database _db;
  bool _initialized = false;

  factory LocalAuthService() {
    return _instance;
  }

  LocalAuthService._internal();

  Future<User?> authenticateUser(String emailOrMobile, String password) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final identifier = emailOrMobile.trim().toLowerCase();
      if (identifier.isEmpty) return null;

      final result = await _db.query(
        _tableName,
        where: 'email = ? OR mobile = ?',
        whereArgs: [identifier, identifier],
      );

      if (result.isEmpty) return null;

      final hashedPassword = result.first['password'] as String;
      final passwordMatch = BCrypt.checkpw(password, hashedPassword);

      if (!passwordMatch) return null;

      return User.fromDbJson(result.first);
    } catch (e) {
      print('Error authenticating user: $e');
      return null;
    }
  }

  Future<void> clearAllUsers() async {
    try {
      await _db.delete(_tableName);
    } catch (e) {
      print('Error clearing users: $e');
    }
  }

  Future<void> close() async {
    if (_initialized) {
      await _db.close();
      _initialized = false;
    }
  }

  Future<User> createUser({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final user = User(
      userId: _generateUserId(),
      name: name,
      email: email.toLowerCase(),
      mobile: mobile,
      password: password,
    );

    try {
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      await _db.insert(
        _tableName,
        {
          'id': user.userId,
          'name': user.name,
          'email': user.email,
          'mobile': user.mobile,
          'password': hashedPassword,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        },
      );
      return user;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<bool> deleteUser(String email) async {
    try {
      final count = await _db.delete(
        _tableName,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      return count > 0;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      final result = await _db.query(_tableName);
      return result.map((json) => User.fromDbJson(json)).toList();
    } catch (e) {
      print('Error fetching all users: $e');
      return [];
    }
  }

  Future<User?> getUserById(String userId) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final result = await _db.query(
        _tableName,
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (result.isEmpty) return null;

      return User.fromDbJson(result.first);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    _initialized = true;
  }

  Future<bool> updatePassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      if (!_initialized) {
        await initialize();
      }

      final hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

      final count = await _db.update(
        _tableName,
        {'password': hashedPassword},
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      return count > 0;
    } catch (e) {
      print('Error updating password: $e');
      return false;
    }
  }

  Future<bool> userExists(String email) async {
    if (!_initialized) {
      await initialize();
    }

    final identifier = email.trim().toLowerCase();
    final result = await _db.query(
      _tableName,
      where: 'email = ? OR mobile = ?',
      whereArgs: [identifier, identifier],
    );
    return result.isNotEmpty;
  }

  String _generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    final random = (DateTime.now().microsecond % 10000).toRadixString(36);
    return 'U-$timestamp-$random'.toUpperCase();
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        mobile TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $_tableName ADD COLUMN mobile TEXT');
      await db.execute(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_users_mobile ON $_tableName(mobile)',
      );
    }
  }
}
