import '../../../data/local_db.dart';
import '../../../models/game_settings.dart';
import '../domain/game_settings_repository.dart';

class GameSettingsRepositoryImpl implements GameSettingsRepository {
  final LocalDb _localDb;

  GameSettingsRepositoryImpl({LocalDb? localDb}) : _localDb = localDb ?? LocalDb.instance;

  @override
  Future<GameSettings> loadGameSettings() {
    return _localDb.loadGameSettings();
  }

  @override
  Future<void> saveGameSettings(GameSettings settings) {
    return _localDb.saveGameSettings(settings);
  }
}
