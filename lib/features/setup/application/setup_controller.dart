import 'dart:math';

import '../../../models/game_settings.dart';
import '../../setup/domain/setup_repository.dart';

class SetupInitialData {
  final List<String> playerNames;
  final String selectedPresetId;
  final GameSettings settings;

  const SetupInitialData({
    required this.playerNames,
    required this.selectedPresetId,
    required this.settings,
  });
}

class SetupController {
  final SetupRepository _repository;

  SetupController(this._repository);

  Future<SetupInitialData> loadInitialData() async {
    final playerNames = await _repository.loadPlayerNames();
    final selectedPresetId = await _repository.loadSelectedPresetId();
    final settings = await _repository.loadGameSettings();

    return SetupInitialData(
      playerNames: playerNames,
      selectedPresetId: selectedPresetId,
      settings: settings,
    );
  }

  Future<String> loadSelectedPresetId() {
    return _repository.loadSelectedPresetId();
  }

  Future<void> saveSelectedPresetId(String presetId) {
    return _repository.saveSelectedPresetId(presetId);
  }

  Future<void> saveSetup({
    required List<String> playerNames,
    required GameSettings settings,
    required String selectedPresetId,
  }) async {
    await _repository.savePlayerNames(playerNames);
    await _repository.saveSelectedPresetId(selectedPresetId);
    await _repository.saveGameSettings(settings);
  }

  int clampPlayerCount(int count) => max(3, min(8, count));
}
