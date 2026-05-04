import '../../features/company/models/active_company.dart';
import '../../features/company/services/company_service.dart';
import '../../features/conditions/models/ongoing_condition.dart';
import '../../features/conditions/services/condition_service.dart';
import '../../features/education/models/active_education.dart';
import '../../features/education/models/completed_education.dart';
import '../../features/finance/models/active_debt.dart';
import '../../features/finance/models/active_deposit.dart';
import '../../features/finance/services/finance_service.dart';
import '../../features/jobs/services/job_career_service.dart';
import '../../features/wellbeing/services/wellbeing_service.dart';
import '../models/game_state.dart';
import '../models/month_result.dart';
import '../models/player_state.dart';
import '../models/stat_change.dart';

class MonthResolver {
  const MonthResolver({
    required List<ResolutionStep> steps,
  }) : _steps = steps;

  final List<ResolutionStep> _steps;

  factory MonthResolver.foundation() {
    return const MonthResolver(
      steps: [
        JobIncomeStep(),
        EducationProgressStep(),
        BaseLivingExpenseStep(),
        HousingStep(),
        JobEnergyLoadStep(),
        CompanyStep(),
        FinanceStep(),
      ],
    );
  }

  MonthResolution resolve(GameState state) {
    var context = ResolutionContext(
      month: state.month,
      player: state.player,
      cashBefore: state.player.cash,
      state: state,
      activeEducation: state.activeEducation,
      completedEducations: state.completedEducations,
      activeDebts: state.activeDebts,
      activeDeposits: state.activeDeposits,
      activeCompany: state.activeCompany,
      activeConditions: state.activeConditions,
    );

    for (final step in _steps) {
      context = step.apply(context);
    }

    final wellbeingResult = const WellbeingService().resolveMonth(
      state.copyWith(
        player: context.player,
        activeCompany: context.activeCompany,
        clearActiveCompany: context.activeCompany == null,
        activeDebts: context.activeDebts,
        activeDeposits: context.activeDeposits,
        activeConditions: context.activeConditions,
      ),
    );
    context = context.copyWith(
      player: wellbeingResult.player,
      housingEnergyModifier:
          context.housingEnergyModifier + wellbeingResult.energyRecoveryModifier,
      wellbeingLabel: wellbeingResult.evaluation.label,
      wellbeingEnergyModifier: wellbeingResult.energyRecoveryModifier,
      statChanges: [...context.statChanges, ...wellbeingResult.statChanges],
      messages: [...context.messages, ...wellbeingResult.messages],
    );

    final conditionResult = const ConditionService().resolveMonth(
      state.copyWith(
        player: context.player,
        activeCompany: context.activeCompany,
        clearActiveCompany: context.activeCompany == null,
        activeDebts: context.activeDebts,
        activeDeposits: context.activeDeposits,
        activeConditions: context.activeConditions,
      ),
    );
    context = context.copyWith(
      player: conditionResult.player,
      activeCompany: conditionResult.activeCompany,
      clearActiveCompany: conditionResult.activeCompany == null,
      activeConditions: conditionResult.activeConditions,
      housingEnergyModifier:
          context.housingEnergyModifier + conditionResult.energyRecoveryModifier,
      statChanges: [...context.statChanges, ...conditionResult.statChanges],
      gainedConditions: conditionResult.gainedConditionTitles,
      expiredConditions: conditionResult.expiredConditionTitles,
      messages: [...context.messages, ...conditionResult.messages],
    );

    final careerResult = const JobCareerService().resolveMonth(
      state.copyWith(
        player: context.player,
        activeDebts: context.activeDebts,
        activeDeposits: context.activeDeposits,
        activeCompany: context.activeCompany,
        clearActiveCompany: context.activeCompany == null,
        activeConditions: context.activeConditions,
      ),
    );
    context = context.copyWith(
      messages: [...context.messages, ...careerResult.messages],
    );

    final result = MonthResult(
      previousMonth: state.month,
      cashBefore: context.cashBefore,
      cashAfter: context.player.cash,
      baseExpense: context.baseExpense,
      housingCostPaid: context.housingCostPaid,
      housingEnergyModifier: context.housingEnergyModifier,
      salaryEarned: context.salaryEarned,
      jobEnergyLoad: context.jobEnergyLoad,
      educationCostPaid: context.educationCostPaid,
      educationStudyRequired: context.educationStudyRequired,
      educationStudyApplied: context.educationStudyApplied,
      educationProgressAdvanced: context.educationProgressAdvanced,
      debtPaid: context.debtPaid,
      emergencyDebtCreated: context.emergencyDebtCreated,
      emergencyDebtPaid: context.emergencyDebtPaid,
      depositInterestEarned: context.depositInterestEarned,
      maturedDepositPayout: context.maturedDepositPayout,
      companyRevenue: context.companyRevenue,
      companyOperatingCost: context.companyOperatingCost,
      companyNet: context.companyNet,
      companyHealthDelta: context.companyHealthDelta,
      companyMomentumDelta: context.companyMomentumDelta,
      companyPipelineDelta: context.companyPipelineDelta,
      companyOperationsDelta: context.companyOperationsDelta,
      conditionEnergyModifier: conditionResult.energyRecoveryModifier,
      gainedConditions: context.gainedConditions,
      expiredConditions: context.expiredConditions,
      wellbeingLabel: context.wellbeingLabel,
      wellbeingEnergyModifier: context.wellbeingEnergyModifier,
      companyName: context.companyName,
      completedEducationTitle: context.completedEducationTitle,
      housingTitle: context.housingTitle,
      cashChange: context.player.cash - context.cashBefore,
      statChanges: context.statChanges,
      messages: context.messages,
    );

    final nextStats = context.player.stats
        .resetEnergy()
        .apply(
          energy: context.housingEnergyModifier - context.jobEnergyLoad,
        );
    final nextPlayer = context.player.copyWith(
      stats: nextStats,
      occupation:
          careerResult.currentJob == null ? 'Unemployed' : careerResult.currentJob!.title,
    );

    return MonthResolution(
      state: state.copyWith(
        month: state.month + 1,
        player: nextPlayer,
        activeEducation: context.activeEducation,
        completedEducations: context.completedEducations,
        activeDebts: context.activeDebts,
        activeDeposits: context.activeDeposits,
        activeCompany: context.activeCompany,
        activeConditions: context.activeConditions,
        currentJob: careerResult.currentJob,
        workHistory: careerResult.workHistory,
        jobPerformanceScore: careerResult.performanceScore,
        clearActiveEducation: context.activeEducation == null,
        clearActiveCompany: context.activeCompany == null,
        clearCurrentJob: careerResult.currentJob == null,
        lastMonthResult: result,
      ),
      result: result,
    );
  }
}

class MonthResolution {
  const MonthResolution({
    required this.state,
    required this.result,
  });

  final GameState state;
  final MonthResult result;
}

class ResolutionContext {
  const ResolutionContext({
    required this.month,
    required this.player,
    required this.cashBefore,
    this.state,
    this.activeEducation,
    this.completedEducations = const [],
    this.activeDebts = const [],
    this.activeDeposits = const [],
    this.activeCompany,
    this.activeConditions = const [],
    this.baseExpense = 0,
    this.housingCostPaid = 0,
    this.housingEnergyModifier = 0,
    this.housingTitle,
    this.salaryEarned = 0,
    this.jobEnergyLoad = 0,
    this.educationCostPaid = 0,
    this.educationStudyRequired = 0,
    this.educationStudyApplied = 0,
    this.educationProgressAdvanced = false,
    this.debtPaid = 0,
    this.emergencyDebtCreated = 0,
    this.emergencyDebtPaid = 0,
    this.depositInterestEarned = 0,
    this.maturedDepositPayout = 0,
    this.companyRevenue = 0,
    this.companyOperatingCost = 0,
    this.companyNet = 0,
    this.companyHealthDelta = 0,
    this.companyMomentumDelta = 0,
    this.companyPipelineDelta = 0,
    this.companyOperationsDelta = 0,
    this.gainedConditions = const [],
    this.expiredConditions = const [],
    this.wellbeingLabel = 'Stable',
    this.wellbeingEnergyModifier = 0,
    this.companyName,
    this.completedEducationTitle,
    this.statChanges = const [],
    this.messages = const [],
  });

  final int month;
  final PlayerState player;
  final GameState? state;
  final ActiveEducation? activeEducation;
  final List<CompletedEducation> completedEducations;
  final List<ActiveDebt> activeDebts;
  final List<ActiveDeposit> activeDeposits;
  final ActiveCompany? activeCompany;
  final List<OngoingCondition> activeConditions;
  final int cashBefore;
  final int baseExpense;
  final int housingCostPaid;
  final int housingEnergyModifier;
  final String? housingTitle;
  final int salaryEarned;
  final int jobEnergyLoad;
  final int educationCostPaid;
  final int educationStudyRequired;
  final int educationStudyApplied;
  final bool educationProgressAdvanced;
  final int debtPaid;
  final int emergencyDebtCreated;
  final int emergencyDebtPaid;
  final int depositInterestEarned;
  final int maturedDepositPayout;
  final int companyRevenue;
  final int companyOperatingCost;
  final int companyNet;
  final int companyHealthDelta;
  final int companyMomentumDelta;
  final int companyPipelineDelta;
  final int companyOperationsDelta;
  final List<String> gainedConditions;
  final List<String> expiredConditions;
  final String wellbeingLabel;
  final int wellbeingEnergyModifier;
  final String? companyName;
  final String? completedEducationTitle;
  final List<StatChange> statChanges;
  final List<String> messages;

  ResolutionContext copyWith({
    PlayerState? player,
    ActiveEducation? activeEducation,
    List<CompletedEducation>? completedEducations,
    List<ActiveDebt>? activeDebts,
    List<ActiveDeposit>? activeDeposits,
    ActiveCompany? activeCompany,
    List<OngoingCondition>? activeConditions,
    int? baseExpense,
    int? housingCostPaid,
    int? housingEnergyModifier,
    String? housingTitle,
    int? salaryEarned,
    int? jobEnergyLoad,
    int? educationCostPaid,
    int? educationStudyRequired,
    int? educationStudyApplied,
    bool? educationProgressAdvanced,
    int? debtPaid,
    int? emergencyDebtCreated,
    int? emergencyDebtPaid,
    int? depositInterestEarned,
    int? maturedDepositPayout,
    int? companyRevenue,
    int? companyOperatingCost,
    int? companyNet,
    int? companyHealthDelta,
    int? companyMomentumDelta,
    int? companyPipelineDelta,
    int? companyOperationsDelta,
    List<String>? gainedConditions,
    List<String>? expiredConditions,
    String? wellbeingLabel,
    int? wellbeingEnergyModifier,
    String? companyName,
    String? completedEducationTitle,
    bool clearActiveEducation = false,
    bool clearActiveCompany = false,
    List<StatChange>? statChanges,
    List<String>? messages,
  }) {
    return ResolutionContext(
      month: month,
      player: player ?? this.player,
      state: state,
      activeEducation: clearActiveEducation
          ? null
          : activeEducation ?? this.activeEducation,
      completedEducations: completedEducations ?? this.completedEducations,
      activeDebts: activeDebts ?? this.activeDebts,
      activeDeposits: activeDeposits ?? this.activeDeposits,
      activeCompany:
          clearActiveCompany ? null : activeCompany ?? this.activeCompany,
      activeConditions: activeConditions ?? this.activeConditions,
      cashBefore: cashBefore,
      baseExpense: baseExpense ?? this.baseExpense,
      housingCostPaid: housingCostPaid ?? this.housingCostPaid,
      housingEnergyModifier:
          housingEnergyModifier ?? this.housingEnergyModifier,
      housingTitle: housingTitle ?? this.housingTitle,
      salaryEarned: salaryEarned ?? this.salaryEarned,
      jobEnergyLoad: jobEnergyLoad ?? this.jobEnergyLoad,
      educationCostPaid: educationCostPaid ?? this.educationCostPaid,
      educationStudyRequired:
          educationStudyRequired ?? this.educationStudyRequired,
      educationStudyApplied: educationStudyApplied ?? this.educationStudyApplied,
      educationProgressAdvanced:
          educationProgressAdvanced ?? this.educationProgressAdvanced,
      debtPaid: debtPaid ?? this.debtPaid,
      emergencyDebtCreated:
          emergencyDebtCreated ?? this.emergencyDebtCreated,
      emergencyDebtPaid: emergencyDebtPaid ?? this.emergencyDebtPaid,
      depositInterestEarned:
          depositInterestEarned ?? this.depositInterestEarned,
      maturedDepositPayout: maturedDepositPayout ?? this.maturedDepositPayout,
      companyRevenue: companyRevenue ?? this.companyRevenue,
      companyOperatingCost: companyOperatingCost ?? this.companyOperatingCost,
      companyNet: companyNet ?? this.companyNet,
      companyHealthDelta: companyHealthDelta ?? this.companyHealthDelta,
      companyMomentumDelta: companyMomentumDelta ?? this.companyMomentumDelta,
      companyPipelineDelta:
          companyPipelineDelta ?? this.companyPipelineDelta,
      companyOperationsDelta:
          companyOperationsDelta ?? this.companyOperationsDelta,
      gainedConditions: gainedConditions ?? this.gainedConditions,
      expiredConditions: expiredConditions ?? this.expiredConditions,
      wellbeingLabel: wellbeingLabel ?? this.wellbeingLabel,
      wellbeingEnergyModifier:
          wellbeingEnergyModifier ?? this.wellbeingEnergyModifier,
      companyName: companyName ?? this.companyName,
      completedEducationTitle:
          completedEducationTitle ?? this.completedEducationTitle,
      statChanges: statChanges ?? this.statChanges,
      messages: messages ?? this.messages,
    );
  }
}

class EducationProgressStep extends ResolutionStep {
  const EducationProgressStep();

  @override
  ResolutionContext apply(ResolutionContext context) {
    final active = context.activeEducation;
    if (active == null) return context;

    final program = active.program;
    final canPay = context.player.cash >= program.monthlyCost;
    final studyMet = active.studyRequirementMet;

    if (!canPay) {
      return context.copyWith(
        activeEducation: active.copyWith(studyProgressThisMonth: 0),
        educationStudyRequired: program.monthlyStudyRequired,
        educationStudyApplied: active.studyProgressThisMonth,
        messages: [
          ...context.messages,
          '${program.title} paused because the monthly cost could not be paid.',
        ],
      );
    }

    final paidPlayer = context.player.copyWith(
      cash: context.player.cash - program.monthlyCost,
    );

    if (!studyMet) {
      return context.copyWith(
        player: paidPlayer,
        activeEducation: active.copyWith(studyProgressThisMonth: 0),
        educationCostPaid: context.educationCostPaid + program.monthlyCost,
        educationStudyRequired: program.monthlyStudyRequired,
        educationStudyApplied: active.studyProgressThisMonth,
        messages: [
          ...context.messages,
          '${program.title} study target was not met. Progress did not advance.',
        ],
      );
    }

    final nextCompletedMonths = active.completedMonths + 1;
    final completed = nextCompletedMonths >= program.durationMonths;
    final rewardStats = paidPlayer.stats.apply(
      intelligence: completed ? program.intelligenceReward : 0,
      happiness: completed ? program.happinessReward : 0,
    );
    final rewardedPlayer = paidPlayer.copyWith(
      stats: rewardStats,
      reliabilityScore: completed
          ? (paidPlayer.reliabilityScore + program.reliabilityReward)
              .clamp(0, 100)
              .toInt()
          : paidPlayer.reliabilityScore,
    );

    if (completed) {
      final record = CompletedEducation(
        programId: program.id,
        title: program.title,
        completedOnMonth: context.month,
        tags: program.tags,
      );

      return context.copyWith(
        player: rewardedPlayer,
        clearActiveEducation: true,
        completedEducations: [...context.completedEducations, record],
        educationCostPaid: context.educationCostPaid + program.monthlyCost,
        educationStudyRequired: program.monthlyStudyRequired,
        educationStudyApplied: active.studyProgressThisMonth,
        educationProgressAdvanced: true,
        completedEducationTitle: program.title,
        statChanges: [
          ...context.statChanges,
          if (program.intelligenceReward != 0)
            StatChange(
              label: 'Education intelligence reward',
              amount: program.intelligenceReward,
            ),
          if (program.reliabilityReward != 0)
            StatChange(
              label: 'Education reliability reward',
              amount: program.reliabilityReward,
            ),
          if (program.happinessReward != 0)
            StatChange(
              label: 'Education happiness reward',
              amount: program.happinessReward,
            ),
        ],
        messages: [
          ...context.messages,
          '${program.title} completed.',
        ],
      );
    }

    return context.copyWith(
      player: rewardedPlayer,
      activeEducation: active.copyWith(
        completedMonths: nextCompletedMonths,
        studyProgressThisMonth: 0,
      ),
      educationCostPaid: context.educationCostPaid + program.monthlyCost,
      educationStudyRequired: program.monthlyStudyRequired,
      educationStudyApplied: active.studyProgressThisMonth,
      educationProgressAdvanced: true,
      messages: [
        ...context.messages,
        '${program.title} advanced to $nextCompletedMonths/${program.durationMonths} months.',
      ],
    );
  }
}

abstract class ResolutionStep {
  const ResolutionStep();

  ResolutionContext apply(ResolutionContext context);
}

class BaseLivingExpenseStep extends ResolutionStep {
  const BaseLivingExpenseStep();

  @override
  ResolutionContext apply(ResolutionContext context) {
    final expense = context.player.monthlyBaseExpense;

    return context.copyWith(
      player: context.player.copyWith(cash: context.player.cash - expense),
      baseExpense: context.baseExpense + expense,
      messages: [
        ...context.messages,
        'Base living costs were paid.',
      ],
    );
  }
}

class HousingStep extends ResolutionStep {
  const HousingStep();

  @override
  ResolutionContext apply(ResolutionContext context) {
    final housing = context.state!.currentHousing;
    final updatedStats = context.player.stats.apply(
      happiness: housing.happinessModifier,
      stress: housing.stressModifier,
      health: housing.healthModifier,
    );

    return context.copyWith(
      player: context.player.copyWith(
        cash: context.player.cash - housing.monthlyCost,
        stats: updatedStats,
      ),
      housingCostPaid: context.housingCostPaid + housing.monthlyCost,
      housingEnergyModifier:
          context.housingEnergyModifier + housing.energyRecoveryModifier,
      housingTitle: housing.title,
      statChanges: [
        ...context.statChanges,
        if (housing.happinessModifier != 0)
          StatChange(
            label: 'Housing happiness',
            amount: housing.happinessModifier,
          ),
        if (housing.stressModifier != 0)
          StatChange(
            label: 'Housing stress',
            amount: housing.stressModifier,
          ),
        if (housing.healthModifier != 0)
          StatChange(
            label: 'Housing health',
            amount: housing.healthModifier,
          ),
      ],
      messages: [
        ...context.messages,
        '${housing.title} rent paid: -${housing.monthlyCost}.',
      ],
    );
  }
}

class JobIncomeStep extends ResolutionStep {
  const JobIncomeStep();

  @override
  ResolutionContext apply(ResolutionContext context) {
    final job = context.state?.currentJob;
    if (job == null) return context;

    return context.copyWith(
      player: context.player.copyWith(cash: context.player.cash + job.monthlySalary),
      salaryEarned: context.salaryEarned + job.monthlySalary,
      messages: [
        ...context.messages,
        '${job.title} salary earned: +${job.monthlySalary}.',
      ],
    );
  }
}

class JobEnergyLoadStep extends ResolutionStep {
  const JobEnergyLoadStep();

  @override
  ResolutionContext apply(ResolutionContext context) {
    final job = context.state?.currentJob;
    if (job == null) return context;

    final updatedStats = context.player.stats.apply(
      stress: job.stressImpact,
    );

    return context.copyWith(
      player: context.player.copyWith(stats: updatedStats),
      jobEnergyLoad: context.jobEnergyLoad + job.monthlyEnergyLoad,
      statChanges: [
        ...context.statChanges,
        StatChange(label: 'Energy load from ${job.title}', amount: -job.monthlyEnergyLoad),
        if (job.stressImpact != 0)
          StatChange(label: 'Job stress', amount: job.stressImpact),
      ],
      messages: [
        ...context.messages,
        '${job.title} used ${job.monthlyEnergyLoad} energy this month.',
      ],
    );
  }
}

class FinanceStep extends ResolutionStep {
  const FinanceStep();

  @override
  ResolutionContext apply(ResolutionContext context) {
    final finance = const FinanceService().resolveMonth(
      context.state!.copyWith(
        player: context.player,
        activeDebts: context.activeDebts,
        activeDeposits: context.activeDeposits,
      ),
    );

    return context.copyWith(
      player: context.player.copyWith(cash: finance.cash),
      activeDebts: finance.activeDebts,
      activeDeposits: finance.activeDeposits,
      debtPaid: finance.debtPaid,
      emergencyDebtCreated: finance.emergencyDebtCreated,
      emergencyDebtPaid: finance.emergencyDebtPaid,
      depositInterestEarned: finance.depositInterestEarned,
      maturedDepositPayout: finance.maturedDepositPayout,
      messages: [
        ...context.messages,
        if (finance.debtPaid > 0) 'Debt payments made: -${finance.debtPaid}.',
        if (finance.emergencyDebtCreated > 0)
          'Emergency debt created: ${finance.emergencyDebtCreated}.',
        if (finance.emergencyDebtPaid > 0)
          'Emergency debt paid down: ${finance.emergencyDebtPaid}.',
        if (finance.depositInterestEarned > 0)
          'Deposits gained ${finance.depositInterestEarned}.',
        if (finance.maturedDepositPayout > 0)
          'Term deposit matured: +${finance.maturedDepositPayout}.',
      ],
    );
  }
}

class CompanyStep extends ResolutionStep {
  const CompanyStep();

  @override
  ResolutionContext apply(ResolutionContext context) {
    final result = const CompanyService().resolveMonth(
      context.state!.copyWith(
        player: context.player,
        activeCompany: context.activeCompany,
      ),
    );
    if (result.companyName == null) return context;

    return context.copyWith(
      player: context.player.copyWith(cash: context.player.cash + result.net),
      activeCompany: result.company,
      clearActiveCompany: result.company == null,
      companyRevenue: result.revenue,
      companyOperatingCost: result.operatingCost,
      companyNet: result.net,
      companyHealthDelta: result.healthDelta,
      companyMomentumDelta: result.momentumDelta,
      companyPipelineDelta: result.pipelineDelta,
      companyOperationsDelta: result.operationsDelta,
      companyName: result.companyName,
      statChanges: [
        ...context.statChanges,
        if (result.companyClosed)
          const StatChange(label: 'Company closed', amount: -1),
      ],
      messages: [
        ...context.messages,
        '${result.companyName} revenue: +${result.revenue}.',
        '${result.companyName} operating cost: -${result.operatingCost}.',
        if (result.companyClosed) '${result.companyName} closed after collapsing.',
      ],
    );
  }
}
