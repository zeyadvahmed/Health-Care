import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static Database? _database;

  Future<Database> get database async {

    if (_database != null) {
      return _database!;
    }

    _database =
        await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {

    String path = join(
      await getDatabasesPath(),
      'sparksteel.db',
    );

    return await openDatabase(

      path,

      version: 1,

      onCreate: (
        db,
        version,
      ) async {

        await db.execute('''

        CREATE TABLE users(

          id INTEGER PRIMARY KEY AUTOINCREMENT,

          name TEXT,

          email TEXT,

          age TEXT,

          weight TEXT,

          height TEXT,

          waterGoal TEXT,

          caloriesGoal TEXT

        )

        ''');
      },
    );
  }

  // =========================
  // INSERT USER IF NOT EXISTS
  // =========================

  Future<void> insertUserIfNotExists(
    Map<String, dynamic> user,
  ) async {

    final db =
        await database;

    final result =
        await db.query('users');

    if (result.isEmpty) {

      await db.insert(
        'users',
        user,
      );
    }
  }

  // =========================
  // GET USERS
  // =========================

  Future<List<Map<String, dynamic>>> getUsers() async {

    final db =
        await database;

    return await db.query(
      'users',
    );
  }

  // =========================
  // UPDATE USER
  // =========================

  Future<int> updateUser(

    Map<String, dynamic> user,

    int id,
  ) async {

    final db =
        await database;

    return await db.update(

      'users',

      user,

      where: 'id = ?',

      whereArgs: [id],
    );
  }
}