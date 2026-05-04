class DepositProduct {
  const DepositProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.monthlyReturnPercent,
    required this.lockMonths,
    required this.isFlexible,
  });

  final String id;
  final String title;
  final String description;
  final int monthlyReturnPercent;
  final int lockMonths;
  final bool isFlexible;
}
