import 'package:ambition_flutter/game/models/action_type.dart';
import 'package:ambition_flutter/features/events/models/life_event.dart';
import 'package:ambition_flutter/features/events/models/event_choice.dart';
import '../simulation_runner.dart';
import 'base_bot.dart';

class DebtBot extends BaseBot {
  const DebtBot();

  @override
  String get name => 'DebtBot';

  @override
  void takeTurn(dynamic r) {
    final runner = r as SimulationRunner;

    // Standard baseline: apply for jobs
    if (runner.state.currentJob == null) {
      runner.applyToBestJob();
    }

    // DebtBot unique behavior: Manage liquidity with loans and deposits
    
    // 1. Pay down debt if pressure is high
    final totalDebt = runner.state.activeDebts.fold(0, (sum, d) => sum + d.remainingBalance);
    final monthlyDebt = runner.state.activeDebts.fold(0, (sum, d) => sum + d.monthlyPayment);
    final obligations = runner.state.player.monthlyBaseExpense + runner.state.currentHousing.monthlyCost + monthlyDebt;
    final hasEmergencyDebt = runner.state.activeDebts.any((d) => d.isEmergency);

    if (totalDebt > 0 && (monthlyDebt > 50 || hasEmergencyDebt) && runner.state.player.cash > obligations + 100) {
      // High pressure or emergency debt, pay down aggressively
      if (runner.canPayDownDebt(150)) {
        runner.payDownDebt(150);
      } else if (runner.canPayDownDebt(50)) {
        runner.payDownDebt(50);
      }
    }

    // 2. Open deposits if we have extra cash (may cause liquidity mistake later)
    if (runner.state.player.cash > 800 && runner.state.activeDeposits.isEmpty) {
      if (runner.financeService.deposits.isNotEmpty) {
        // Lock up a large chunk of cash
        runner.openDeposit(runner.financeService.deposits.first, 500);
      }
    }

    // 3. Take loans to maintain flexibility if cash gets low (thinner buffer than before)
    if (runner.state.player.cash < obligations + 150 && totalDebt < 1500) {
      // More willing to take Small Personal Loan, maybe Large if really needed
      final isDesperate = runner.state.player.cash < 50;
      final loanType = isDesperate && runner.financeService.loans.length > 1 ? 
          runner.financeService.loans[1] : // Large Personal Loan 
          runner.financeService.loans.first; // Small Personal Loan
          
      // Don't take multiple loans in a row too rapidly, limit to 3 debts
      if (runner.state.activeDebts.length < 3) {
        runner.takeLoan(loanType);
      }
    }

    // If we locked up cash in deposits and are now struggling, withdraw early
    if (runner.state.player.cash < 50 && runner.state.activeDeposits.isNotEmpty) {
      runner.withdrawDeposit(runner.state.activeDeposits.first);
    }
    
    // 4. Housing Logic
    // DebtBot considers moving down if under severe pressure, or might move up if flush with cash
    if (hasEmergencyDebt || runner.state.player.stats.stress > 80 || (totalDebt > 800 && runner.state.player.cash < 100)) {
      // Under pressure, try to downgrade housing if not already in shared room
      if (runner.state.currentHousing.id != 'shared_room') {
        final cheaperHousing = runner.housingService.options.firstWhere((o) => o.id == 'shared_room', orElse: () => runner.housingService.options.first);
        if (runner.canMoveHousing(cheaperHousing) && cheaperHousing.id != runner.state.currentHousing.id) {
          runner.moveHousing(cheaperHousing);
        }
      }
    } else if (runner.state.player.cash > 1500 && runner.state.currentJob != null && totalDebt < 300) {
      // Flush with cash, might try to upgrade housing (potentially creating a trap for itself later)
      if (runner.state.currentHousing.id == 'shared_room') {
        final betterHousing = runner.housingService.options.firstWhere((o) => o.id == 'studio_apartment', orElse: () => runner.housingService.options.last);
        if (runner.canMoveHousing(betterHousing) && betterHousing.id != runner.state.currentHousing.id) {
          runner.moveHousing(betterHousing);
        }
      }
    }

    // Normal actions
    if (runner.state.player.stats.stress > 65) {
      while (runner.canAffordAction(ActionType.socialTime)) {
        runner.applyAction(ActionType.socialTime);
      }
      while (runner.canAffordAction(ActionType.rest)) {
        runner.applyAction(ActionType.rest);
      }
    } else {
      if (runner.canAffordAction(ActionType.lookAround)) {
        runner.applyAction(ActionType.lookAround);
      }
      if (runner.canAffordAction(ActionType.walk)) {
        runner.applyAction(ActionType.walk);
      }
      while (runner.canAffordAction(ActionType.rest)) {
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
      
      // DebtBot doesn't mind mild cash losses if it gives stats (willing to borrow to cover it)
      if (effect.cash < 0) {
        score += effect.cash ~/ 150; // Very small penalty
      } else {
        score += effect.cash ~/ 100;
      }
      
      // Prefers happiness and health
      score += effect.happiness * 3;
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
