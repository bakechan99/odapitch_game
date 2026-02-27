import '../../../models/game_settings.dart';

abstract class GameSettingsRepository {
  Future<GameSettings> loadGameSettings();
  Future<void> saveGameSettings(GameSettings settings);
}
