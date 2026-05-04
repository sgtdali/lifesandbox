import '../../../game/models/game_state.dart';
import '../../finance/models/finance_snapshot.dart';
import '../../finance/services/finance_evaluator.dart';
import '../models/milestone_definition.dart';
import '../models/run_state_evaluation.dart';

class ProgressionService {
  const ProgressionService();

  List<MilestoneDefinition> get definitions => _definitions;

  GameState syncMilestones(GameState state) {
    final completed = completedMilestoneIds(state);
    if (_sameIds(completed, state.completedMilestoneIds)) return state;
    return state.copyWith(completedMilestoneIds: completed);
  }

  List<String> completedMilestoneIds(GameState state) {
    final ids = <String>{...state.completedMilestoneIds};
    for (final definition in _definitions) {
      if (definition.isComplete(state)) {
        ids.add(definition.id);
      }
    }
    return ids.toList()..sort();
  }

  List<MilestoneView> milestonesFor(GameState state) {
    final completed = completedMilestoneIds(state).toSet();
    return _definitions
        .map(
          (definition) => MilestoneView(
            definition: definition,
            completed: completed.contains(definition.id),
          ),
        )
        .toList();
  }

  RunStateEvaluation evaluateRunState(GameState state) {
    final cash = state.player.cash;
    final debt = _totalDebt(state);
    final monthlyDebt = _monthlyDebtPayment(state);
    final obligations = state.player.monthlyBaseExpense +
        state.currentHousing.monthlyCost +
        monthlyDebt +
        (state.activeEducation?.program.monthlyCost ?? 0);
    final hasIncome = state.currentJob != null || state.activeCompany != null;
    final company = state.activeCompany;
    final businessReady = company == null &&
        cash >= 260 &&
        debt <= 160 &&
        (state.completedEducations.isNotEmpty ||
            state.player.reliabilityScore >= 65 ||
            state.month >= 8);

    if (company != null) {
      if (company.health < 35 || cash < obligations ~/ 2) {
        return const RunStateEvaluation(
          tier: RunStateTier.recovering,
          label: 'Company Under Pressure',
          description: 'The business exists, but cash or company health is thin.',
        );
      }
      return const RunStateEvaluation(
        tier: RunStateTier.growing,
        label: 'Growing',
        description: 'You have moved into ownership and can build momentum.',
      );
    }

    if (cash < 60 || debt > cash + 180 || state.player.stats.stress >= 82) {
      return const RunStateEvaluation(
        tier: RunStateTier.unstable,
        label: 'Unstable',
        description: 'Short-term pressure is high. Survival choices matter now.',
      );
    }

    if (businessReady) {
      return const RunStateEvaluation(
        tier: RunStateTier.businessReady,
        label: 'Business Ready',
        description: 'You have enough stability to consider a first company.',
      );
    }

    if (hasIncome && cash >= obligations * 2 && debt <= obligations) {
      return const RunStateEvaluation(
        tier: RunStateTier.stable,
        label: 'Stable',
        description: 'Your monthly life has a workable cushion.',
      );
    }

    return const RunStateEvaluation(
      tier: RunStateTier.recovering,
      label: 'Recovering',
      description: 'You are building toward a steadier rhythm.',
    );
  }

  List<String> guidanceFor(GameState state) {
    final suggestions = <String>[];
    final cash = state.player.cash;
    final debt = _totalDebt(state);
    final finance = const FinanceEvaluator().evaluate(state);
    final obligations = state.player.monthlyBaseExpense +
        state.currentHousing.monthlyCost +
        _monthlyDebtPayment(state);
    final education = state.activeEducation;
    final company = state.activeCompany;

    if (state.pendingEvent != null) {
      suggestions.add('Resolve the pending event before planning the month.');
    }
    if (_hasCondition(state, 'burnout_risk')) {
      suggestions.add('Burnout risk is active. Rest and reduce stress soon.');
    }
    if (_hasCondition(state, 'money_anxiety')) {
      suggestions.add('Money anxiety is active. Build cash cushion before upgrades.');
    }
    if (state.player.stats.health < 45 || state.player.stats.stress >= 76) {
      suggestions.add('Wellbeing is under pressure. Recovery actions may be the best move.');
    }
    if (cash < obligations) {
      suggestions.add('Your cash cushion is weak. Prioritize reliable income.');
    }
    if (state.currentJob == null && company == null) {
      suggestions.add('Search for starter jobs to stop the early cash bleed.');
    }
    if (debt > 0 && _monthlyDebtPayment(state) >= 45) {
      suggestions.add('Debt payments are heavy. Avoid new fixed costs for now.');
    }
    if (finance.tier == FinanceStateTier.fragile) {
      suggestions.add('Finances are fragile. Keep cash liquid and pay emergency debt first.');
    }
    if (education != null && !education.studyRequirementMet) {
      suggestions.add('Study this month or the education program will not progress.');
    }
    if (state.currentJob != null &&
        education == null &&
        state.completedEducations.isEmpty &&
        cash >= 170) {
      suggestions.add('A short education program can improve future job options.');
    }
    if (state.currentJob != null &&
        state.currentJob!.isCareer &&
        state.workHistory.currentJobTenure >= 4 &&
        state.jobPerformanceScore >= 64) {
      suggestions.add('Your career footing is improving. Search for next-level roles.');
    }
    if (state.currentHousing.id == 'shared_room' &&
        state.currentJob != null &&
        cash >= 190) {
      suggestions.add('Moving to a modest private place can reduce life pressure.');
    }
    if (evaluateRunState(state).tier == RunStateTier.businessReady) {
      suggestions.add('You are close to a company attempt. Keep cash liquid.');
    }
    if (company != null &&
        (finance.tier == FinanceStateTier.fragile ||
            finance.tier == FinanceStateTier.pressured)) {
      suggestions.add('Company ownership is risky with weak personal finances.');
    }
    if (company != null && (company.health < 50 || company.momentum < 45)) {
      suggestions.add('Your company is fragile. Spend energy on business actions.');
    }
    if (company != null && company.pipeline < 35) {
      suggestions.add('Company pipeline is thin. Find Clients can protect future revenue.');
    }
    if (company != null && company.operations < 35) {
      suggestions.add('Company operations are strained. Improve Operations can prevent drag.');
    }
    if (suggestions.isEmpty) {
      suggestions.add('Build a cash buffer, keep stress controlled, and choose one growth path.');
    }

    return suggestions.take(3).toList();
  }

  List<PressureSignal> pressureSignalsFor(GameState state) {
    final signals = <PressureSignal>[];
    final debt = _totalDebt(state);
    final monthlyDebt = _monthlyDebtPayment(state);
    final education = state.activeEducation;
    final company = state.activeCompany;

    if (state.player.cash < 75) {
      signals.add(const PressureSignal(
        label: 'Low cash',
        detail: 'Less than one lean month of cushion.',
        level: PressureLevel.danger,
      ));
    }
    if (state.player.stats.stress >= 75) {
      signals.add(const PressureSignal(
        label: 'High stress',
        detail: 'Stress is starting to threaten consistency.',
        level: PressureLevel.warning,
      ));
    }
    if (state.player.stats.health < 42) {
      signals.add(const PressureSignal(
        label: 'Low health',
        detail: 'Weak health now hurts recovery and consistency.',
        level: PressureLevel.danger,
      ));
    }
    if (state.player.stats.happiness < 38) {
      signals.add(const PressureSignal(
        label: 'Low happiness',
        detail: 'Low mood reduces resilience over time.',
        level: PressureLevel.warning,
      ));
    }
    if (debt > 0) {
      signals.add(PressureSignal(
        label: 'Debt pressure',
        detail: '$debt remaining, $monthlyDebt due monthly.',
        level: monthlyDebt >= 45 ? PressureLevel.danger : PressureLevel.warning,
      ));
    }
    final finance = const FinanceEvaluator().evaluate(state);
    if (finance.tier == FinanceStateTier.fragile) {
      signals.add(const PressureSignal(
        label: 'Fragile finances',
        detail: 'Cash cushion, debt, or emergency debt need attention.',
        level: PressureLevel.danger,
      ));
    }
    if (education != null && !education.studyRequirementMet) {
      signals.add(PressureSignal(
        label: 'Study gap',
        detail:
            '${education.studyProgressThisMonth}/${education.program.monthlyStudyRequired} study done.',
        level: PressureLevel.warning,
      ));
    }
    if (company != null &&
        (company.health < 45 || company.pipeline < 28 || company.operations < 28)) {
      signals.add(const PressureSignal(
        label: 'Fragile company',
        detail: 'Weak health, pipeline, or operations can pull down results.',
        level: PressureLevel.danger,
      ));
    }
    if (_hasCondition(state, 'burnout_risk')) {
      signals.add(const PressureSignal(
        label: 'Burnout risk',
        detail: 'Temporary condition is weakening recovery and performance.',
        level: PressureLevel.danger,
      ));
    }
    if (_hasCondition(state, 'money_anxiety')) {
      signals.add(const PressureSignal(
        label: 'Money anxiety',
        detail: 'Debt pressure is carrying into mood and stress.',
        level: PressureLevel.warning,
      ));
    }

    return signals;
  }

  bool _hasCondition(GameState state, String id) {
    return state.activeConditions.any((condition) => condition.id == id);
  }

  int _totalDebt(GameState state) {
    return state.activeDebts.fold<int>(
      0,
      (total, debt) => total + debt.remainingBalance,
    );
  }

  int _monthlyDebtPayment(GameState state) {
    return state.activeDebts.fold<int>(
      0,
      (total, debt) => total + debt.monthlyPayment,
    );
  }

  bool _sameIds(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index += 1) {
      if (left[index] != right[index]) return false;
    }
    return true;
  }
}

final _definitions = <MilestoneDefinition>[
  MilestoneDefinition(
    id: 'first_job',
    title: 'Get Hired',
    description: 'Land your first main job.',
    stage: MilestoneStage.early,
    isComplete: (state) => state.currentJob != null,
  ),
  MilestoneDefinition(
    id: 'survive_six_months',
    title: 'Six Months Standing',
    description: 'Reach Month 7.',
    stage: MilestoneStage.early,
    isComplete: (state) => state.month >= 7,
  ),
  MilestoneDefinition(
    id: 'first_education',
    title: 'First Credential',
    description: 'Complete any education program.',
    stage: MilestoneStage.stable,
    isComplete: (state) => state.completedEducations.isNotEmpty,
  ),
  MilestoneDefinition(
    id: 'leave_shared_room',
    title: 'Move Up',
    description: 'Move out of the Shared Room.',
    stage: MilestoneStage.stable,
    isComplete: (state) => state.currentHousing.id != 'shared_room',
  ),
  MilestoneDefinition(
    id: 'cash_cushion',
    title: 'Cash Cushion',
    description: 'Hold at least 350 cash.',
    stage: MilestoneStage.stable,
    isComplete: (state) => state.player.cash >= 350,
  ),
  MilestoneDefinition(
    id: 'debt_free',
    title: 'Clean Balance',
    description: 'Have no active debt after the opening months.',
    stage: MilestoneStage.stable,
    isComplete: (state) => state.month >= 4 && state.activeDebts.isEmpty,
  ),
  MilestoneDefinition(
    id: 'reliable_operator',
    title: 'Reliable Operator',
    description: 'Reach Good reliability.',
    stage: MilestoneStage.growth,
    isComplete: (state) => state.player.reliabilityScore >= 65,
  ),
  MilestoneDefinition(
    id: 'job_and_education',
    title: 'Skilled Worker',
    description: 'Hold a job and finish one education program.',
    stage: MilestoneStage.growth,
    isComplete: (state) =>
        state.currentJob != null && state.completedEducations.isNotEmpty,
  ),
  MilestoneDefinition(
    id: 'career_level_two',
    title: 'Career Step Up',
    description: 'Reach a level 2 career role.',
    stage: MilestoneStage.growth,
    isComplete: (state) => (state.currentJob?.level ?? 0) >= 2,
  ),
  MilestoneDefinition(
    id: 'low_stress_stability',
    title: 'Controlled Pace',
    description: 'Keep stress below 45 while employed.',
    stage: MilestoneStage.growth,
    isComplete: (state) =>
        state.currentJob != null && state.player.stats.stress < 45,
  ),
  MilestoneDefinition(
    id: 'start_company',
    title: 'First Company',
    description: 'Found your first company.',
    stage: MilestoneStage.business,
    isComplete: (state) => state.activeCompany != null,
  ),
  MilestoneDefinition(
    id: 'company_three_months',
    title: 'Still In Business',
    description: 'Keep a company active for three months.',
    stage: MilestoneStage.business,
    isComplete: (state) => (state.activeCompany?.monthsActive ?? 0) >= 3,
  ),
  MilestoneDefinition(
    id: 'healthy_company',
    title: 'Viable Business',
    description: 'Reach 65 health and 55 momentum in your company.',
    stage: MilestoneStage.business,
    isComplete: (state) {
      final company = state.activeCompany;
      return company != null && company.health >= 65 && company.momentum >= 55;
    },
  ),
];
