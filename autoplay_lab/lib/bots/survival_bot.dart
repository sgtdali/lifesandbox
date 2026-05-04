import 'package:ambition_flutter/game/models/action_type.dart';
import 'package:ambition_flutter/features/events/models/life_event.dart';
import 'package:ambition_flutter/features/events/models/event_choice.dart';
import '../simulation_runner.dart';
import 'base_bot.dart';

class SurvivalBot extends BaseBot {
  const SurvivalBot();

  @override
  String get name => 'SurvivalBot';

  @override
  void takeTurn(dynamic r) {
    final runner = r as SimulationRunner;

    // Apply for best job if unemployed
    if (runner.state.currentJob == null) {
      runner.applyToBestJob();
    }

    // Occasional variation: 10% chance to do a random action if affordable
    if (runner.random.nextDouble() < 0.10 && runner.canAffordAction(ActionType.walk)) {
      runner.applyAction(ActionType.walk);
    }

    // High stress or low health? Rest heavily.
    if (runner.state.player.stats.stress > 60 || runner.state.player.stats.health < 40) {
      while (runner.canAffordAction(ActionType.deepRest)) {
        runner.applyAction(ActionType.deepRest);
      }
      while (runner.canAffordAction(ActionType.rest)) {
        runner.applyAction(ActionType.rest);
      }
    } else {
      // General wellness maintenance
      if (runner.canAffordAction(ActionType.walk)) {
        runner.applyAction(ActionType.walk);
      }
      
      // Pay debt if there is any and we have decent cash
      if (runner.state.activeDebts.isNotEmpty && runner.state.player.cash > 500) {
        runner.financeService.payDownDebt(runner.state, 100);
      }

      // Any remaining energy? Just light rest to maintain stability.
      while (runner.canAffordAction(ActionType.rest)) {
        runner.applyAction(ActionType.rest);
      }
    }
  }

  @override
  EventChoice chooseEventAction(dynamic r, LifeEvent event) {
    final runner = r as SimulationRunner;
    
    // SurvivalBot scores choices by avoiding negative impacts.
    EventChoice bestChoice = event.choices.first;
    int bestScore = -99999;

    for (final choice in event.choices) {
      int score = 0;
      final effect = choice.effect;
      
      // Heavily penalize cash loss
      if (effect.cash < 0) score += effect.cash; // negative
      
      // Penalize stress increase
      score -= effect.stress * 2;
      
      // Reward health
      score += effect.health * 3;
      
      // Add slight randomness (variation)
      score += runner.random.nextInt(10);
      
      if (score > bestScore) {
        bestScore = score;
        bestChoice = choice;
      }
    }
    
    return bestChoice;
  }
}
