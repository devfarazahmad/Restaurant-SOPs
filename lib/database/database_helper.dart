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
      version: 7,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ============================================================
  // CREATE DATABASE
  // ============================================================

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        image TEXT NOT NULL DEFAULT '',
        preparation_time INTEGER NOT NULL DEFAULT 0,
        ingredients TEXT NOT NULL DEFAULT '',
        preparation_steps TEXT NOT NULL DEFAULT '',
        cooking_instructions TEXT NOT NULL DEFAULT '',
        presentation_instructions TEXT NOT NULL DEFAULT '',
        storage_instructions TEXT NOT NULL DEFAULT '',
        freezing_instructions TEXT NOT NULL DEFAULT '',
        thawing_instructions TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT '',
        updated_at TEXT NOT NULL DEFAULT ''
      )
    ''');

    await _createDefaultUsers(db);
    await _seedRecipes(db);
  }

  // ============================================================
  // DATABASE UPGRADE
  // ============================================================

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // -------------------------
    // Version 2
    // -------------------------
    if (oldVersion < 2) {
      await _addColumnIfMissing(
        db,
        'users',
        'phone',
        "TEXT NOT NULL DEFAULT ''",
      );
    }

    // -------------------------
    // Version 3
    // -------------------------
    if (oldVersion < 3) {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master "
        "WHERE type='table' AND name='recipes'",
      );

      if (tables.isEmpty) {
        await _createRecipesTable(db);
      }
    }

    // -------------------------
    // Version 4
    // -------------------------
    if (oldVersion < 4) {
      await _addColumnIfMissing(
        db,
        'recipes',
        'created_at',
        "TEXT NOT NULL DEFAULT ''",
      );

      await _addColumnIfMissing(
        db,
        'recipes',
        'updated_at',
        "TEXT NOT NULL DEFAULT ''",
      );
    }

    // -------------------------
    // Version 5
    // -------------------------
    if (oldVersion < 5) {
      await _addColumnIfMissing(
        db,
        'recipes',
        'presentation_instructions',
        "TEXT NOT NULL DEFAULT ''",
      );
    }

    // -------------------------
    // Version 6
    // -------------------------
    if (oldVersion < 6) {
      await _ensureAllRecipeColumns(db);
    }

    // -------------------------
    // Version 7
    // FINAL REPAIR
    // -------------------------
    if (oldVersion < 7) {
      await _ensureAllRecipeColumns(db);
    }

    // Make sure every recipe row has timestamps.
    await db.execute('''
      UPDATE recipes
      SET created_at = ?
      WHERE created_at IS NULL OR created_at = ''
    ''', [DateTime.now().toIso8601String()]);

    await db.execute('''
      UPDATE recipes
      SET updated_at = ?
      WHERE updated_at IS NULL OR updated_at = ''
    ''', [DateTime.now().toIso8601String()]);
  }

  // ============================================================
  // CREATE RECIPES TABLE
  // ============================================================

  Future<void> _createRecipesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL DEFAULT '',
        category TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        image TEXT NOT NULL DEFAULT '',
        preparation_time INTEGER NOT NULL DEFAULT 0,
        ingredients TEXT NOT NULL DEFAULT '',
        preparation_steps TEXT NOT NULL DEFAULT '',
        cooking_instructions TEXT NOT NULL DEFAULT '',
        presentation_instructions TEXT NOT NULL DEFAULT '',
        storage_instructions TEXT NOT NULL DEFAULT '',
        freezing_instructions TEXT NOT NULL DEFAULT '',
        thawing_instructions TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL DEFAULT '',
        updated_at TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  // ============================================================
  // ADD COLUMN ONLY IF IT DOES NOT EXIST
  // ============================================================

  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final columns = await db.rawQuery(
      'PRAGMA table_info($table)',
    );

    final exists = columns.any(
      (columnInfo) => columnInfo['name'] == column,
    );

    if (!exists) {
      await db.execute(
        'ALTER TABLE $table ADD COLUMN $column $definition',
      );
    }
  }

  // ============================================================
  // ENSURE ALL RECIPE COLUMNS EXIST
  // ============================================================

  Future<void> _ensureAllRecipeColumns(Database db) async {
    final recipesTable = await db.rawQuery(
      "SELECT name FROM sqlite_master "
      "WHERE type='table' AND name='recipes'",
    );

    if (recipesTable.isEmpty) {
      await _createRecipesTable(db);
      return;
    }

    await _addColumnIfMissing(
      db,
      'name',
      'name',
      "TEXT NOT NULL DEFAULT ''",
    );

    await _addColumnIfMissing(
      db,
      'category',
      'category',
      "TEXT NOT NULL DEFAULT ''",
    );

    await _addColumnIfMissing(
      db,
      'description',
      'description',
      "TEXT NOT NULL DEFAULT ''",
    );

    await _addColumnIfMissing(
      db,
      'image',
      'image',
      "TEXT NOT NULL DEFAULT ''",
    );

    await _addColumnIfMissing(
      db,
      'recipes',
      'preparation_time',
      "INTEGER NOT NULL DEFAULT 0",
    );

    await _addColumnIfMissing(
      db,
      'recipes',
      'ingredients',
      "TEXT NOT NULL DEFAULT ''",
    );

    await _addColumnIfMissing(
      db,
      'recipes',
      'preparation_steps',
      "TEXT NOT NULL DEFAULT ''",
    );

    await _addColumnIfMissing(
      db,
      'recipes',
      'cooking_instructions',
      "TEXT NOT NULL DEFAULT ''",
    );

    // IMPORTANT:
    // This is the column causing your current error.
    await _addColumnIfMissing(
      db,
      'recipes',
      'presentation_instructions',
      "TEXT NOT NULL DEFAULT ''",
    );

    await _addColumnIfMissing(
      db,
      'recipes',
      'storage_instructions',
      "TEXT NOT NULL DEFAULT ''",
    );

    await _addColumnIfMissing(
      db,
      'recipes',
      'freezing_instructions',
      "TEXT NOT NULL DEFAULT ''",
    );

    await _addColumnIfMissing(
      db,
      'recipes',
      'thawing_instructions',
      "TEXT NOT NULL DEFAULT ''",
    );

    await _addColumnIfMissing(
      db,
      'recipes',
      'created_at',
      "TEXT NOT NULL DEFAULT ''",
    );

    await _addColumnIfMissing(
      db,
      'recipes',
      'updated_at',
      "TEXT NOT NULL DEFAULT ''",
    );
  }

  // ============================================================
  // DEFAULT USERS
  // ============================================================

  Future<void> _createDefaultUsers(Database db) async {
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM users',
    );

    final count = Sqflite.firstIntValue(countResult) ?? 0;

    if (count > 0) {
      return;
    }

    await db.insert('users', {
      'name': 'Owner',
      'phone': '',
      'email': 'owner@kitchenops.com',
      'password': '123456',
      'role': 'owner',
    });

    await db.insert('users', {
      'name': 'Chef Master',
      'phone': '',
      'email': 'chef@kitchenops.com',
      'password': '123456',
      'role': 'chef_master',
    });

    await db.insert('users', {
      'name': 'Kitchen Staff',
      'phone': '',
      'email': 'staff@kitchenops.com',
      'password': '123456',
      'role': 'staff',
    });
  }

  // ============================================================
  // SAMPLE RECIPES
  // ============================================================

  Future<void> _seedRecipes(Database db) async {
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM recipes',
    );

    final count = Sqflite.firstIntValue(countResult) ?? 0;

    if (count > 0) {
      return;
    }

    final now = DateTime.now().toIso8601String();

    await db.insert('recipes', {
      'name': 'Classic Beef Burger',
      'category': 'Burgers',
      'description': 'Classic restaurant style beef burger.',
      'image': 'assets/images/burger.jpg',
      'preparation_time': 15,
      'ingredients':
          'Beef patty, burger bun, lettuce, tomato, cheese, sauce',
      'preparation_steps':
          'Prepare beef patty. Cut vegetables. Prepare bun.',
      'cooking_instructions':
          'Cook beef patty until fully cooked.',
      'presentation_instructions':
          'Place patty inside bun and arrange vegetables neatly.',
      'storage_instructions':
          'Store ingredients in refrigerator.',
      'freezing_instructions':
          'Freeze uncooked patties in sealed packaging.',
      'thawing_instructions':
          'Thaw patties in refrigerator before cooking.',
      'created_at': now,
      'updated_at': now,
    });

    await db.insert('recipes', {
      'name': 'Chicken Pizza',
      'category': 'Pizza',
      'description': 'Restaurant style chicken pizza.',
      'image': 'assets/images/pizza.jpg',
      'preparation_time': 20,
      'ingredients':
          'Pizza dough, chicken, cheese, tomato sauce, vegetables',
      'preparation_steps':
          'Prepare dough. Add sauce. Add chicken and vegetables.',
      'cooking_instructions':
          'Bake pizza until cheese is melted and crust is cooked.',
      'presentation_instructions':
          'Cut pizza into equal slices and serve neatly.',
      'storage_instructions':
          'Store prepared ingredients in refrigerator.',
      'freezing_instructions':
          'Pizza can be frozen in sealed packaging.',
      'thawing_instructions':
          'Thaw frozen pizza in refrigerator before reheating.',
      'created_at': now,
      'updated_at': now,
    });
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<Map<String, dynamic>?> login(
    String email,
    String password,
    String role,
  ) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ? AND role = ?',
      whereArgs: [
        email.trim(),
        password,
        role,
      ],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // ============================================================
  // CHECK EMAIL
  // ============================================================

  Future<bool> emailExists(String email) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim()],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  // ============================================================
  // CREATE USER
  // ============================================================

  Future<int> createUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String role,
  }) async {
    final db = await database;

    return await db.insert(
      'users',
      {
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email.trim(),
        'password': password,
        'role': role,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ============================================================
  // GET ALL RECIPES
  // ============================================================

  Future<List<Map<String, dynamic>>> getAllRecipes() async {
    final db = await database;

    return await db.query(
      'recipes',
      orderBy: 'id DESC',
    );
  }

  // ============================================================
  // GET ONE RECIPE
  // ============================================================

  Future<Map<String, dynamic>?> getRecipeById(int id) async {
    final db = await database;

    final result = await db.query(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // ============================================================
  // INSERT RECIPE
  // ============================================================

  Future<int> insertRecipe({
    required String name,
    required String category,
    required String description,
    String image = '',
    required int preparationTime,
    required String ingredients,
    required String preparationSteps,
    required String cookingInstructions,

    // IMPORTANT:
    // Optional so old CreateRecipeScreen code will also work.
    String presentationInstructions = '',

    required String storageInstructions,
    required String freezingInstructions,
    required String thawingInstructions,
  }) async {
    final db = await database;

    final now = DateTime.now().toIso8601String();

    final data = <String, dynamic>{
      'name': name.trim(),
      'category': category.trim(),
      'description': description.trim(),
      'image': image.trim(),
      'preparation_time': preparationTime,
      'ingredients': ingredients.trim(),
      'preparation_steps': preparationSteps.trim(),
      'cooking_instructions': cookingInstructions.trim(),

      // VERY IMPORTANT
      'presentation_instructions':
          presentationInstructions.trim(),

      'storage_instructions': storageInstructions.trim(),
      'freezing_instructions': freezingInstructions.trim(),
      'thawing_instructions': thawingInstructions.trim(),
      'created_at': now,
      'updated_at': now,
    };

    print('======================================');
    print('KITCHENOPS INSERT RECIPE');
    print('Data being inserted:');
    print(data);
    print('======================================');

    return await db.insert(
      'recipes',
      data,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ============================================================
  // UPDATE RECIPE
  // ============================================================

  Future<int> updateRecipe({
    required int id,
    required String name,
    required String category,
    required String description,
    String image = '',
    required int preparationTime,
    required String ingredients,
    required String preparationSteps,
    required String cookingInstructions,
    String presentationInstructions = '',
    required String storageInstructions,
    required String freezingInstructions,
    required String thawingInstructions,
  }) async {
    final db = await database;

    final now = DateTime.now().toIso8601String();

    return await db.update(
      'recipes',
      {
        'name': name.trim(),
        'category': category.trim(),
        'description': description.trim(),
        'image': image.trim(),
        'preparation_time': preparationTime,
        'ingredients': ingredients.trim(),
        'preparation_steps': preparationSteps.trim(),
        'cooking_instructions': cookingInstructions.trim(),
        'presentation_instructions':
            presentationInstructions.trim(),
        'storage_instructions': storageInstructions.trim(),
        'freezing_instructions': freezingInstructions.trim(),
        'thawing_instructions': thawingInstructions.trim(),
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // DELETE RECIPE
  // ============================================================

  Future<int> deleteRecipe(int id) async {
    final db = await database;

    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // DEBUG DATABASE SCHEMA
  // ============================================================

  Future<void> debugRecipeColumns() async {
    final db = await database;

    final columns = await db.rawQuery(
      'PRAGMA table_info(recipes)',
    );

    print('======================================');
    print('KITCHENOPS RECIPES TABLE');
    print(columns);
    print('======================================');
  }
}