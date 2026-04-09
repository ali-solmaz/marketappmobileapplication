import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:marketapp2/data/migration/migrationQuery.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> getDB() async {
    if (_db != null) return _db!;

    final path = join(await getDatabasesPath(), 'marketapp.db');

    _db = await openDatabase(
      path,
      version: migraitons.length,
      onCreate: (db, version) {
        for (var query in migraitons) {
          db.execute(query);
        }
      },
      onUpgrade: (db, oldversion, newversion) async {
        for (int i = oldversion; i < newversion; i++) {
          db.execute(migraitons[i]);
        }
      },
    );

    return _db!;
  }

  static Future<void> insert(Map<String, dynamic> urun) async {
    final db = await getDB();
    await db.insert(
      'sepet',
      urun,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
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

  static Future<void> saveTokenandApiUserID(String token, int apiUserId) async {
    final db = await getDB();
    await db.delete('users');
    await db.insert('users', {'token': token, 'apiUserId': apiUserId});
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

  static Future<int> getUserId() async {
    final db = await getDB();
    List<Map<String, dynamic>> result = await db.query(
      'users',
      where: 'id = 1',
    );

    int apiUserID = result.first['apiUserId'];

    return apiUserID;
  }
}
