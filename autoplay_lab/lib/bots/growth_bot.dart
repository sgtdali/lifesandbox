import 'package:ambition_flutter/game/models/action_type.dart';
import 'package:ambition_flutter/features/events/models/life_event.dart';
import 'package:ambition_flutter/features/events/models/event_choice.dart';
import '../simulation_runner.dart';
import 'base_bot.dart';

class GrowthBot extends BaseBot {
  const GrowthBot();

  @override
  String get name => 'GrowthBot';

  @override
  void takeTurn(dynamic r) {
    final runner = r as SimulationRunner;

    // Apply for best job constantly to scale up salary
    runner.applyToBestJob();

    // Start education if none is active
    if (runner.state.activeEducation == null && runner.state.player.cash > 500) {
      if (runner.educationService.programs.isNotEmpty) {
        // Variation: 20% chance to pick a random education program instead of the first
        int index = 0;
        if (runner.random.nextDouble() < 0.20 && runner.educationService.programs.length > 1) {
          index = runner.random.nextInt(runner.educationService.programs.length);
        }
        runner.state = runner.educationService.startProgram(runner.state, runner.educationService.programs[index]);
      }
    }

    // Study as much as possible
    while (runner.canStudy()) {
      runner.study();
    }

    // Deal with critical stress only if it gets bad
    if (runner.state.player.stats.stress > 80) {
      while (runner.canAffordAction(ActionType.personalReset)) {
        runner.applyAction(ActionType.personalReset);
      }
    }

    // Use remaining energy on self study
    while (runner.canAffordAction(ActionType.selfStudy)) {
      runner.applyAction(ActionType.selfStudy);
    }

    // If still have energy, rest
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
      
      // Values intelligence and progression highly
      score += effect.intelligence * 5;
      score += effect.reliability * 2;
      
      // Dislikes extreme negative cash, but tolerates small costs
      if (effect.cash < -500) {
        score -= 20;
      } else {
        score += effect.cash ~/ 100;
      }
      
      // Moderate penalty for stress
      score -= effect.stress;
      
      score += runner.random.nextInt(15); // Slightly higher variation threshold
      
      if (score > bestScore) {
        bestScore = score;
        bestChoice = choice;
      }
    }
    
    return bestChoice;
  }
}
