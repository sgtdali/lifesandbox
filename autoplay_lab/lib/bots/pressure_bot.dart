import 'package:ambition_flutter/game/models/action_type.dart';
import 'package:ambition_flutter/features/events/models/life_event.dart';
import 'package:ambition_flutter/features/events/models/event_choice.dart';
import 'package:ambition_flutter/features/jobs/models/suitability.dart';
import '../simulation_runner.dart';
import 'base_bot.dart';

class PressureBot extends BaseBot {
  const PressureBot();

  @override
  String get name => 'PressureBot';

  @override
  void takeTurn(dynamic r) {
    final runner = r as SimulationRunner;

    // 1. Get a job, but not necessarily the best one
    if (runner.state.currentJob == null && runner.state.availableJobs.isNotEmpty) {
      // Pick a random job instead of the highest paying
      final job = runner.state.availableJobs[runner.random.nextInt(runner.state.availableJobs.length)];
      final preview = runner.applicationEvaluator.preview(state: runner.state, job: job);
      if (preview.level.canApply) {
        runner.applyToJob(job);
      }
    }

    // 2. Overcommit to housing
    // Moves to an expensive place as soon as it has the raw cash, ignoring obligations buffer
    if (runner.state.player.cash > 1000 && runner.state.currentJob != null) {
      if (runner.state.currentHousing.id == 'shared_room') {
        final expensiveHousing = runner.housingService.options.last; // Most expensive
        if (runner.canMoveHousing(expensiveHousing)) {
          runner.moveHousing(expensiveHousing);
        } else {
          final middleHousing = runner.housingService.options.firstWhere((o) => o.id == 'studio_apartment', orElse: () => runner.housingService.options.last);
          if (runner.canMoveHousing(middleHousing)) {
            runner.moveHousing(middleHousing);
          }
        }
      }
    }

    // 3. Overcommit to education
    if (runner.state.activeEducation == null && 
        runner.state.player.cash > 300 && // Too low of a threshold!
        runner.state.currentJob != null &&
        runner.state.completedEducations.isEmpty) {
      if (runner.educationService.programs.isNotEmpty) {
        runner.state = runner.educationService.startProgram(runner.state, runner.educationService.programs.first);
      }
    }

    final totalDebt = runner.state.activeDebts.fold(0, (sum, d) => sum + d.remainingBalance);
    final monthlyDebt = runner.state.activeDebts.fold(0, (sum, d) => sum + d.monthlyPayment);
    final obligations = runner.state.player.monthlyBaseExpense + runner.state.currentHousing.monthlyCost + monthlyDebt;

    // 4. Bad finance choices: takes loans just to afford things, not for survival buffer
    if (runner.state.player.cash < obligations && totalDebt < 2000) {
      if (runner.financeService.loans.length > 1) {
        // Takes a large loan to feel "rich" again instead of a small one
        if (runner.state.activeDebts.length < 3) {
          runner.takeLoan(runner.financeService.loans[1]); // Usually large personal loan
        }
      }
    }

    // 5. Barely recovers from debt
    if (runner.state.activeDebts.any((d) => d.isEmergency) && runner.state.player.cash > obligations + 50) {
      if (runner.canPayDownDebt(50)) {
        runner.payDownDebt(50);
      }
    }

    // 6. Delays recovery until it's very bad
    // Ignores stress until it's over 85 (very risky)
    if (runner.state.player.stats.stress > 85) {
      if (runner.canAffordAction(ActionType.personalReset)) {
        runner.applyAction(ActionType.personalReset);
      } else {
        while (runner.canAffordAction(ActionType.rest)) runner.applyAction(ActionType.rest);
      }
    } else {
      // Pushes hard on education and walking
      if (runner.state.activeEducation != null) {
        while (runner.canStudy()) {
          runner.study();
        }
      }
      
      // Look around or Walk instead of resting properly
      if (runner.canAffordAction(ActionType.lookAround)) {
        runner.applyAction(ActionType.lookAround);
      }
      if (runner.canAffordAction(ActionType.walk)) {
        runner.applyAction(ActionType.walk);
      }
      if (runner.canAffordAction(ActionType.selfStudy)) {
        runner.applyAction(ActionType.selfStudy);
      }
      
      // Minimal rest only if nothing else to do
      if (runner.canAffordAction(ActionType.rest)) {
        runner.applyAction(ActionType.rest);
      }
    }
  }

  @override
  EventChoice chooseEventAction(dynamic r, LifeEvent event) {
    final runner = r as SimulationRunner;
    
    EventChoice bestChoice = event.choices.first;
    int bestScore = -99999;

    for (final choice in event.choices) {
      int score = 0;
      final effect = choice.effect;
      
      // PressureBot makes shortsighted choices
      score += effect.cash ~/ 50; // Values short term cash highly
      score -= effect.stress ~/ 2; // Doesn't care much about stress
      score += effect.happiness; // Values temporary happiness
      
      // Slight random irrationality
      score += runner.random.nextInt(20);
      
      if (score > bestScore) {
        bestScore = score;
        bestChoice = choice;
      }
    }
    
    return bestChoice;
  }
}
