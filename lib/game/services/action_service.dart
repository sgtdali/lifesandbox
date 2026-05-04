import '../models/action_definition.dart';
import '../models/action_type.dart';
import '../models/game_state.dart';
import '../models/player_state.dart';
import '../../features/wellbeing/services/wellbeing_service.dart';

class ActionService {
  const ActionService();

  List<ActionDefinition> get availableActions => const [
        ActionDefinition(
          type: ActionType.rest,
          title: 'Rest',
          description: 'Recover a little and bring stress down.',
          energyCost: 5,
          health: 2,
          happiness: 3,
          stress: -7,
        ),
        ActionDefinition(
          type: ActionType.deepRest,
          title: 'Deep Rest',
          description: 'Spend the month carefully recovering health and stress.',
          energyCost: 12,
          health: 5,
          happiness: 1,
          stress: -12,
          conditionId: 'recovery_phase',
        ),
        ActionDefinition(
          type: ActionType.walk,
          title: 'Exercise / Walk',
          description: 'Improve health and mood without spending cash.',
          energyCost: 18,
          health: 4,
          happiness: 2,
          stress: -4,
          conditionId: 'good_routine',
        ),
        ActionDefinition(
          type: ActionType.personalReset,
          title: 'Personal Reset',
          description: 'Pay for a low-key reset that calms the month.',
          energyCost: 10,
          cashCost: 18,
          happiness: 4,
          stress: -8,
          conditionId: 'good_routine',
        ),
        ActionDefinition(
          type: ActionType.socialTime,
          title: 'Social Time',
          description: 'Spend time and a little cash to restore mood.',
          energyCost: 16,
          cashCost: 14,
          happiness: 7,
          stress: -3,
          conditionId: 'social_uplift',
        ),
        ActionDefinition(
          type: ActionType.selfStudy,
          title: 'Self Study',
          description: 'Improve intelligence at the cost of focus and stress.',
          energyCost: 35,
          intelligence: 4,
          stress: 4,
          happiness: -1,
        ),
        ActionDefinition(
          type: ActionType.lookAround,
          title: 'Look Around',
          description: 'Scout for future opportunities. Placeholder for now.',
          energyCost: 25,
          stress: 2,
          happiness: 1,
        ),
      ];

  GameState applyAction(GameState state, ActionDefinition action) {
    if (!canAfford(state, action)) return state;

    final updatedStats = state.player.stats.apply(
      health: action.health,
      happiness: action.happiness,
      stress: action.stress,
      energy: -action.energyCost,
      intelligence: action.intelligence,
    );

    var nextState = state.copyWith(
      player: state.player.copyWith(
        cash: state.player.cash - action.cashCost,
        stats: updatedStats,
      ),
      clearLastMonthResult: true,
    );
    final conditionId = action.conditionId;
    if (conditionId != null) {
      nextState = const WellbeingService().markRecoveryAction(nextState, conditionId);
    }
    return nextState;
  }

  bool canAfford(GameState state, ActionDefinition action) {
    return state.player.stats.energy >= action.energyCost &&
        state.player.cash >= action.cashCost;
  }

  bool hasMeaningfulEnergy(PlayerState player) {
    return availableActions.any(
      (action) => player.stats.energy >= action.energyCost,
    );
  }
}
