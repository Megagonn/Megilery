import 'package:gallery/model/model.info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class MyDb {
  MyDb._();
  //assign the private constructor to a static variable
  // a class owns a static variable
  static final MyDb db = MyDb._();

  static Database? _database;
  Future<Database> get database async {
    return _database ??= await init();
  }

  //-------Initialize the database----------
  Future<Database> init() async {
    //get the path using getDatabasesPath()
    return await openDatabase(
      join(await getDatabasesPath(), 'note.db'),
      onCreate: (db, version) {
        db.execute('''
            CREATE TABLE favourite (id INTEGER PRIMARY KEY AUTOINCREMENT, original TEXT, portrait TEXT, alt TEXT, photographer TEXT)
          ''');
      },
      version: 1,
    );
  }

  //---------Get the data from the database-------
  getDatabaseInfo() async {
    var db = await database;
    var info = await db.query('favourite');
    if (info.isEmpty) {
      return null;
    } else {
      return info;
    }
  }

  addDatabase(Pexel pexel) async {
    var db = await database;
    await db.insert('favourite', pexel.toMap(pexel),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  toUpdate(int id, Pexel pexel) async {
    var db = await database;
    await db.update('favourite', pexel.toMap(pexel), where: 'id = ?', whereArgs: [id]);
  }

  toDelete(int id) async {
    var db = await database;
    await db.delete('favourite', where: 'id = ?', whereArgs: [id]);
    // await db.rawDelete('DELETE FROM note WHERE id = ?', [id]);
  }
}