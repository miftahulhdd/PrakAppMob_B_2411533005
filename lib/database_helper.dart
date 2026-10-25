import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'db_init.dart';
import 'models.dart';

// Error khusus untuk proses login / register
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  final ValueNotifier<int> dataVersion = ValueNotifier<int>(0);

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    // Factory dipilih sesuai platform (web / mobile)
    final DatabaseFactory factory = await getAppDatabaseFactory();
    final String path =
        p.join(await factory.getDatabasesPath(), 'expense_tracker.db');

    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              email TEXT NOT NULL UNIQUE,
              password_hash TEXT NOT NULL,
              salt TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE transactions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              title TEXT NOT NULL,
              amount INTEGER NOT NULL,
              type TEXT NOT NULL,
              category TEXT NOT NULL,
              date TEXT NOT NULL,
              created_at TEXT NOT NULL,
              FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
            )
          ''');

          // Menyimpan user yang sedang login (hanya 1 baris)
          await db.execute('''
            CREATE TABLE app_session (
              id INTEGER PRIMARY KEY CHECK (id = 1),
              user_id INTEGER NOT NULL
            )
          ''');
        },
      ),
    );
  }

  // ---------------------------------------------------------------
  // PASSWORD
  // ---------------------------------------------------------------
  String _generateSalt() {
    final Random random = Random.secure();
    final List<int> bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPassword(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }

  // ---------------------------------------------------------------
  // AUTH
  // ---------------------------------------------------------------
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final Database db = await database;
    final String cleanEmail = email.trim().toLowerCase();

    final List<Map<String, Object?>> existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [cleanEmail],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      throw AuthException('Email sudah terdaftar, silakan login');
    }

    final String salt = _generateSalt();
    final int id = await db.insert('users', {
      'name': name.trim(),
      'email': cleanEmail,
      'password_hash': _hashPassword(password, salt),
      'salt': salt,
      'created_at': DateTime.now().toIso8601String(),
    });

    return UserModel(id: id, name: name.trim(), email: cleanEmail);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final Database db = await database;
    final String cleanEmail = email.trim().toLowerCase();

    final List<Map<String, Object?>> rows = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [cleanEmail],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw AuthException('Email atau password salah');
    }

    final Map<String, Object?> row = rows.first;
    final String hash = _hashPassword(password, row['salt'] as String);
    if (hash != row['password_hash']) {
      throw AuthException('Email atau password salah');
    }

    final UserModel user = UserModel.fromMap(row);
    await db.insert(
      'app_session',
      {'id': 1, 'user_id': user.id},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    AppSession.user = user;
    return user;
  }

  // Dipanggil saat aplikasi dibuka: apakah masih ada sesi login?
  Future<UserModel?> restoreSession() async {
    final Database db = await database;

    final List<Map<String, Object?>> session =
        await db.query('app_session', limit: 1);
    if (session.isEmpty) return null;

    final int userId = session.first['user_id'] as int;
    final List<Map<String, Object?>> users = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    if (users.isEmpty) {
      await db.delete('app_session');
      return null;
    }

    return UserModel.fromMap(users.first);
  }

  Future<void> logout() async {
    final Database db = await database;
    await db.delete('app_session');
    AppSession.user = null;
  }

  // ---------------------------------------------------------------
  // TRANSAKSI
  // ---------------------------------------------------------------
  Future<int> insertTransaction(TransactionModel t) async {
    final Database db = await database;
    final int id = await db.insert('transactions', t.toMap());
    dataVersion.value++;
    return id;
  }

  Future<List<TransactionModel>> getTransactions(
    int userId, {
    int? limit,
  }) async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(
      'transactions',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
      limit: limit,
    );
    return rows.map((row) => TransactionModel.fromMap(row)).toList();
  }

  Future<void> deleteTransaction(int id, int userId) async {
    final Database db = await database;
    await db.delete(
      'transactions',
      where: 'id = ? AND user_id = ?',
      whereArgs: [id, userId],
    );
    dataVersion.value++;
  }

  // Mengembalikan {'income': ..., 'expense': ...}
  Future<Map<String, int>> getTotals(int userId) async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT type, COALESCE(SUM(amount), 0) AS total '
      'FROM transactions WHERE user_id = ? GROUP BY type',
      [userId],
    );

    final Map<String, int> totals = {'income': 0, 'expense': 0};
    for (final Map<String, Object?> row in rows) {
      totals[row['type'] as String] = (row['total'] as num).toInt();
    }
    return totals;
  }
}
