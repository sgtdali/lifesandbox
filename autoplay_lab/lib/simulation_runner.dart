import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:ambition_flutter/game/models/game_state.dart';
import 'package:ambition_flutter/game/models/action_type.dart';
import 'package:ambition_flutter/game/services/action_service.dart';
import 'package:ambition_flutter/game/services/month_resolver.dart';
import 'package:ambition_flutter/features/events/services/event_service.dart';
import 'package:ambition_flutter/features/jobs/services/job_listing_service.dart';
import 'package:ambition_flutter/features/jobs/services/application_evaluator.dart';
import 'package:ambition_flutter/features/jobs/models/suitability.dart';
import 'package:ambition_flutter/features/jobs/models/job.dart';
import 'package:ambition_flutter/features/jobs/models/job.dart';
import 'package:ambition_flutter/features/education/services/education_service.dart';
import 'package:ambition_flutter/features/finance/services/finance_service.dart';
import 'package:ambition_flutter/features/finance/models/loan_product.dart';
import 'package:ambition_flutter/features/finance/models/deposit_product.dart';
import 'package:ambition_flutter/features/finance/models/active_deposit.dart';
import 'package:ambition_flutter/features/housing/services/housing_service.dart';
import 'package:ambition_flutter/features/housing/models/housing_option.dart';
import 'package:ambition_flutter/features/company/services/company_service.dart';
import 'package:ambition_flutter/features/company/models/company_type.dart';
import 'package:ambition_flutter/features/company/models/company_action.dart';
import 'package:ambition_flutter/features/wellbeing/services/wellbeing_service.dart';

import 'package:ambition_flutter/features/progression/services/progression_service.dart';

import 'bots/base_bot.dart';

class SimulationRunner {
  GameState state;
  final BaseBot bot;
  final ActionService actionService = const ActionService();
  final MonthResolver monthResolver = MonthResolver.foundation();
  final EventService eventService = const EventService();
  final JobListingService jobListingService = const JobListingService();
  final ApplicationEvaluator applicationEvaluator = const ApplicationEvaluator();
  final EducationService educationService = const EducationService();
  final FinanceService financeService = const FinanceService();
  final HousingService housingService = const HousingService();
  final CompanyService companyService = const CompanyService();
  final WellbeingService wellbeingService = const WellbeingService();
  final ProgressionService progressionService = const ProgressionService();
  
  late final Random random;
  
  final int seed;
  final List<Map<String, dynamic>> monthlyLogs = [];
  
  // Tracking metrics
  int totalEventsResolved = 0;
  Map<ActionType, int> actionCounts = {};
  int? firstJobMonth;
  int? firstEduStartMonth;
  int? firstEduCompleteMonth;
  int? firstDebtMonth;
  int? firstEmergencyDebtMonth;
  int? firstCompanyMonth;
  int peakDebt = 0;
  int lowestCash = 999999;
  int highestStress = 0;
  int lowestHealth = 100;
  
  // New phase 4 diagnostics
  int? firstFormalLoanMonth;
  int loanCountTaken = 0;
  int? firstDepositMonth;
  int depositsOpenedCount = 0;
  int paydownCount = 0;
  int? firstHousingMoveMonth;
  int housingMoveCount = 0;
  int highestMonthlyObligation = 0;
  int lowestLiquidCash = 999999;
  int monthsUnderFinancePressure = 0;
  int monthsInFragileFinanceState = 0;
  int monthsInBurnoutOrStrainedWellbeing = 0;
  
  bool usedFinancePaydown = false;
  bool usedDeposits = false;

  SimulationRunner({required this.bot, required this.seed}) : state = GameState.initial(seed: seed) {
    random = Random(seed);
    _setState(state.copyWith(
      availableJobs: jobListingService.generateListings(
        month: state.month,
        refreshCount: state.jobSearchCount,
        state: state,
      ),
    ));
  }

  void _setState(GameState nextState) {
    state = progressionService.syncMilestones(nextState);
  }

  void runMonths(int months) {
    for (int i = 0; i < months; i++) {
      bot.takeTurn(this);
      
      // Save state before end of month actions
      monthlyLogs.add({
        'month': state.month,
        'cash': state.player.cash,
        'energy': state.player.stats.energy,
        'stress': state.player.stats.stress,
        'health': state.player.stats.health,
        'happiness': state.player.stats.happiness,
        'job': state.currentJob?.title,
        'company': state.activeCompany?.name,
      });

      endMonth();
    }
    
    // Final resolution to ensure any end-of-month events/debt are reflected in final stats
    // We don't increment the month again, just resolve the current state's obligations
    final finalRes = monthResolver.resolve(state);
    _setState(finalRes.state.copyWith(month: state.month)); // Keep month the same
    
    _updateTrackingMetrics();
  }

  void endMonth() {
    final resolution = monthResolver.resolve(state);
    var nextState = resolution.state;
    final eventGen = eventService.generateMonthlyEvent(nextState);
    nextState = eventGen.state;
    
    if (eventGen.pendingEvent != null) {
      nextState = nextState.copyWith(pendingEvent: eventGen.pendingEvent);
      // Let the bot evaluate the event and choose
      final choice = bot.chooseEventAction(this, nextState.pendingEvent!.event);
      nextState = eventService.resolveChoice(state: nextState, choice: choice).state;
      totalEventsResolved++;
    }

    _setState(nextState);
    _updateTrackingMetrics();
  }

  void _updateTrackingMetrics() {
    // Update tracking metrics
    if (state.currentJob != null && firstJobMonth == null) firstJobMonth = state.month;
    if (state.activeEducation != null && firstEduStartMonth == null) firstEduStartMonth = state.month;
    if (state.completedEducations.isNotEmpty && firstEduCompleteMonth == null) firstEduCompleteMonth = state.month;
    if (state.activeCompany != null && firstCompanyMonth == null) firstCompanyMonth = state.month;

    int currentDebt = state.activeDebts.fold(0, (sum, d) => sum + d.remainingBalance);
    if (currentDebt > 0 && firstDebtMonth == null) firstDebtMonth = state.month;
    if (state.activeDebts.any((d) => d.isEmergency) && firstEmergencyDebtMonth == null) firstEmergencyDebtMonth = state.month;

    if (currentDebt > peakDebt) peakDebt = currentDebt;
    if (state.player.cash < lowestCash) lowestCash = state.player.cash;
    if (state.player.stats.stress > highestStress) highestStress = state.player.stats.stress;
    if (state.player.stats.health < lowestHealth) lowestHealth = state.player.stats.health;

    // Additional Phase 4 metrics
    final monthlyObligations = state.player.monthlyBaseExpense + state.currentHousing.monthlyCost + state.activeDebts.fold<int>(0, (sum, d) => sum + d.monthlyPayment);
    if (monthlyObligations > highestMonthlyObligation) highestMonthlyObligation = monthlyObligations;
    
    final liquidCash = state.player.cash; 
    if (liquidCash < lowestLiquidCash) lowestLiquidCash = liquidCash;
    
    final pressureSignals = progressionService.pressureSignalsFor(state);
    if (pressureSignals.any((s) => s.label == 'Debt pressure')) {
      monthsUnderFinancePressure++;
    }
    if (pressureSignals.any((s) => s.label == 'Fragile finances')) {
      monthsInFragileFinanceState++;
    }
    if (state.player.stats.health < 45 || state.player.stats.stress >= 76 || state.activeConditions.any((c) => c.id == 'burnout_risk')) {
      monthsInBurnoutOrStrainedWellbeing++;
    }
  }

  bool canAffordAction(ActionType type) {
    final def = actionService.availableActions.firstWhere((a) => a.type == type);
    return actionService.canAfford(state, def);
  }

  void applyAction(ActionType type) {
    actionCounts[type] = (actionCounts[type] ?? 0) + 1;
    final def = actionService.availableActions.firstWhere((a) => a.type == type);
    _setState(actionService.applyAction(state, def));
  }

  void applyToBestJob() {
    if (state.availableJobs.isEmpty) return;
    
    // Simple heuristic: pick the highest paying job we can apply for
    Job? bestJob;
    int maxSalary = -1;

    for (final job in state.availableJobs) {
      final preview = applicationEvaluator.preview(state: state, job: job);
      if (preview.level.canApply && job.monthlySalary > maxSalary) {
        maxSalary = job.monthlySalary;
        bestJob = job;
      }
    }

    if (bestJob != null && bestJob.id != state.currentJob?.id) {
      applyToJob(bestJob);
    }
  }

  void applyToJob(Job job) {
    final result = applicationEvaluator.evaluate(state: state, job: job);
    if (result.accepted) {
      _setState(state.copyWith(
        currentJob: job,
        player: state.player.copyWith(occupation: job.title),
        workHistory: state.workHistory.clearCurrentJob(),
        availableJobs: state.availableJobs.where((l) => l.id != job.id).toList(),
        lastApplicationResult: result,
        clearLastMonthResult: true,
      ));
    }
  }

  bool canStudy() => state.activeEducation != null && state.player.stats.energy >= EducationService.studyEnergyCost;

  void study() {
    if (canStudy()) {
      _setState(educationService.study(state));
    }
  }

  void foundCompany(CompanyType type) {
    if (companyService.canFound(state, type)) {
      _setState(companyService.foundCompany(state, type));
    }
  }

  bool canDoCompanyAction(CompanyAction action) => state.activeCompany != null && state.player.stats.energy >= action.energyCost;

  void doCompanyAction(CompanyAction action) {
    if (canDoCompanyAction(action)) {
      _setState(companyService.applyAction(state, action));
    }
  }

  void takeLoan(LoanProduct product) {
    if (firstFormalLoanMonth == null) firstFormalLoanMonth = state.month;
    loanCountTaken++;
    _setState(financeService.takeLoan(state, product));
  }

  bool canPayDownDebt(int amount) => state.player.cash >= amount && state.activeDebts.isNotEmpty;

  void payDownDebt(int amount) {
    if (canPayDownDebt(amount)) {
      usedFinancePaydown = true;
      paydownCount++;
      _setState(financeService.payDownDebt(state, amount));
    }
  }

  bool canOpenDeposit(int amount) => state.player.cash >= amount;

  void openDeposit(DepositProduct product, int amount) {
    if (canOpenDeposit(amount)) {
      usedDeposits = true;
      if (firstDepositMonth == null) firstDepositMonth = state.month;
      depositsOpenedCount++;
      _setState(financeService.openDeposit(state: state, product: product, amount: amount));
    }
  }

  void withdrawDeposit(ActiveDeposit deposit) {
    _setState(financeService.withdrawDeposit(state, deposit));
  }

  bool canMoveHousing(HousingOption option) => housingService.canMoveTo(state, option);

  void moveHousing(HousingOption option) {
    if (canMoveHousing(option)) {
      if (firstHousingMoveMonth == null) firstHousingMoveMonth = state.month;
      housingMoveCount++;
      _setState(housingService.moveTo(state, option));
    }
  }

  Map<String, dynamic> generateReport() {
    final endState = state;
    
    final coverage = {
      'used_jobs': firstJobMonth != null,
      'used_education': firstEduStartMonth != null,
      'used_housing': housingMoveCount > 0,
      'used_finance_loans': loanCountTaken > 0,
      'used_emergency_debt': firstEmergencyDebtMonth != null,
      'used_finance_paydown': usedFinancePaydown,
      'used_deposits': usedDeposits,
      'used_company': firstCompanyMonth != null,
      'resolved_events': totalEventsResolved > 0,
      'gained_conditions': endState.activeConditions.isNotEmpty,
      'completed_milestones': endState.completedMilestoneIds.isNotEmpty,
    };
    
    return {
      'bot_type': bot.name,
      'seed': seed,
      'months_simulated': endState.month - 1,
      'final_state': {
        'cash': endState.player.cash,
        'health': endState.player.stats.health,
        'happiness': endState.player.stats.happiness,
        'stress': endState.player.stats.stress,
        'intelligence': endState.player.stats.intelligence,
      },
      'job_state': endState.currentJob?.title ?? 'Unemployed',
      'company_state': endState.activeCompany?.name,
      'debt_state': endState.activeDebts.length,
      'total_debt': endState.activeDebts.fold(0, (sum, d) => sum + d.remainingBalance),
      'education_completed': endState.completedEducations.length,
      'wellbeing_label': wellbeingService.evaluate(endState).label,
      'milestones_completed': endState.completedMilestoneIds.length,
      'completed_milestone_ids': endState.completedMilestoneIds,
      'diagnostics': {
        'first_job_month': firstJobMonth,
        'first_edu_start_month': firstEduStartMonth,
        'first_edu_complete_month': firstEduCompleteMonth,
        'first_debt_month': firstDebtMonth,
        'first_emergency_debt_month': firstEmergencyDebtMonth,
        'first_company_month': firstCompanyMonth,
        'peak_debt': peakDebt,
        'lowest_cash': lowestCash,
        'highest_stress': highestStress,
        'lowest_health': lowestHealth,
        'total_events_resolved': totalEventsResolved,
        'first_formal_loan_month': firstFormalLoanMonth,
        'loan_count_taken': loanCountTaken,
        'first_deposit_month': firstDepositMonth,
        'deposits_opened_count': depositsOpenedCount,
        'paydown_count': paydownCount,
        'first_housing_move_month': firstHousingMoveMonth,
        'housing_move_count': housingMoveCount,
        'highest_monthly_obligation': highestMonthlyObligation,
        'lowest_liquid_cash': lowestLiquidCash,
        'months_under_finance_pressure': monthsUnderFinancePressure,
        'months_in_fragile_finance_state': monthsInFragileFinanceState,
        'months_in_burnout_or_strained_wellbeing': monthsInBurnoutOrStrainedWellbeing,
        'action_counts': actionCounts.map((k, v) => MapEntry(k.toString(), v)),
      },
      'coverage': coverage,
      'monthly_snapshots': monthlyLogs,
    };
  }

  void saveReport(String filename) {
    final outputDir = Directory('autoplay_lab/output');
    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }
    final file = File('autoplay_lab/output/$filename');
    file.writeAsStringSync(jsonEncode(generateReport()));
  }
}
