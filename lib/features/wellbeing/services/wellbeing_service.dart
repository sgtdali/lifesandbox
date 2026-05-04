import '../../../game/models/game_state.dart';
import '../../../game/models/player_state.dart';
import '../../../game/models/stat_change.dart';
import '../../conditions/services/condition_catalog.dart';
import '../models/wellbeing_state.dart';

class WellbeingService {
  const WellbeingService();

  WellbeingEvaluation evaluate(GameState state) {
    final stats = state.player.stats;
    final hasBurnout = _hasCondition(state, 'burnout_risk');
    final hasGoodRoutine = _hasCondition(state, 'good_routine');
    final hasRecovery = _hasCondition(state, 'recovery_phase');
    final drivers = <String>[];
    var score = 0;

    score += ((stats.health - 50) / 4).round();
    score += ((stats.happiness - 50) / 5).round();
    score += ((50 - stats.stress) / 3).round();
    if (hasGoodRoutine) score += 5;
    if (hasRecovery) score += 4;
    if (hasBurnout) score -= 10;

    if (stats.stress >= 75) drivers.add('high stress');
    if (stats.health < 45) drivers.add('low health');
    if (stats.happiness < 45) drivers.add('low happiness');
    if (stats.stress <= 42 && stats.health >= 65) drivers.add('good recovery base');
    if (hasBurnout) drivers.add('burnout risk');
    if (hasGoodRoutine) drivers.add('good routine');
    if (drivers.isEmpty) drivers.add('balanced stats');

    if (hasBurnout || stats.stress >= 82) {
      return WellbeingEvaluation(
        tier: WellbeingTier.burnoutRisk,
        label: 'Burnout Risk',
        description: 'Stress is high enough to threaten consistency.',
        drivers: drivers.take(3).toList(),
        energyRecoveryModifier: -8,
        performanceModifier: -7,
        studyModifier: -4,
        companyActionPercent: -15,
      );
    }
    if (score <= -12 || stats.health < 38) {
      return WellbeingEvaluation(
        tier: WellbeingTier.drained,
        label: 'Drained',
        description: 'Recovery is weak and pressure is carrying over.',
        drivers: drivers.take(3).toList(),
        energyRecoveryModifier: -5,
        performanceModifier: -5,
        studyModifier: -3,
        companyActionPercent: -10,
      );
    }
    if (score <= 1 || stats.stress >= 62) {
      return WellbeingEvaluation(
        tier: WellbeingTier.strained,
        label: 'Strained',
        description: 'You can keep going, but the month has a cost.',
        drivers: drivers.take(3).toList(),
        energyRecoveryModifier: -2,
        performanceModifier: -2,
        studyModifier: -1,
        companyActionPercent: -5,
      );
    }
    if (score >= 18 && stats.stress <= 42) {
      return WellbeingEvaluation(
        tier: WellbeingTier.thriving,
        label: 'Thriving',
        description: 'Strong wellbeing is supporting consistency.',
        drivers: drivers.take(3).toList(),
        energyRecoveryModifier: 4,
        performanceModifier: 4,
        studyModifier: 2,
        companyActionPercent: 8,
      );
    }
    return WellbeingEvaluation(
      tier: WellbeingTier.stable,
      label: 'Stable',
      description: 'Your wellbeing is holding steady.',
      drivers: drivers.take(3).toList(),
      energyRecoveryModifier: 0,
      performanceModifier: 0,
      studyModifier: 0,
      companyActionPercent: 0,
    );
  }

  WellbeingMonthResult resolveMonth(GameState state) {
    final evaluation = evaluate(state);
    var player = state.player;
    final changes = <StatChange>[];
    final messages = <String>[
      'Wellbeing: ${evaluation.label}.',
    ];

    switch (evaluation.tier) {
      case WellbeingTier.thriving:
        player = _apply(
          player,
          health: 1,
          happiness: 1,
          stress: -1,
          changes: changes,
          label: 'Thriving',
        );
        break;
      case WellbeingTier.stable:
        break;
      case WellbeingTier.strained:
        player = _apply(
          player,
          happiness: -1,
          stress: 1,
          changes: changes,
          label: 'Strained',
        );
        break;
      case WellbeingTier.drained:
        player = _apply(
          player,
          health: -1,
          happiness: -2,
          stress: 2,
          changes: changes,
          label: 'Drained',
        );
        break;
      case WellbeingTier.burnoutRisk:
        player = _apply(
          player,
          health: -2,
          happiness: -2,
          stress: 3,
          changes: changes,
          label: 'Burnout risk',
        );
        break;
    }

    return WellbeingMonthResult(
      player: player,
      evaluation: evaluation,
      energyRecoveryModifier: evaluation.energyRecoveryModifier,
      statChanges: changes,
      messages: messages,
    );
  }

  int performanceModifier(GameState state) => evaluate(state).performanceModifier;

  int studyModifier(GameState state) => evaluate(state).studyModifier;

  int companyActionPercent(GameState state) => evaluate(state).companyActionPercent;

  GameState markRecoveryAction(GameState state, String conditionId) {
    final condition = ConditionCatalog.create(conditionId);
    final existing = state.activeConditions.where((item) => item.id != condition.id);
    return state.copyWith(activeConditions: [...existing, condition]);
  }

  PlayerState _apply(
    PlayerState player, {
    int health = 0,
    int happiness = 0,
    int stress = 0,
    required List<StatChange> changes,
    required String label,
  }) {
    if (health != 0) changes.add(StatChange(label: '$label health', amount: health));
    if (happiness != 0) {
      changes.add(StatChange(label: '$label happiness', amount: happiness));
    }
    if (stress != 0) changes.add(StatChange(label: '$label stress', amount: stress));
    return player.copyWith(
      stats: player.stats.apply(
        health: health,
        happiness: happiness,
        stress: stress,
      ),
    );
  }

  bool _hasCondition(GameState state, String id) {
    return state.activeConditions.any((condition) => condition.id == id);
  }
}

class WellbeingMonthResult {
  const WellbeingMonthResult({
    required this.player,
    required this.evaluation,
    required this.energyRecoveryModifier,
    required this.statChanges,
    required this.messages,
  });

  final PlayerState player;
  final WellbeingEvaluation evaluation;
  final int energyRecoveryModifier;
  final List<StatChange> statChanges;
  final List<String> messages;
}
