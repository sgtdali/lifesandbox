class ActiveDeposit {
  const ActiveDeposit({
    required this.id,
    required this.title,
    required this.amount,
    required this.monthlyReturnPercent,
    required this.remainingMonths,
    required this.isFlexible,
  });

  final String id;
  final String title;
  final int amount;
  final int monthlyReturnPercent;
  final int remainingMonths;
  final bool isFlexible;

  ActiveDeposit copyWith({
    int? amount,
    int? remainingMonths,
  }) {
    return ActiveDeposit(
      id: id,
      title: title,
      amount: amount ?? this.amount,
      monthlyReturnPercent: monthlyReturnPercent,
      remainingMonths: remainingMonths ?? this.remainingMonths,
      isFlexible: isFlexible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'monthlyReturnPercent': monthlyReturnPercent,
      'remainingMonths': remainingMonths,
      'isFlexible': isFlexible,
    };
  }

  factory ActiveDeposit.fromJson(Map<String, dynamic> json) {
    return ActiveDeposit(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Deposit',
      amount: json['amount'] as int? ?? 0,
      monthlyReturnPercent: json['monthlyReturnPercent'] as int? ?? 0,
      remainingMonths: json['remainingMonths'] as int? ?? 0,
      isFlexible: json['isFlexible'] as bool? ?? true,
    );
  }
}
