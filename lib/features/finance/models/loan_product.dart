class LoanProduct {
  const LoanProduct({
    required this.id,
    required this.title,
    required this.principal,
    required this.durationMonths,
    required this.monthlyPayment,
    required this.description,
  });

  final String id;
  final String title;
  final int principal;
  final int durationMonths;
  final int monthlyPayment;
  final String description;

  int get totalRepayment => durationMonths * monthlyPayment;
}
