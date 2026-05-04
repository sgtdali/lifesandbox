import 'dart:math';

import '../../../game/models/game_state.dart';
import '../../conditions/models/ongoing_condition.dart';
import '../../conditions/services/condition_catalog.dart';
import '../../wellbeing/models/wellbeing_state.dart';
import '../../wellbeing/services/wellbeing_service.dart';
import '../data/event_catalog.dart';
import '../models/event_choice.dart';
import '../models/event_resolution.dart';
import '../models/event_effect.dart';
import '../models/life_event.dart';
import '../models/pending_event.dart';
import '../models/scheduled_event.dart';

class EventService {
  const EventService();

  static const eventChancePercent = 45;
  static const recentEventLimit = 4;
  static const recentCategoryLimit = 3;

  EventGenerationResult generateMonthlyEvent(GameState state) {
    if (state.pendingEvent != null) {
      return EventGenerationResult(state: state, pendingEvent: null);
    }

    final followUp = _dueFollowUp(state);
    if (followUp != null) {
      final event = _eventById(followUp.eventId);
      final nextScheduled = state.scheduledEvents
          .where((item) => item.eventId != followUp.eventId)
          .where((item) => item.targetMonth >= state.month - 1)
          .toList();
      if (event != null && _isEligible(event, state)) {
        return EventGenerationResult(
          state: state.copyWith(scheduledEvents: nextScheduled),
          pendingEvent: PendingEvent(event: event, generatedMonth: state.month),
        );
      }
      state = state.copyWith(scheduledEvents: nextScheduled);
    }

    final random = Random(_seedFor(state.month, state.player.cash));
    if (random.nextInt(100) >= eventChancePercent) {
      return EventGenerationResult(state: state, pendingEvent: null);
    }

    final eligible = eventCatalog
        .where((event) => _isEligible(event, state))
        .where((event) => !event.followUpOnly)
        .where((event) => !state.recentEventIds.contains(event.id))
        .toList();
    final candidates = eligible.isEmpty
        ? eventCatalog
            .where((event) => _isEligible(event, state))
            .where((event) => !event.followUpOnly)
            .toList()
        : eligible;

    if (candidates.isEmpty) {
      return EventGenerationResult(state: state, pendingEvent: null);
    }

    final totalWeight = candidates.fold<int>(
      0,
      (total, event) => total + _contextualWeight(event, state),
    );
    var roll = random.nextInt(totalWeight);

    for (final event in candidates) {
      roll -= _contextualWeight(event, state);
      if (roll < 0) {
        return EventGenerationResult(
          state: state,
          pendingEvent: PendingEvent(event: event, generatedMonth: state.month),
        );
      }
    }

    return EventGenerationResult(
      state: state,
      pendingEvent: PendingEvent(event: candidates.first, generatedMonth: state.month),
    );
  }

  EventApplyResult resolveChoice({
    required GameState state,
    required EventChoice choice,
  }) {
    final effect = choice.effect;
    final updatedStats = state.player.stats.apply(
      health: effect.health,
      happiness: effect.happiness,
      stress: effect.stress,
      intelligence: effect.intelligence,
    );
    final updatedPlayer = state.player.copyWith(
      cash: state.player.cash + effect.cash,
      reliabilityScore:
          (state.player.reliabilityScore + effect.reliability)
              .clamp(0, 100)
              .toInt(),
      stats: updatedStats,
    );

    final pending = state.pendingEvent!;
    final recent = [pending.event.id, ...state.recentEventIds]
        .take(recentEventLimit)
        .toList();
    final recentCategories = [pending.event.category, ...state.recentEventCategories]
        .take(recentCategoryLimit)
        .toList();
    final conditions = _applyConditionEffects(state, effect);
    final scheduled = _scheduleFollowUp(
      state: state,
      effect: effect,
      sourceEventId: pending.event.id,
    );

    return EventApplyResult(
      state: state.copyWith(
        player: updatedPlayer,
        activeConditions: conditions,
        scheduledEvents: scheduled,
        recentEventIds: recent,
        recentEventCategories: recentCategories,
        clearPendingEvent: true,
        clearLastMonthResult: true,
      ),
      resolution: EventResolution(
        title: pending.event.title,
        resultText: choice.resultText,
        effectSummary: effect.summary,
      ),
    );
  }

  bool _isEligible(LifeEvent event, GameState state) {
    switch (event.condition) {
      case EventCondition.always:
        return true;
      case EventCondition.employed:
        return state.currentJob != null;
      case EventCondition.unemployed:
        return state.currentJob == null;
      case EventCondition.activeEducation:
        return state.activeEducation != null;
      case EventCondition.lowQualityHousing:
        return state.currentHousing.id == 'shared_room' ||
            state.currentHousing.id == 'tiny_studio';
      case EventCondition.highStress:
        return state.player.stats.stress >= 60;
      case EventCondition.wellbeingPressure:
        final tier = const WellbeingService().evaluate(state).tier;
        return tier == WellbeingTier.strained ||
            tier == WellbeingTier.drained ||
            tier == WellbeingTier.burnoutRisk;
      case EventCondition.positiveWellbeing:
        final tier = const WellbeingService().evaluate(state).tier;
        return tier == WellbeingTier.stable || tier == WellbeingTier.thriving;
      case EventCondition.debtPressure:
        return state.activeDebts.any((debt) => debt.isEmergency) ||
            state.activeDebts.fold<int>(
                  0,
                  (total, debt) => total + debt.remainingBalance,
                ) >
                state.player.cash + 120;
      case EventCondition.activeCompany:
        return state.activeCompany != null;
      case EventCondition.fragileCompany:
        final company = state.activeCompany;
        return company != null &&
            (company.health < 50 ||
                company.pipeline < 30 ||
                company.operations < 30 ||
                company.lastNetResult < -20);
      case EventCondition.careerMomentum:
        return state.currentJob != null &&
            (state.jobPerformanceScore >= 70 ||
                _hasCondition(state, 'career_momentum'));
      case EventCondition.activeCondition:
        return event.contextConditionIds.any((id) => _hasCondition(state, id));
      case EventCondition.scheduledFollowUp:
        return true;
    }
  }

  int _contextualWeight(LifeEvent event, GameState state) {
    var weight = event.weight;
    final wellbeing = const WellbeingService().evaluate(state);
    final hasCategoryRecent = state.recentEventCategories.contains(event.category);

    if (hasCategoryRecent) weight -= 4;
    if (event.contextConditionIds.any((id) => _hasCondition(state, id))) weight += 12;
    if (event.category == 'Wellbeing' &&
        (wellbeing.tier == WellbeingTier.drained ||
            wellbeing.tier == WellbeingTier.burnoutRisk)) {
      weight += 14;
    }
    if (event.category == 'Finance' && _isEligible(event, state) &&
        event.condition == EventCondition.debtPressure) {
      weight += 12;
    }
    if (event.category == 'Company' && state.activeCompany != null) {
      final company = state.activeCompany!;
      weight += company.health < 50 ||
              company.pipeline < 35 ||
              company.operations < 35
          ? 12
          : 4;
      if (event.tone == EventTone.positive &&
          company.pipeline >= 60 &&
          company.momentum >= 55) {
        weight += 8;
      }
    }
    if (event.category == 'Career' && state.currentJob != null) {
      weight += state.jobPerformanceScore >= 70 ? 8 : 2;
    }
    if (event.tone == EventTone.negative &&
        state.recentEventCategories.length >= 2 &&
        state.player.stats.stress >= 75) {
      weight -= 3;
    }
    if (event.tone == EventTone.positive &&
        (wellbeing.tier == WellbeingTier.thriving ||
            _hasCondition(state, 'good_routine'))) {
      weight += 5;
    }

    return weight.clamp(1, 80).toInt();
  }

  List<OngoingCondition> _applyConditionEffects(
    GameState state,
    EventEffect effect,
  ) {
    final byId = {
      for (final condition in state.activeConditions) condition.id: condition,
    };
    for (final id in effect.removeConditionIds) {
      byId.remove(id);
    }
    for (final id in effect.addConditionIds) {
      if (!ConditionCatalog.contains(id)) continue;
      final condition = ConditionCatalog.create(id);
      final current = byId[id];
      byId[id] = current == null ||
              condition.remainingMonths > current.remainingMonths
          ? condition
          : current;
    }
    return byId.values.toList()..sort((a, b) => a.title.compareTo(b.title));
  }

  List<ScheduledEvent> _scheduleFollowUp({
    required GameState state,
    required EventEffect effect,
    required String sourceEventId,
  }) {
    final followUpId = effect.followUpEventId;
    final existing = state.scheduledEvents
        .where((event) => event.eventId != followUpId)
        .toList();
    if (followUpId == null) return existing;
    return [
      ...existing,
      ScheduledEvent(
        eventId: followUpId,
        targetMonth: state.month + effect.followUpDelayMonths,
        sourceEventId: sourceEventId,
      ),
    ];
  }

  ScheduledEvent? _dueFollowUp(GameState state) {
    final due = state.scheduledEvents
        .where((event) => event.targetMonth <= state.month)
        .toList()
      ..sort((a, b) => a.targetMonth.compareTo(b.targetMonth));
    return due.isEmpty ? null : due.first;
  }

  LifeEvent? _eventById(String id) {
    for (final event in eventCatalog) {
      if (event.id == id) return event;
    }
    return null;
  }

  bool _hasCondition(GameState state, String id) {
    return state.activeConditions.any((condition) => condition.id == id);
  }

  int _seedFor(int month, int cash) {
    return month * 997 + cash * 13;
  }
}

class EventGenerationResult {
  const EventGenerationResult({
    required this.state,
    required this.pendingEvent,
  });

  final GameState state;
  final PendingEvent? pendingEvent;
}

class EventApplyResult {
  const EventApplyResult({
    required this.state,
    required this.resolution,
  });

  final GameState state;
  final EventResolution resolution;
}
