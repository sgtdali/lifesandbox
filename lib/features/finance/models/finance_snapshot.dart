enum FinanceStateTier {
  fragile,
  pressured,
  stable,
  buffered,
  comfortable,
}

class FinanceSnapshot {
  const FinanceSnapshot({
    required this.tier,
    required this.label,
    required this.description,
    required this.cash,
    required this.totalDebt,
    required this.emergencyDebt,
    required this.monthlyDebtPayment,
    required this.totalDeposits,
    required this.flexibleDeposits,
    required this.lockedDeposits,
    required this.monthlyLifeObligations,
    required this.monthlyGrowthObligations,
    required this.totalMonthlyObligations,
    required this.cushionMonths,
    required this.signals,
  });

  final FinanceStateTier tier;
  final String label;
  final String description;
  final int cash;
  final int totalDebt;
  final int emergencyDebt;
  final int monthlyDebtPayment;
  final int totalDeposits;
  final int flexibleDeposits;
  final int lockedDeposits;
  final int monthlyLifeObligations;
  final int monthlyGrowthObligations;
  final int totalMonthlyObligations;
  final double cushionMonths;
  final List<String> signals;
}
