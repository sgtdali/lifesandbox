class ActiveDebt {
  const ActiveDebt({
    required this.id,
    required this.title,
    required this.remainingBalance,
    required this.monthlyPayment,
    required this.remainingMonths,
    required this.isEmergency,
  });

  final String id;
  final String title;
  final int remainingBalance;
  final int monthlyPayment;
  final int remainingMonths;
  final bool isEmergency;

  ActiveDebt copyWith({
    int? remainingBalance,
    int? monthlyPayment,
    int? remainingMonths,
  }) {
    return ActiveDebt(
      id: id,
      title: title,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      monthlyPayment: monthlyPayment ?? this.monthlyPayment,
      remainingMonths: remainingMonths ?? this.remainingMonths,
      isEmergency: isEmergency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'remainingBalance': remainingBalance,
      'monthlyPayment': monthlyPayment,
      'remainingMonths': remainingMonths,
      'isEmergency': isEmergency,
    };
  }

  factory ActiveDebt.fromJson(Map<String, dynamic> json) {
    return ActiveDebt(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Debt',
      remainingBalance: json['remainingBalance'] as int? ?? 0,
      monthlyPayment: json['monthlyPayment'] as int? ?? 0,
      remainingMonths: json['remainingMonths'] as int? ?? 0,
      isEmergency: json['isEmergency'] as bool? ?? false,
    );
  }
}
