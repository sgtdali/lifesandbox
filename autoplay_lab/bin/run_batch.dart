import 'dart:convert';
import 'dart:io';

import 'package:ambition_flutter/game/models/action_type.dart';

import '../lib/simulation_runner.dart';
import '../lib/bots/survival_bot.dart';
import '../lib/bots/growth_bot.dart';
import '../lib/bots/company_rush_bot.dart';
import '../lib/bots/debt_bot.dart';
import '../lib/bots/balanced_ambition_bot.dart';
import '../lib/bots/pressure_bot.dart';

void main(List<String> args) {
  print('Starting Autoplay Lab Simulation...');

  // Default parameters
  int runs = 1;
  int months = 24;
  String botType = 'mixed'; // 'survival', 'growth', 'company', 'debt', 'balanced', 'mixed'
  int? baseSeed;

  // Simple CLI parsing
  for (final arg in args) {
    if (arg.startsWith('--runs=')) {
      runs = int.parse(arg.split('=')[1]);
    } else if (arg.startsWith('--months=')) {
      months = int.parse(arg.split('=')[1]);
    } else if (arg.startsWith('--bot=')) {
      botType = arg.split('=')[1];
    } else if (arg.startsWith('--seed=')) {
      baseSeed = int.parse(arg.split('=')[1]);
    }
  }

  print('Config: runs=$runs, months=$months, bot=$botType, baseSeed=${baseSeed ?? "random"}\n');

  final summaries = <Map<String, dynamic>>[];

  for (int i = 0; i < runs; i++) {
    final bot = _selectBot(botType, i);
    final runSeed = baseSeed != null ? baseSeed + i : DateTime.now().millisecondsSinceEpoch + i;
    
    print('Run ${i + 1}/$runs using ${bot.name} (Seed: $runSeed)...');
    
    final runner = SimulationRunner(bot: bot, seed: runSeed);
    runner.runMonths(months);
    
    final filename = 'single_run_${bot.name.toLowerCase()}_${runSeed}_${DateTime.now().millisecondsSinceEpoch}.json';
    runner.saveReport(filename);
    
    summaries.add(runner.generateReport());
  }

  if (runs > 1) {
    _writeBatchSummary(summaries, runs, months, botType);
  }

  print('\nSimulation Complete! Outputs written to autoplay_lab/output/');
}

dynamic _selectBot(String type, int index) {
  if (type == 'survival') return const SurvivalBot();
  if (type == 'growth') return const GrowthBot();
  if (type == 'company') return const CompanyRushBot();
  if (type == 'debt') return const DebtBot();
  if (type == 'balanced') return const BalancedAmbitionBot();
  
  // Mixed
  int mod = index % 6;
  if (mod == 0) return const SurvivalBot();
  if (mod == 1) return const GrowthBot();
  if (mod == 2) return const CompanyRushBot();
  if (mod == 3) return const DebtBot();
  if (mod == 4) return const BalancedAmbitionBot();
  return const PressureBot();
}

void _writeBatchSummary(List<Map<String, dynamic>> summaries, int runs, int months, String botType) {
  final Map<String, List<Map<String, dynamic>>> byBot = {};
  
  for (final s in summaries) {
    final bt = s['bot_type'] as String;
    byBot.putIfAbsent(bt, () => []).add(s);
  }

  Map<String, dynamic> computeMetrics(List<Map<String, dynamic>> list) {
    int totalCash = 0;
    int jobsGot = 0;
    int companiesFounded = 0;
    int totalDebt = 0;
    int emergencyDebtRuns = 0;
    int formalLoanRuns = 0;
    int depositRuns = 0;
    int housingMoveRuns = 0;
    int totalMilestones = 0;
    int totalEvents = 0;
    int runsResolvingEvents = 0;
    
    int totalLoanCount = 0;
    int totalDepositCount = 0;
    int totalPaydownCount = 0;
    int totalMonthsUnderPressure = 0;
    
    List<int> jobMonths = [];
    List<int> eduStartMonths = [];
    List<int> eduCompleteMonths = [];
    List<int> companyMonths = [];
    List<int> emergencyDebtMonths = [];
    List<int> firstHousingMoveMonths = [];
    List<int> firstFormalLoanMonths = [];
    
    for (final s in list) {
      totalCash += (s['final_state']['cash'] as int);
      totalDebt += (s['total_debt'] as int? ?? 0);
      totalMilestones += (s['milestones_completed'] as int? ?? 0);
      
      final diag = s['diagnostics'] as Map<String, dynamic>;
      final cov = s['coverage'] as Map<String, dynamic>;
      
      if (s['job_state'] != 'Unemployed') jobsGot++;
      if (s['company_state'] != null) companiesFounded++;
      if (cov['used_emergency_debt'] == true) emergencyDebtRuns++;
      if (cov['used_finance_loans'] == true) formalLoanRuns++;
      if (cov['used_deposits'] == true) depositRuns++;
      if (cov['used_housing'] == true) housingMoveRuns++;
      if (cov['resolved_events'] == true) runsResolvingEvents++;
      
      totalEvents += (diag['total_events_resolved'] as int? ?? 0);
      totalLoanCount += (diag['loan_count_taken'] as int? ?? 0);
      totalDepositCount += (diag['deposits_opened_count'] as int? ?? 0);
      totalPaydownCount += (diag['paydown_count'] as int? ?? 0);
      totalMonthsUnderPressure += (diag['months_under_finance_pressure'] as int? ?? 0);
      
      if (diag['first_job_month'] != null) jobMonths.add(diag['first_job_month'] as int);
      if (diag['first_edu_start_month'] != null) eduStartMonths.add(diag['first_edu_start_month'] as int);
      if (diag['first_edu_complete_month'] != null) eduCompleteMonths.add(diag['first_edu_complete_month'] as int);
      if (diag['first_company_month'] != null) companyMonths.add(diag['first_company_month'] as int);
      if (diag['first_emergency_debt_month'] != null) emergencyDebtMonths.add(diag['first_emergency_debt_month'] as int);
      if (diag['first_housing_move_month'] != null) firstHousingMoveMonths.add(diag['first_housing_move_month'] as int);
      if (diag['first_formal_loan_month'] != null) firstFormalLoanMonths.add(diag['first_formal_loan_month'] as int);
    }

    double avg(List<int> col) => col.isEmpty ? 0.0 : col.reduce((a, b) => a + b) / col.length;
    final int count = list.length;

    return {
      'runs': count,
      'average_ending_cash': (totalCash / count).round(),
      'average_total_debt': (totalDebt / count).round(),
      'average_milestones_completed': (totalMilestones / count).toStringAsFixed(1),
      'average_events_resolved': (totalEvents / count).toStringAsFixed(1),
      'average_loan_count': (totalLoanCount / count).toStringAsFixed(1),
      'average_deposit_count': (totalDepositCount / count).toStringAsFixed(1),
      'average_paydown_count': (totalPaydownCount / count).toStringAsFixed(1),
      'average_months_finance_pressure': (totalMonthsUnderPressure / count).toStringAsFixed(1),
      'percent_resolving_events': '${((runsResolvingEvents / count) * 100).toStringAsFixed(1)}%',
      'percent_with_job': '${((jobsGot / count) * 100).toStringAsFixed(1)}%',
      'percent_with_company': '${((companiesFounded / count) * 100).toStringAsFixed(1)}%',
      'percent_with_emergency_debt': '${((emergencyDebtRuns / count) * 100).toStringAsFixed(1)}%',
      'percent_with_formal_loan': '${((formalLoanRuns / count) * 100).toStringAsFixed(1)}%',
      'percent_with_deposits': '${((depositRuns / count) * 100).toStringAsFixed(1)}%',
      'percent_with_housing_move': '${((housingMoveRuns / count) * 100).toStringAsFixed(1)}%',
      'average_first_job_month': avg(jobMonths).toStringAsFixed(1),
      'average_first_edu_start_month': avg(eduStartMonths).toStringAsFixed(1),
      'average_first_edu_complete_month': avg(eduCompleteMonths).toStringAsFixed(1),
      'average_first_company_month': avg(companyMonths).toStringAsFixed(1),
      'average_first_emergency_debt_month': avg(emergencyDebtMonths).toStringAsFixed(1),
      'average_first_housing_move_month': avg(firstHousingMoveMonths).toStringAsFixed(1),
      'average_first_formal_loan_month': avg(firstFormalLoanMonths).toStringAsFixed(1),
    };
  }

  final overallMetrics = computeMetrics(summaries);
  final perBotMetrics = <String, dynamic>{};
  
  for (final entry in byBot.entries) {
    perBotMetrics[entry.key] = computeMetrics(entry.value);
  }

  final batchReport = {
    'runs': runs,
    'months_simulated_per_run': months,
    'bot_configuration': botType,
    'overall': overallMetrics,
    'per_bot': perBotMetrics,
  };

  final file = File('autoplay_lab/output/batch_summary_${botType}_${DateTime.now().millisecondsSinceEpoch}.json');
  if (!file.parent.existsSync()) {
    file.parent.createSync(recursive: true);
  }
  file.writeAsStringSync(jsonEncode(batchReport));
  
  print('Batch summary written.');
}
