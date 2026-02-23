import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local SQLite gateway for simple persistence (player names for now).
class LocalDb {
  LocalDb._();

  static final LocalDb instance = LocalDb._();
  static const String defaultPresetId = 'default';

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'odapitch.sqlite');

    final db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE player_names ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'name TEXT NOT NULL,'
          'position INTEGER NOT NULL'
          ')',
        );

        await db.execute(
          'CREATE TABLE app_settings ('
          'key TEXT PRIMARY KEY,'
          'value TEXT NOT NULL'
          ')',
        );

        await db.execute(
          'CREATE TABLE app_cache ('
          'key TEXT PRIMARY KEY,'
          'value TEXT NOT NULL,'
          'expires_at INTEGER,'
          'updated_at INTEGER NOT NULL'
          ')',
        );

        await db.insert('app_settings', {
          'key': 'selected_preset_id',
          'value': defaultPresetId,
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS app_settings ('
            'key TEXT PRIMARY KEY,'
            'value TEXT NOT NULL'
            ')',
          );

          await db.execute(
            'CREATE TABLE IF NOT EXISTS app_cache ('
            'key TEXT PRIMARY KEY,'
            'value TEXT NOT NULL,'
            'expires_at INTEGER,'
            'updated_at INTEGER NOT NULL'
            ')',
          );

          await db.insert(
            'app_settings',
            {
              'key': 'selected_preset_id',
              'value': defaultPresetId,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
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

  Future<String> loadSelectedPresetId({String fallback = defaultPresetId}) async {
    if (kIsWeb) {
      return fallback;
    }

    final db = await database;
    final rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['selected_preset_id'],
      limit: 1,
    );

    if (rows.isEmpty) {
      await saveSelectedPresetId(fallback);
      return fallback;
    }

    return rows.first['value'] as String;
  }

  Future<void> saveSelectedPresetId(String presetId) async {
    if (kIsWeb) {
      return;
    }

    final db = await database;
    await db.insert(
      'app_settings',
      {
        'key': 'selected_preset_id',
        'value': presetId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> loadAppSetting(String key) async {
    if (kIsWeb) {
      return null;
    }

    final db = await database;
    final rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return rows.first['value'] as String;
  }

  Future<void> saveAppSetting(String key, String value) async {
    if (kIsWeb) {
      return;
    }

    final db = await database;
    await db.insert(
      'app_settings',
      {
        'key': key,
        'value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> loadCache(String key) async {
    if (kIsWeb) {
      return null;
    }

    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final rows = await db.query(
      'app_cache',
      columns: ['value', 'expires_at'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final expiresAt = rows.first['expires_at'] as int?;
    if (expiresAt != null && expiresAt <= now) {
      await db.delete('app_cache', where: 'key = ?', whereArgs: [key]);
      return null;
    }

    return rows.first['value'] as String;
  }

  Future<void> saveCache(String key, String value, {Duration? ttl}) async {
    if (kIsWeb) {
      return;
    }

    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = ttl == null ? null : now + ttl.inMilliseconds;

    await db.insert(
      'app_cache',
      {
        'key': key,
        'value': value,
        'expires_at': expiresAt,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearExpiredCache() async {
    if (kIsWeb) {
      return;
    }

    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.delete(
      'app_cache',
      where: 'expires_at IS NOT NULL AND expires_at <= ?',
      whereArgs: [now],
    );
  }
}
