import 'package:ambition_flutter/game/models/action_type.dart';
import 'package:ambition_flutter/features/events/models/life_event.dart';
import 'package:ambition_flutter/features/events/models/event_choice.dart';
import '../simulation_runner.dart';
import 'base_bot.dart';

class BalancedAmbitionBot extends BaseBot {
  const BalancedAmbitionBot();

  @override
  String get name => 'BalancedAmbitionBot';

  @override
  void takeTurn(dynamic r) {
    final runner = r as SimulationRunner;

    // 1. Secure early stability
    runner.applyToBestJob();

    // 2. Start education if stable
    if (runner.state.activeEducation == null && 
        runner.state.player.cash > 250 && 
        runner.state.month > 4 && 
        runner.state.completedEducations.isEmpty) {
      if (runner.educationService.programs.isNotEmpty) {
        runner.state = runner.educationService.startProgram(runner.state, runner.educationService.programs.first);
      }
    }

    // 3. Foundation of Company if highly stable and educated/promoted
    final obligations = runner.state.player.monthlyBaseExpense + runner.state.currentHousing.monthlyCost;
    final totalDebt = runner.state.activeDebts.fold(0, (sum, d) => sum + d.remainingBalance);
    
    if (runner.state.activeCompany == null && 
        runner.state.player.cash >= 600 && 
        totalDebt == 0 && 
        (runner.state.completedEducations.isNotEmpty || runner.state.month > 12)) {
      if (runner.companyService.types.isNotEmpty) {
        final type = runner.companyService.types.first;
        if (runner.companyService.canFound(runner.state, type)) {
          runner.foundCompany(type);
        }
      }
    }

    // 3.5 Housing Upgrades
    // Only upgrade if we have excellent cash buffer, low debt, and good income
    if (runner.state.player.cash > obligations * 3 + 600 && totalDebt == 0 && runner.state.currentJob != null) {
      if (runner.state.currentHousing.id == 'shared_room') {
        final betterHousing = runner.housingService.options.firstWhere((o) => o.id == 'studio_apartment', orElse: () => runner.housingService.options.last);
        if (runner.canMoveHousing(betterHousing)) {
          runner.moveHousing(betterHousing);
        }
      } else if (runner.state.currentHousing.id == 'studio_apartment' && runner.state.player.cash > 4000) {
        final bestHousing = runner.housingService.options.firstWhere((o) => o.id == 'one_bedroom_apartment', orElse: () => runner.housingService.options.last);
        if (runner.canMoveHousing(bestHousing)) {
          runner.moveHousing(bestHousing);
        }
      }
    }

    // 4. Action execution priority
    
    // Safety first: handle extreme stress
    if (runner.state.player.stats.stress > 70) {
      if (runner.canAffordAction(ActionType.personalReset)) {
        runner.applyAction(ActionType.personalReset);
      } else if (runner.canAffordAction(ActionType.socialTime)) {
        runner.applyAction(ActionType.socialTime);
      } else {
        while (runner.canAffordAction(ActionType.rest)) runner.applyAction(ActionType.rest);
      }
      return; // Skip other actions to focus on recovery
    }

    // Education progression
    if (runner.state.activeEducation != null) {
      while (runner.canStudy()) {
        runner.study();
      }
    }

    // Company progression
    if (runner.state.activeCompany != null) {
      final actions = runner.companyService.actions;
      if (actions.isNotEmpty) {
        // Balanced approach: mix operations and client outreach
        int actionIndex = runner.random.nextDouble() > 0.5 ? 0 : (actions.length > 1 ? 1 : 0);
        while (runner.canDoCompanyAction(actions[actionIndex])) {
          runner.doCompanyAction(actions[actionIndex]);
          actionIndex = runner.random.nextDouble() > 0.5 ? 0 : (actions.length > 1 ? 1 : 0);
        }
      }
    }

    // Leftover energy into self-study or rest
    if (runner.canAffordAction(ActionType.selfStudy)) {
      runner.applyAction(ActionType.selfStudy);
    }
    
    // Always leave some room for basic rest
    while (runner.canAffordAction(ActionType.rest)) {
      runner.applyAction(ActionType.rest);
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
      
      // Balanced bot looks at everything moderately
      score += effect.cash ~/ 100;
      score -= effect.stress;
      score += effect.intelligence * 2;
      score += effect.reliability * 2;
      score += effect.health * 2;
      
      score += runner.random.nextInt(10);
      
      if (score > bestScore) {
        bestScore = score;
        bestChoice = choice;
      }
    }
    
    return bestChoice;
  }
}
