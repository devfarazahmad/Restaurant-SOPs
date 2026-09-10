import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'kitchenops.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(
    Database db,
    int version,
  ) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    // Temporary demo users.

    await db.insert('users', {
      'name': 'Restaurant Owner',
      'phone': '03000000000',
      'email': 'owner@kitchenops.com',
      'password': '123456',
      'role': 'owner',
    });

    await db.insert('users', {
      'name': 'Chef Master',
      'phone': '03111111111',
      'email': 'chef@kitchenops.com',
      'password': '123456',
      'role': 'chef_master',
    });

    await db.insert('users', {
      'name': 'Kitchen Staff',
      'phone': '03222222222',
      'email': 'staff@kitchenops.com',
      'password': '123456',
      'role': 'staff',
    });
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE users ADD COLUMN phone TEXT NOT NULL DEFAULT ''",
      );
    }
  }

  Future<Map<String, dynamic>?> login(
    String email,
    String password, String selectedRole,
  ) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [
        email.trim(),
        password,
      ],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<bool> emailExists(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email.trim()],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<int> createUser({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    final db = await database;

    return await db.insert(
      'users',
      {
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'password': password,
        'role': 'staff',
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {}
}