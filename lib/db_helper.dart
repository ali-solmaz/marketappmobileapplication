import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  // Veritabanını aç (yoksa oluştur)
  static Future<Database> getDB() async {
    if (_db != null) return _db!; // zaten açıksa tekrar açma

    final path = join(await getDatabasesPath(), 'urunler.db'); // telefonda dosya yolu

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        // tablo ilk seferinde oluşturulur
        return db.execute('''
          CREATE TABLE sepet (
            id INTEGER PRIMARY KEY,        
            name TEXT,
            price REAL,
            adet INTEGER                   
          )
        ''');
      },
    );

    return _db!;
  }

  // Ürün ekle
  static Future<void> insert(Map<String, dynamic> urun) async {
    final db = await getDB();
    print('DB Insert: $urun');
    // Aynı ID varsa adet artır, yoksa yeni ekle
    await db.insert('sepet', urun,
        conflictAlgorithm: ConflictAlgorithm.replace);  // ← urunler yerine sepet
  }

  // Tüm ürünleri sil (temizle)
  static Future<void> clear() async {
    final db = await getDB();
    await db.delete('sepet');
  }

  // Tüm ürünleri getir
  static Future<List<Map<String, dynamic>>> getAll() async {
    final db = await getDB();
    final result = await db.query('sepet');
    print('DB GetAll: $result');
    return result;
  }

  // Ürün sil
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
    await db.delete('sepet'); // tüm satırları sil
  }
}