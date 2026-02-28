import '../../../models/game_settings.dart';

abstract class SetupRepository {
  Future<List<String>> loadPlayerNames();
  Future<void> savePlayerNames(List<String> names);

  Future<String> loadSelectedPresetId();
  Future<void> saveSelectedPresetId(String presetId);

  Future<GameSettings> loadGameSettings();
  Future<void> saveGameSettings(GameSettings settings);
}
