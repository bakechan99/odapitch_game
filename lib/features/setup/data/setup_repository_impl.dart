import '../../../data/local_db.dart';
import '../../../models/game_settings.dart';
import '../../settings/domain/game_settings_repository.dart';
import '../../settings/data/game_settings_repository_impl.dart';
import '../domain/setup_repository.dart';

class SetupRepositoryImpl implements SetupRepository {
  final LocalDb _localDb;
  final GameSettingsRepository _gameSettingsRepository;

  SetupRepositoryImpl({
    LocalDb? localDb,
    GameSettingsRepository? gameSettingsRepository,
  })  : _localDb = localDb ?? LocalDb.instance,
        _gameSettingsRepository = gameSettingsRepository ?? GameSettingsRepositoryImpl(localDb: localDb);

  @override
  Future<List<String>> loadPlayerNames() {
    return _localDb.loadPlayerNames();
  }

  @override
  Future<void> savePlayerNames(List<String> names) {
    return _localDb.savePlayerNames(names);
  }

  @override
  Future<String> loadSelectedPresetId() {
    return _localDb.loadSelectedPresetId();
  }

  @override
  Future<void> saveSelectedPresetId(String presetId) {
    return _localDb.saveSelectedPresetId(presetId);
  }

  @override
  Future<GameSettings> loadGameSettings() {
    return _gameSettingsRepository.loadGameSettings();
  }

  @override
  Future<void> saveGameSettings(GameSettings settings) {
    return _gameSettingsRepository.saveGameSettings(settings);
  }
}
