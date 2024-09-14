import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDB('party_planner.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE parties (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      description TEXT,
      date TEXT,
      guests TEXT
    )
    ''');
  }

  Future<void> addParty(String name, String description, String date, List<String> guests) async {
    final db = await instance.database;
    await db.insert('parties', {
      'name': name,
      'description': description,
      'date': date,
      'guests': guests.join(','),
    });
  }

  Future<List<Map<String, dynamic>>> getParties() async {
    final db = await instance.database;
    return await db.query('parties');
  }

  Future<void> updateParty(int id, String name, String description, String date, List<String> guests) async {
    final db = await instance.database;
    await db.update(
      'parties',
      {'name': name, 'description': description, 'date': date, 'guests': guests.join(',')},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteParty(int id) async {
    final db = await instance.database;
    await db.delete(
      'parties',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
