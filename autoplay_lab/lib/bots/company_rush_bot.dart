import 'package:ambition_flutter/game/models/action_type.dart';
import 'package:ambition_flutter/features/events/models/life_event.dart';
import 'package:ambition_flutter/features/events/models/event_choice.dart';
import '../simulation_runner.dart';
import 'base_bot.dart';

class CompanyRushBot extends BaseBot {
  const CompanyRushBot();

  @override
  String get name => 'CompanyRushBot';

  @override
  void takeTurn(dynamic r) {
    final runner = r as SimulationRunner;

    // Secure income first
    runner.applyToBestJob();

    // Check if we can found a company
    if (runner.state.activeCompany == null) {
      if (runner.companyService.types.isNotEmpty) {
        // Tie-breaker variation: sometimes pick a random valid company type
        int typeIndex = 0;
        if (runner.random.nextDouble() < 0.25) {
           typeIndex = runner.random.nextInt(runner.companyService.types.length);
        }
        final type = runner.companyService.types[typeIndex];
        if (runner.companyService.canFound(runner.state, type)) {
          runner.foundCompany(type);
        }
      }
    }

    // If we have a company, focus all energy on it
    if (runner.state.activeCompany != null) {
      final actions = runner.companyService.actions;
      if (actions.isNotEmpty) {
        // Mostly spam the first action (Client Outreach), occasionally mix it up
        while (runner.canDoCompanyAction(actions.first)) {
           final actionIndex = runner.random.nextDouble() < 0.20 ? runner.random.nextInt(actions.length) : 0;
           runner.doCompanyAction(actions[actionIndex]);
        }
      }
    }

    // If stress gets out of hand, minimal recovery
    if (runner.state.player.stats.stress > 85) {
      if (runner.canAffordAction(ActionType.socialTime)) {
        runner.applyAction(ActionType.socialTime);
      } else if (runner.canAffordAction(ActionType.rest)) {
        runner.applyAction(ActionType.rest);
      }
    }

    // Spend leftover energy looking around or resting
    while (runner.canAffordAction(ActionType.lookAround)) {
      runner.applyAction(ActionType.lookAround);
    }
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
      
      // Values cash generation highly
      score += effect.cash ~/ 50;
      
      // Values business momentum/opportunity if visible in effect
      // Actually, effects are mostly player stats, cash, conditions
      
      // Willing to accept stress for cash
      if (effect.cash > 200) {
        score -= effect.stress ~/ 2; // halving the stress penalty
      } else {
        score -= effect.stress;
      }
      
      // Small penalty for health loss
      score += effect.health * 2;
      
      score += runner.random.nextInt(20); // Highest variation
      
      if (score > bestScore) {
        bestScore = score;
        bestChoice = choice;
      }
    }
    
    return bestChoice;
  }
}
