import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';

class GamePersistenceService {
  static const _saveKey = 'life_sandbox_game_state_v1';

  Future<GameState?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawState = preferences.getString(_saveKey);
    if (rawState == null) return null;

    try {
      return GameState.fromJson(
        Map<String, dynamic>.from(jsonDecode(rawState) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(GameState state) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_saveKey, jsonEncode(state.toJson()));
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_saveKey);
  }
}
