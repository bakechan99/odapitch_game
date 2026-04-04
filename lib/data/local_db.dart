import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/game_settings.dart';
import 'dart:io'; // 追加

/// Local SQLite gateway for simple persistence (player names for now).
class LocalDb {
  LocalDb._();

  static final LocalDb instance = LocalDb._();
  static const String defaultPresetId = 'rikei';
  static const String defaultOdaiPresetId = 'rikei';
  static const String _keySelectedOdaiPresetId = 'selected_odai_preset_id';
  static const String _keyPresentationTimeSec = 'presentation_time_sec';
  static const String _keyQaTimeSec = 'qa_time_sec';
  static const String _keyPlayerCount = 'player_count';

  Database? _db;

  Future<Database> get database async {
    final existing = _db;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();

    // ▼ 以下を追加：ディレクトリが存在しない場合は作成する ▼
    final dir = Directory(dbPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    // ▲ ここまで ▲

    final path = join(dbPath, 'odapitch.sqlite');

    final db = await openDatabase(
      path,
      version: 6,
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

        await db.execute(
          'CREATE TABLE play_sessions ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'odai_theme TEXT NOT NULL,'
          'created_at INTEGER NOT NULL'
          ')',
        );

        await db.execute(
          'CREATE TABLE game_history ('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'session_id INTEGER NOT NULL,'
          'player_name TEXT NOT NULL,'
          'research_title TEXT NOT NULL,'
          'ai_feedback TEXT NOT NULL'
          ')',
        );

        await db.insert('app_settings', {
          'key': 'selected_preset_id',
          'value': defaultPresetId,
        });

        await db.insert('app_settings', {
          'key': _keySelectedOdaiPresetId,
          'value': defaultOdaiPresetId,
        });

        await db.insert('app_settings', {
          'key': _keyPresentationTimeSec,
          'value': GameSettings.defaultPresentationTimeSec.toString(),
        });

        await db.insert('app_settings', {
          'key': _keyQaTimeSec,
          'value': GameSettings.defaultQaTimeSec.toString(),
        });

        await db.insert('app_settings', {
          'key': _keyPlayerCount,
          'value': GameSettings.defaultPlayerCount.toString(),
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

          await db.insert('app_settings', {
            'key': 'selected_preset_id',
            'value': defaultPresetId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await db.insert('app_settings', {
            'key': _keyPresentationTimeSec,
            'value': GameSettings.defaultPresentationTimeSec.toString(),
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await db.insert('app_settings', {
            'key': _keyQaTimeSec,
            'value': GameSettings.defaultQaTimeSec.toString(),
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await db.insert('app_settings', {
            'key': _keyPlayerCount,
            'value': GameSettings.defaultPlayerCount.toString(),
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await db.insert('app_settings', {
            'key': _keySelectedOdaiPresetId,
            'value': defaultOdaiPresetId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }

        if (oldVersion < 3) {
          await db.insert('app_settings', {
            'key': _keyPresentationTimeSec,
            'value': GameSettings.defaultPresentationTimeSec.toString(),
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await db.insert('app_settings', {
            'key': _keyQaTimeSec,
            'value': GameSettings.defaultQaTimeSec.toString(),
          }, conflictAlgorithm: ConflictAlgorithm.ignore);

          await db.insert('app_settings', {
            'key': _keyPlayerCount,
            'value': GameSettings.defaultPlayerCount.toString(),
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }

        if (oldVersion < 4) {
          await db.insert('app_settings', {
            'key': _keySelectedOdaiPresetId,
            'value': defaultOdaiPresetId,
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }

        if (oldVersion < 5) {
          await db.execute(
            'CREATE TABLE IF NOT EXISTS game_history ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT,'
            'odai_theme TEXT NOT NULL,'
            'player_name TEXT NOT NULL,'
            'research_title TEXT NOT NULL,'
            'ai_feedback TEXT NOT NULL,'
            'created_at INTEGER NOT NULL'
            ')',
          );
        }

        if (oldVersion < 6) {
          // 旧 game_history を削除し、新スキーマに移行（履歴はリセット）
          await db.execute('DROP TABLE IF EXISTS game_history');
          await db.execute(
            'CREATE TABLE play_sessions ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT,'
            'odai_theme TEXT NOT NULL,'
            'created_at INTEGER NOT NULL'
            ')',
          );
          await db.execute(
            'CREATE TABLE game_history ('
            'id INTEGER PRIMARY KEY AUTOINCREMENT,'
            'session_id INTEGER NOT NULL,'
            'player_name TEXT NOT NULL,'
            'research_title TEXT NOT NULL,'
            'ai_feedback TEXT NOT NULL'
            ')',
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
    final rows = await db.query('player_names', orderBy: 'position ASC');

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
        await txn.insert('player_names', {'name': names[i], 'position': i});
      }
    });
  }

  Future<String> loadSelectedPresetId({
    String fallback = defaultPresetId,
  }) async {
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
    await db.insert('app_settings', {
      'key': 'selected_preset_id',
      'value': presetId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String> loadSelectedOdaiPresetId({
    String fallback = defaultOdaiPresetId,
  }) async {
    if (kIsWeb) {
      return fallback;
    }

    final db = await database;
    final rows = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_keySelectedOdaiPresetId],
      limit: 1,
    );

    if (rows.isEmpty) {
      await saveSelectedOdaiPresetId(fallback);
      return fallback;
    }

    return rows.first['value'] as String;
  }

  Future<void> saveSelectedOdaiPresetId(String presetId) async {
    if (kIsWeb) {
      return;
    }

    final db = await database;
    await db.insert('app_settings', {
      'key': _keySelectedOdaiPresetId,
      'value': presetId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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
    await db.insert('app_settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<GameSettings> loadGameSettings() async {
    if (kIsWeb) {
      return GameSettings.defaults;
    }

    final presentation = await loadAppSetting(_keyPresentationTimeSec);
    final qa = await loadAppSetting(_keyQaTimeSec);
    final playerCount = await loadAppSetting(_keyPlayerCount);

    return GameSettings.fromSettingsMap({
      _keyPresentationTimeSec: presentation,
      _keyQaTimeSec: qa,
      _keyPlayerCount: playerCount,
    });
  }

  Future<void> saveGameSettings(GameSettings settings) async {
    if (kIsWeb) {
      return;
    }

    final map = settings.toSettingsMap();
    for (final entry in map.entries) {
      await saveAppSetting(entry.key, entry.value);
    }
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

    await db.insert('app_cache', {
      'key': key,
      'value': value,
      'expires_at': expiresAt,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
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

  // ── プレイ履歴 ──────────────────────────────────────────────

  static const int _historyMaxCount = 10;

  /// 1回のプレイ（セッション）分の履歴を保存する。
  /// [players] は各プレイヤーの {'name', 'title', 'feedback'} マップのリスト。
  /// セッション数が10を超えた場合は最古のセッションを自動削除（FIFO）。
  Future<void> saveHistory({
    required String odaiTheme,
    required List<Map<String, String>> players,
  }) async {
    if (kIsWeb) return;

    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      // セッション行を挿入
      final sessionId = await txn.insert('play_sessions', {
        'odai_theme': odaiTheme,
        'created_at': now,
      });

      // プレイヤー行を挿入
      for (final p in players) {
        await txn.insert('game_history', {
          'session_id': sessionId,
          'player_name': p['name'] ?? '',
          'research_title': p['title'] ?? '',
          'ai_feedback': p['feedback'] ?? '',
        });
      }

      // 10セッションを超えていたら最古のセッション（＋その子行）を削除
      final countResult = await txn.rawQuery(
        'SELECT COUNT(*) as cnt FROM play_sessions',
      );
      final int count = (countResult.first['cnt'] as int?) ?? 0;
      if (count > _historyMaxCount) {
        final oldest = await txn.query(
          'play_sessions',
          columns: ['id'],
          orderBy: 'created_at ASC',
          limit: count - _historyMaxCount,
        );
        for (final row in oldest) {
          final sid = row['id'] as int;
          await txn.delete(
            'game_history',
            where: 'session_id = ?',
            whereArgs: [sid],
          );
          await txn.delete(
            'play_sessions',
            where: 'id = ?',
            whereArgs: [sid],
          );
        }
      }
    });
  }

  /// 保存済みセッション履歴を新しい順で返す（最大10件）。
  /// 各エントリは {'session_id', 'odai_theme', 'created_at', 'players': List} の形式。
  Future<List<Map<String, dynamic>>> loadHistory() async {
    if (kIsWeb) return [];

    final db = await database;
    final sessions = await db.query(
      'play_sessions',
      orderBy: 'created_at DESC',
      limit: _historyMaxCount,
    );

    final List<Map<String, dynamic>> result = [];
    for (final session in sessions) {
      final sessionId = session['id'] as int;
      final players = await db.query(
        'game_history',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );
      result.add({
        'session_id': sessionId,
        'odai_theme': session['odai_theme'] as String,
        'created_at': session['created_at'] as int,
        'players': players,
      });
    }
    return result;
  }
}
