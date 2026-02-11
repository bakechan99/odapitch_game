import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local SQLite gateway for simple persistence (player names for now).
class LocalDb {
  LocalDb._();

  static final LocalDb instance = LocalDb._();
  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'odapitch.sqlite');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(''
            'CREATE TABLE player_names ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT,'
            'name TEXT NOT NULL,'
            'position INTEGER NOT NULL'
            ')');
      },
    );

    _db = db;
    return db;
  }

  Future<List<String>> loadPlayerNames() async {
    if (kIsWeb) {
      return [];
    }
    final db = await database;
    final rows = await db.query(
      'player_names',
      orderBy: 'position ASC',
    );

    return rows.map((row) => row['name'] as String).toList();
  }

  Future<void> savePlayerNames(List<String> names) async {
    if (kIsWeb) {
      return;
    }
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('player_names');
      for (int i = 0; i < names.length; i++) {
        await txn.insert('player_names', {
          'name': names[i],
          'position': i,
        });
      }
    });
  }
}
