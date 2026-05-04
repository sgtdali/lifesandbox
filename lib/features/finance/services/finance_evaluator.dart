import '../../../game/models/game_state.dart';
import '../models/finance_snapshot.dart';

class FinanceEvaluator {
  const FinanceEvaluator();

  FinanceSnapshot evaluate(GameState state) {
    final cash = state.player.cash;
    final debt = state.activeDebts.fold<int>(
      0,
      (total, item) => total + item.remainingBalance,
    );
    final emergencyDebt = state.activeDebts
        .where((item) => item.isEmergency)
        .fold<int>(0, (total, item) => total + item.remainingBalance);
    final monthlyDebt = state.activeDebts.fold<int>(
      0,
      (total, item) => total + item.monthlyPayment,
    );
    final flexibleDeposits = state.activeDeposits
        .where((item) => item.isFlexible)
        .fold<int>(0, (total, item) => total + item.amount);
    final lockedDeposits = state.activeDeposits
        .where((item) => !item.isFlexible)
        .fold<int>(0, (total, item) => total + item.amount);
    final totalDeposits = flexibleDeposits + lockedDeposits;
    final lifeObligations =
        state.player.monthlyBaseExpense + state.currentHousing.monthlyCost;
    final growthObligations =
        (state.activeEducation?.program.monthlyCost ?? 0) +
            (state.activeCompany?.type.monthlyOperatingCost ?? 0);
    final totalObligations = lifeObligations + growthObligations + monthlyDebt;
    final cushionMonths =
        totalObligations <= 0 ? 0.0 : cash / totalObligations;
    final tier = _tierFor(
      cash: cash,
      debt: debt,
      emergencyDebt: emergencyDebt,
      monthlyDebt: monthlyDebt,
      cushionMonths: cushionMonths,
      companyActive: state.activeCompany != null,
    );

    return FinanceSnapshot(
      tier: tier,
      label: _label(tier),
      description: _description(tier),
      cash: cash,
      totalDebt: debt,
      emergencyDebt: emergencyDebt,
      monthlyDebtPayment: monthlyDebt,
      totalDeposits: totalDeposits,
      flexibleDeposits: flexibleDeposits,
      lockedDeposits: lockedDeposits,
      monthlyLifeObligations: lifeObligations,
      monthlyGrowthObligations: growthObligations,
      totalMonthlyObligations: totalObligations,
      cushionMonths: cushionMonths,
      signals: _signals(
        cash: cash,
        debt: debt,
        emergencyDebt: emergencyDebt,
        monthlyDebt: monthlyDebt,
        lockedDeposits: lockedDeposits,
        totalObligations: totalObligations,
        companyActive: state.activeCompany != null,
      ),
    );
  }

  FinanceStateTier _tierFor({
    required int cash,
    required int debt,
    required int emergencyDebt,
    required int monthlyDebt,
    required double cushionMonths,
    required bool companyActive,
  }) {
    if (emergencyDebt > 0 || cash < 60 || monthlyDebt >= 75) {
      return FinanceStateTier.fragile;
    }
    if (cushionMonths < 1.0 || debt > cash + 180) {
      return FinanceStateTier.pressured;
    }
    if (cushionMonths >= 3.0 && debt == 0) {
      return FinanceStateTier.comfortable;
    }
    if (cushionMonths >= (companyActive ? 2.2 : 1.8) && debt <= cash) {
      return FinanceStateTier.buffered;
    }
    return FinanceStateTier.stable;
  }

  String _label(FinanceStateTier tier) {
    switch (tier) {
      case FinanceStateTier.fragile:
        return 'Fragile';
      case FinanceStateTier.pressured:
        return 'Pressured';
      case FinanceStateTier.stable:
        return 'Stable';
      case FinanceStateTier.buffered:
        return 'Buffered';
      case FinanceStateTier.comfortable:
        return 'Comfortable';
    }
  }

  String _description(FinanceStateTier tier) {
    switch (tier) {
      case FinanceStateTier.fragile:
        return 'One bad month can create lasting debt pressure.';
      case FinanceStateTier.pressured:
        return 'Your obligations are still crowding out flexibility.';
      case FinanceStateTier.stable:
        return 'The month is manageable, but cushion still matters.';
      case FinanceStateTier.buffered:
        return 'You have room to plan instead of only react.';
      case FinanceStateTier.comfortable:
        return 'Cashflow is strong enough to support bigger choices.';
    }
  }

  List<String> _signals({
    required int cash,
    required int debt,
    required int emergencyDebt,
    required int monthlyDebt,
    required int lockedDeposits,
    required int totalObligations,
    required bool companyActive,
  }) {
    final signals = <String>[];
    if (emergencyDebt > 0) signals.add('Emergency debt should be cleared first');
    if (cash < totalObligations) signals.add('Cash is below one month of obligations');
    if (monthlyDebt >= 50) signals.add('Debt payments are heavy');
    if (lockedDeposits > 0 && cash < totalObligations) {
      signals.add('Locked savings are reducing liquidity');
    }
    if (companyActive && cash < totalObligations * 2) {
      signals.add('Company ownership needs a larger cushion');
    }
    if (debt == 0 && cash >= totalObligations * 2) {
      signals.add('You have room for deposits or growth investments');
    }
    if (signals.isEmpty) signals.add('No major finance pressure signal');
    return signals.take(3).toList();
  }
}
