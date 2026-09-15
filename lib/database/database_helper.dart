import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  // ============================================================
  // DATABASE
  // ============================================================

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  // ============================================================
  // INIT DATABASE
  // ============================================================

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(
      databasePath,
      'kitchenops.db',
    );

    return await openDatabase(
      path,
      version: 6,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // ============================================================
  // CREATE DATABASE
  // ============================================================

  Future<void> _onCreate(
    Database db,
    int version,
  ) async {
    await _createUsersTable(db);

    await _createRecipesTable(db);

    await _createDefaultUsers(db);

    await _seedRecipes(db);
  }

  // ============================================================
  // USERS TABLE
  // ============================================================

  Future<void> _createUsersTable(
    Database db,
  ) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL
      )
    ''');
  }

  // ============================================================
  // RECIPES TABLE
  // ============================================================

  Future<void> _createRecipesTable(
    Database db,
  ) async {
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
  // DATABASE UPGRADE
  // ============================================================

  Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // ----------------------------------------------------------
    // VERSION 2
    // ----------------------------------------------------------

    if (oldVersion < 2) {
      if (!await _columnExists(
        db,
        'users',
        'phone',
      )) {
        await db.execute('''
          ALTER TABLE users
          ADD COLUMN phone TEXT NOT NULL DEFAULT ''
        ''');
      }
    }

    // ----------------------------------------------------------
    // VERSION 3
    // ----------------------------------------------------------

    if (oldVersion < 3) {
      await _createRecipesTable(db);
    }

    // ----------------------------------------------------------
    // VERSION 4
    // Add timestamps
    // ----------------------------------------------------------

    if (oldVersion < 4) {
      if (!await _columnExists(
        db,
        'recipes',
        'created_at',
      )) {
        await db.execute('''
          ALTER TABLE recipes
          ADD COLUMN created_at TEXT NOT NULL DEFAULT ''
        ''');
      }

      if (!await _columnExists(
        db,
        'recipes',
        'updated_at',
      )) {
        await db.execute('''
          ALTER TABLE recipes
          ADD COLUMN updated_at TEXT NOT NULL DEFAULT ''
        ''');
      }
    }

    // ----------------------------------------------------------
    // VERSION 5
    // Add presentation_instructions
    // ----------------------------------------------------------

    if (oldVersion < 5) {
      if (!await _columnExists(
        db,
        'recipes',
        'presentation_instructions',
      )) {
        await db.execute('''
          ALTER TABLE recipes
          ADD COLUMN presentation_instructions
          TEXT NOT NULL DEFAULT ''
        ''');
      }
    }

    // ----------------------------------------------------------
    // VERSION 6
    //
    // FINAL FIX
    //
    // If presentation_instructions already exists as:
    //
    // TEXT NOT NULL
    //
    // without a default value, simply adding a column is not
    // enough.
    //
    // We rebuild the recipes table with DEFAULT ''.
    // ----------------------------------------------------------

    if (oldVersion < 6) {
      await _repairRecipesTable(db);
    }

    // ----------------------------------------------------------
    // Make sure all columns exist
    // ----------------------------------------------------------

    await _ensureAllRecipeColumns(db);

    // ----------------------------------------------------------
    // Fix empty timestamps
    // ----------------------------------------------------------

    final now =
        DateTime.now().toIso8601String();

    await db.update(
      'recipes',
      {
        'created_at': now,
        'updated_at': now,
      },
      where:
          "created_at = '' OR updated_at = ''",
    );
  }

  // ============================================================
  // REPAIR RECIPES TABLE
  // ============================================================

  Future<void> _repairRecipesTable(
    Database db,
  ) async {
    final exists = await _tableExists(
      db,
      'recipes',
    );

    if (!exists) {
      await _createRecipesTable(db);
      return;
    }

    // Get current columns
    final columns =
        await db.rawQuery(
      'PRAGMA table_info(recipes)',
    );

    final columnNames = columns
        .map(
          (row) => row['name'].toString(),
        )
        .toSet();

    // ----------------------------------------------------------
    // Create temporary table
    // ----------------------------------------------------------

    await db.execute('''
      CREATE TABLE recipes_new (
        id INTEGER PRIMARY KEY AUTOINCREMENT,

        name TEXT NOT NULL DEFAULT '',

        category TEXT NOT NULL DEFAULT '',

        description TEXT NOT NULL DEFAULT '',

        image TEXT NOT NULL DEFAULT '',

        preparation_time INTEGER NOT NULL DEFAULT 0,

        ingredients TEXT NOT NULL DEFAULT '',

        preparation_steps TEXT NOT NULL DEFAULT '',

        cooking_instructions TEXT NOT NULL DEFAULT '',

        presentation_instructions
          TEXT NOT NULL DEFAULT '',

        storage_instructions
          TEXT NOT NULL DEFAULT '',

        freezing_instructions
          TEXT NOT NULL DEFAULT '',

        thawing_instructions
          TEXT NOT NULL DEFAULT '',

        created_at TEXT NOT NULL DEFAULT '',

        updated_at TEXT NOT NULL DEFAULT ''
      )
    ''');

    // ----------------------------------------------------------
    // Build SELECT values for old table
    // ----------------------------------------------------------

    String valueOrDefault(
      String column,
      String defaultValue,
    ) {
      if (columnNames.contains(column)) {
        return column;
      }

      return defaultValue;
    }

    final name =
        valueOrDefault('name', "''");

    final category =
        valueOrDefault('category', "''");

    final description =
        valueOrDefault('description', "''");

    final image =
        valueOrDefault('image', "''");

    final preparationTime =
        valueOrDefault(
      'preparation_time',
      '0',
    );

    final ingredients =
        valueOrDefault(
      'ingredients',
      "''",
    );

    final preparationSteps =
        valueOrDefault(
      'preparation_steps',
      "''",
    );

    final cookingInstructions =
        valueOrDefault(
      'cooking_instructions',
      "''",
    );

    final presentationInstructions =
        valueOrDefault(
      'presentation_instructions',
      "''",
    );

    final storageInstructions =
        valueOrDefault(
      'storage_instructions',
      "''",
    );

    final freezingInstructions =
        valueOrDefault(
      'freezing_instructions',
      "''",
    );

    final thawingInstructions =
        valueOrDefault(
      'thawing_instructions',
      "''",
    );

    final createdAt =
        valueOrDefault(
      'created_at',
      "''",
    );

    final updatedAt =
        valueOrDefault(
      'updated_at',
      "''",
    );

    // ----------------------------------------------------------
    // COPY OLD DATA
    // ----------------------------------------------------------

    await db.execute('''
      INSERT INTO recipes_new (
        id,
        name,
        category,
        description,
        image,
        preparation_time,
        ingredients,
        preparation_steps,
        cooking_instructions,
        presentation_instructions,
        storage_instructions,
        freezing_instructions,
        thawing_instructions,
        created_at,
        updated_at
      )
      SELECT
        id,
        $name,
        $category,
        $description,
        $image,
        $preparationTime,
        $ingredients,
        $preparationSteps,
        $cookingInstructions,
        $presentationInstructions,
        $storageInstructions,
        $freezingInstructions,
        $thawingInstructions,
        $createdAt,
        $updatedAt
      FROM recipes
    ''');

    // ----------------------------------------------------------
    // DELETE OLD TABLE
    // ----------------------------------------------------------

    await db.execute(
      'DROP TABLE recipes',
    );

    // ----------------------------------------------------------
    // RENAME NEW TABLE
    // ----------------------------------------------------------

    await db.execute('''
      ALTER TABLE recipes_new
      RENAME TO recipes
    ''');
  }

  // ============================================================
  // CHECK TABLE
  // ============================================================

  Future<bool> _tableExists(
    Database db,
    String table,
  ) async {
    final result = await db.rawQuery(
      '''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
      AND name = ?
      ''',
      [table],
    );

    return result.isNotEmpty;
  }

  // ============================================================
  // CHECK COLUMN
  // ============================================================

  Future<bool> _columnExists(
    Database db,
    String table,
    String column,
  ) async {
    final result =
        await db.rawQuery(
      'PRAGMA table_info($table)',
    );

    return result.any(
      (row) =>
          row['name'].toString() ==
          column,
    );
  }

  // ============================================================
  // ENSURE ALL RECIPE COLUMNS
  // ============================================================

  Future<void> _ensureAllRecipeColumns(
    Database db,
  ) async {
    final columns = {
      'name':
          "TEXT NOT NULL DEFAULT ''",

      'category':
          "TEXT NOT NULL DEFAULT ''",

      'description':
          "TEXT NOT NULL DEFAULT ''",

      'image':
          "TEXT NOT NULL DEFAULT ''",

      'preparation_time':
          "INTEGER NOT NULL DEFAULT 0",

      'ingredients':
          "TEXT NOT NULL DEFAULT ''",

      'preparation_steps':
          "TEXT NOT NULL DEFAULT ''",

      'cooking_instructions':
          "TEXT NOT NULL DEFAULT ''",

      'presentation_instructions':
          "TEXT NOT NULL DEFAULT ''",

      'storage_instructions':
          "TEXT NOT NULL DEFAULT ''",

      'freezing_instructions':
          "TEXT NOT NULL DEFAULT ''",

      'thawing_instructions':
          "TEXT NOT NULL DEFAULT ''",

      'created_at':
          "TEXT NOT NULL DEFAULT ''",

      'updated_at':
          "TEXT NOT NULL DEFAULT ''",
    };

    for (final entry in columns.entries) {
      final exists =
          await _columnExists(
        db,
        'recipes',
        entry.key,
      );

      if (!exists) {
        await db.execute('''
          ALTER TABLE recipes
          ADD COLUMN ${entry.key}
          ${entry.value}
        ''');
      }
    }
  }

  // ============================================================
  // DEFAULT USERS
  // ============================================================

  Future<void> _createDefaultUsers(
    Database db,
  ) async {
    final countResult =
        await db.rawQuery(
      'SELECT COUNT(*) as count FROM users',
    );

    final count =
        Sqflite.firstIntValue(
              countResult,
            ) ??
            0;

    if (count > 0) {
      return;
    }

    await db.insert('users', {
      'name': 'Kitchen Owner',
      'phone': '03000000000',
      'email':
          'owner@kitchenops.com',
      'password': '123456',
      'role': 'owner',
    });

    await db.insert('users', {
      'name': 'Chef Master',
      'phone': '03000000001',
      'email':
          'chef@kitchenops.com',
      'password': '123456',
      'role': 'chef_master',
    });

    await db.insert('users', {
      'name': 'Kitchen Staff',
      'phone': '03000000002',
      'email':
          'staff@kitchenops.com',
      'password': '123456',
      'role': 'staff',
    });
  }

  // ============================================================
  // SEED RECIPES
  // ============================================================

  Future<void> _seedRecipes(
    Database db,
  ) async {
    final result =
        await db.rawQuery(
      'SELECT COUNT(*) as count FROM recipes',
    );

    final count =
        Sqflite.firstIntValue(
              result,
            ) ??
            0;

    if (count > 0) {
      return;
    }

    final now =
        DateTime.now()
            .toIso8601String();

    await db.insert('recipes', {
      'name':
          'Classic Beef Burger',

      'category':
          'Burgers',

      'description':
          'A classic restaurant-style beef burger.',

      'image':
          'assets/images/burger.jpg',

      'preparation_time':
          15,

      'ingredients': '''
Beef patty
Burger bun
Lettuce
Tomato
Onion
Cheese
Burger sauce
Salt
Black pepper
''',

      'preparation_steps': '''
Prepare the beef patty.
Season with salt and black pepper.
Slice the vegetables.
Prepare the burger sauce.
Toast the burger bun.
''',

      'cooking_instructions': '''
Cook the beef patty on the grill or pan.
Cook both sides until properly done.
Add cheese.
Toast the burger bun.
''',

      'presentation_instructions': '''
Place the burger on a clean plate.
Add the required garnish.
Serve immediately.
''',

      'storage_instructions':
          'Store ingredients in refrigerated containers.',

      'freezing_instructions':
          'Raw beef patties can be frozen in sealed packaging.',

      'thawing_instructions':
          'Thaw frozen patties inside the refrigerator.',

      'created_at': now,

      'updated_at': now,
    });

    await db.insert('recipes', {
      'name':
          'Chicken Pizza',

      'category':
          'Pizza',

      'description':
          'Restaurant-style chicken pizza.',

      'image':
          'assets/images/pizza.jpg',

      'preparation_time':
          25,

      'ingredients': '''
Pizza dough
Pizza sauce
Chicken
Mozzarella cheese
Capsicum
Onion
Olives
Oregano
Chilli flakes
''',

      'preparation_steps': '''
Prepare the pizza dough.
Spread pizza sauce.
Add cooked chicken.
Add vegetables.
Add mozzarella cheese.
''',

      'cooking_instructions': '''
Preheat the oven.
Place the pizza in the oven.
Bake until the crust is golden.
Remove and slice.
''',

      'presentation_instructions': '''
Place pizza on a clean serving plate.
Cut into equal slices.
Serve hot.
''',

      'storage_instructions':
          'Store prepared ingredients in refrigerated containers.',

      'freezing_instructions':
          'Pizza dough can be frozen in sealed packaging.',

      'thawing_instructions':
          'Thaw frozen dough in the refrigerator.',

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
      where:
          'email = ? AND password = ? AND role = ?',
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
  // GET USER BY ID
  // ============================================================

  Future<Map<String, dynamic>?>
      getUserById(
    int id,
  ) async {
    final db = await database;

    final result = await db.query(
      'users',
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
  // EMAIL EXISTS
  // ============================================================

  Future<bool> emailExists(
    String email,
  ) async {
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
      conflictAlgorithm:
          ConflictAlgorithm.abort,
    );
  }

  // ============================================================
  // GET ALL RECIPES
  // ============================================================

  Future<List<Map<String, dynamic>>>
      getAllRecipes() async {
    final db = await database;

    return await db.query(
      'recipes',
      orderBy: 'id DESC',
    );
  }

  // ============================================================
  // GET RECIPE BY ID
  // ============================================================

  Future<Map<String, dynamic>?>
      getRecipeById(
    int id,
  ) async {
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
    String presentationInstructions = '',
    required String storageInstructions,
    required String freezingInstructions,
    required String thawingInstructions,
  }) async {
    final db = await database;

    final now =
        DateTime.now()
            .toIso8601String();

    return await db.insert(
      'recipes',
      {
        'name':
            name.trim(),

        'category':
            category.trim(),

        'description':
            description.trim(),

        'image':
            image.trim(),

        'preparation_time':
            preparationTime,

        'ingredients':
            ingredients.trim(),

        'preparation_steps':
            preparationSteps.trim(),

        'cooking_instructions':
            cookingInstructions.trim(),

        'presentation_instructions':
            presentationInstructions.trim(),

        'storage_instructions':
            storageInstructions.trim(),

        'freezing_instructions':
            freezingInstructions.trim(),

        'thawing_instructions':
            thawingInstructions.trim(),

        'created_at':
            now,

        'updated_at':
            now,
      },
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

    final now =
        DateTime.now()
            .toIso8601String();

    return await db.update(
      'recipes',
      {
        'name':
            name.trim(),

        'category':
            category.trim(),

        'description':
            description.trim(),

        'image':
            image.trim(),

        'preparation_time':
            preparationTime,

        'ingredients':
            ingredients.trim(),

        'preparation_steps':
            preparationSteps.trim(),

        'cooking_instructions':
            cookingInstructions.trim(),

        'presentation_instructions':
            presentationInstructions.trim(),

        'storage_instructions':
            storageInstructions.trim(),

        'freezing_instructions':
            freezingInstructions.trim(),

        'thawing_instructions':
            thawingInstructions.trim(),

        'updated_at':
            now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // DELETE RECIPE
  // ============================================================

  Future<int> deleteRecipe(
    int id,
  ) async {
    final db = await database;

    return await db.delete(
      'recipes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
