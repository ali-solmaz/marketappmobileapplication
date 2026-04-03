import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> getDB() async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'urunler.db');

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY,
            token TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE sepet (
            id INTEGER PRIMARY KEY,
            name TEXT,
            price REAL,
            adet INTEGER
          )
        ''');
        db.execute('''
            CREATE TABLE users (
              id INTEGER PRIMARY KEY,
              token TEXT
            )
        ''');

      },
    );

    return _db!;
  }

  static Future<void> insert(Map<String, dynamic> urun) async {
    final db = await getDB();
    await db.insert('sepet', urun,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> clear() async {
    final db = await getDB();
    await db.delete('sepet');
  }

  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await getDB();
    final result = await db.query('sepet');
    return result;
  }

  static Future<void> delete(int id) async {
    final db = await getDB();
    await db.delete('sepet', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> update(int id, int yeniAdet) async {
    final db = await getDB();
    await db.update(
      'sepet',
      {'adet': yeniAdet},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  static Future<void> clearSepet() async {
    final db = await getDB();
    await db.delete('sepet');
  }

  static Future<void> saveToken(String token) async {
    final db = await getDB();
    await db.delete('users');
    await db.insert('users', {'token': token});
  }

  static Future<String?> getToken() async {
    final db = await getDB();
    final result = await db.query('users', limit: 1);
    if (result.isEmpty) return null;
    return result.first['token'] as String?;
  }

  static Future<void> deleteToken() async {
    final db = await getDB();
    await db.delete('users');
  }
}