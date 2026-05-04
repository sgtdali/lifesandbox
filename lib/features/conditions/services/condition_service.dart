import '../../../game/models/game_state.dart';
import '../../../game/models/player_state.dart';
import '../../../game/models/stat_change.dart';
import '../../company/models/active_company.dart';
import '../models/ongoing_condition.dart';
import 'condition_catalog.dart';

class ConditionService {
  const ConditionService();

  ConditionMonthResult resolveMonth(GameState state) {
    var player = state.player;
    var company = state.activeCompany;
    var energyRecoveryModifier = 0;
    final statChanges = <StatChange>[];

    for (final condition in state.activeConditions) {
      final effect = condition.effect;
      if (effect.hasMonthlyStatEffect) {
        player = player.copyWith(
          stats: player.stats.apply(
            health: effect.health,
            happiness: effect.happiness,
            stress: effect.stress,
            intelligence: effect.intelligence,
          ),
          reliabilityScore:
              (player.reliabilityScore + effect.reliability).clamp(0, 100).toInt(),
        );

        if (company != null && (effect.companyHealth != 0 || effect.companyMomentum != 0)) {
          company = company.copyWith(
            health: (company.health + effect.companyHealth).clamp(0, 100).toInt(),
            momentum: (company.momentum + effect.companyMomentum).clamp(0, 100).toInt(),
          );
        }
      }
      energyRecoveryModifier += effect.energyRecovery;
      _collectStatChanges(statChanges, condition);
    }

    final ticked = <OngoingCondition>[];
    final expired = <String>[];
    for (final condition in state.activeConditions) {
      final remaining = condition.remainingMonths - 1;
      if (remaining <= 0) {
        expired.add(condition.title);
      } else {
        ticked.add(condition.copyWith(remainingMonths: remaining));
      }
    }

    final triggered = _triggerConditions(
      state.copyWith(
        player: player,
        activeCompany: company,
        clearActiveCompany: company == null,
      ),
    );
    final refreshResult = _merge(ticked, triggered);

    return ConditionMonthResult(
      player: player,
      activeCompany: company,
      activeConditions: refreshResult.conditions,
      energyRecoveryModifier: energyRecoveryModifier,
      statChanges: statChanges,
      gainedConditionTitles: refreshResult.gainedTitles,
      expiredConditionTitles: expired,
      messages: [
        for (final title in refreshResult.gainedTitles) 'Condition gained: $title.',
        for (final title in expired) 'Condition expired: $title.',
      ],
    );
  }

  int jobPerformanceModifier(GameState state) {
    return state.activeConditions.fold<int>(
      0,
      (total, condition) => total + condition.effect.jobPerformance,
    );
  }

  int studyProgressBonus(GameState state) {
    return state.activeConditions.fold<int>(
      0,
      (total, condition) => total + condition.effect.studyProgressBonus,
    );
  }

  List<OngoingCondition> _triggerConditions(GameState state) {
    final conditions = <OngoingCondition>[];
    final totalDebt = state.activeDebts.fold<int>(
      0,
      (total, debt) => total + debt.remainingBalance,
    );
    final hasEmergencyDebt = state.activeDebts.any((debt) => debt.isEmergency);
    final company = state.activeCompany;
    final education = state.activeEducation;

    if (state.player.stats.stress >= 78 ||
        (state.player.stats.stress >= 68 &&
            state.currentHousing.energyRecoveryModifier < 0)) {
      conditions.add(ConditionCatalog.create('burnout_risk'));
    }
    if (hasEmergencyDebt || (totalDebt > state.player.cash + 120 && totalDebt > 0)) {
      conditions.add(ConditionCatalog.create('money_anxiety'));
    }
    if (state.currentHousing.energyRecoveryModifier < 0 &&
        state.player.stats.stress >= 62) {
      conditions.add(ConditionCatalog.create('poor_sleep_cycle'));
    }
    if (state.currentHousing.energyRecoveryModifier >= 2 &&
        state.player.stats.stress <= 58) {
      conditions.add(ConditionCatalog.create('stable_housing_boost'));
    }
    if (state.player.stats.stress <= 48 &&
        state.player.cash >= 100 &&
        totalDebt <= state.player.cash + 80) {
      conditions.add(ConditionCatalog.create('good_routine'));
    }
    if (education != null && education.studyRequirementMet) {
      conditions.add(ConditionCatalog.create('focused_learning'));
    }
    if (state.currentJob != null &&
        state.jobPerformanceScore >= 72 &&
        state.workHistory.currentJobTenure >= 3) {
      conditions.add(ConditionCatalog.create('career_momentum'));
    }
    if (company != null &&
        (company.health < 45 ||
            company.pipeline < 30 ||
            company.operations < 30 ||
            company.lastNetResult < -25)) {
      conditions.add(ConditionCatalog.create('business_strain'));
    }
    if (state.player.stats.health < 78 &&
        state.player.stats.stress <= 42 &&
        totalDebt < 220) {
      conditions.add(ConditionCatalog.create('recovery_phase'));
    }
    if (state.player.stats.happiness >= 72 && state.player.stats.stress <= 60) {
      conditions.add(ConditionCatalog.create('social_uplift'));
    }

    return conditions.take(3).toList();
  }

  _ConditionMergeResult _merge(
    List<OngoingCondition> existing,
    List<OngoingCondition> triggered,
  ) {
    final byId = <String, OngoingCondition>{
      for (final condition in existing) condition.id: condition,
    };
    final gained = <String>[];

    for (final condition in triggered) {
      if (!ConditionCatalog.contains(condition.id)) continue;
      final current = byId[condition.id];
      if (current == null) {
        byId[condition.id] = condition;
        gained.add(condition.title);
      } else if (condition.remainingMonths > current.remainingMonths) {
        byId[condition.id] = current.copyWith(
          remainingMonths: condition.remainingMonths,
        );
      }
    }

    return _ConditionMergeResult(
      conditions: byId.values.toList()
        ..sort((a, b) => a.title.compareTo(b.title)),
      gainedTitles: gained,
    );
  }

  void _collectStatChanges(
    List<StatChange> changes,
    OngoingCondition condition,
  ) {
    final effect = condition.effect;
    if (effect.health != 0) {
      changes.add(StatChange(label: '${condition.title} health', amount: effect.health));
    }
    if (effect.happiness != 0) {
      changes.add(StatChange(label: '${condition.title} happiness', amount: effect.happiness));
    }
    if (effect.stress != 0) {
      changes.add(StatChange(label: '${condition.title} stress', amount: effect.stress));
    }
    if (effect.intelligence != 0) {
      changes.add(StatChange(label: '${condition.title} intelligence', amount: effect.intelligence));
    }
    if (effect.reliability != 0) {
      changes.add(StatChange(label: '${condition.title} reliability', amount: effect.reliability));
    }
    if (effect.energyRecovery != 0) {
      changes.add(StatChange(label: '${condition.title} energy recovery', amount: effect.energyRecovery));
    }
    if (effect.companyHealth != 0) {
      changes.add(StatChange(label: '${condition.title} company health', amount: effect.companyHealth));
    }
    if (effect.companyMomentum != 0) {
      changes.add(StatChange(label: '${condition.title} company momentum', amount: effect.companyMomentum));
    }
  }
}

class ConditionMonthResult {
  const ConditionMonthResult({
    required this.player,
    required this.activeCompany,
    required this.activeConditions,
    required this.energyRecoveryModifier,
    required this.statChanges,
    required this.gainedConditionTitles,
    required this.expiredConditionTitles,
    required this.messages,
  });

  final PlayerState player;
  final ActiveCompany? activeCompany;
  final List<OngoingCondition> activeConditions;
  final int energyRecoveryModifier;
  final List<StatChange> statChanges;
  final List<String> gainedConditionTitles;
  final List<String> expiredConditionTitles;
  final List<String> messages;
}

class _ConditionMergeResult {
  const _ConditionMergeResult({
    required this.conditions,
    required this.gainedTitles,
  });

  final List<OngoingCondition> conditions;
  final List<String> gainedTitles;
}
