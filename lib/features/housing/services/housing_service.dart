import '../../../game/models/game_state.dart';
import '../data/housing_catalog.dart';
import '../models/housing_option.dart';

class HousingService {
  const HousingService();

  List<HousingOption> get options => housingCatalog;

  HousingOption get defaultOption => defaultHousing();

  bool canMoveTo(GameState state, HousingOption option) {
    if (state.currentHousing.id == option.id) return false;
    return state.player.cash >= option.moveFee;
  }

  GameState moveTo(GameState state, HousingOption option) {
    if (!canMoveTo(state, option)) return state;

    return state.copyWith(
      currentHousing: option,
      player: state.player.copyWith(cash: state.player.cash - option.moveFee),
      clearLastMonthResult: true,
    );
  }
}
