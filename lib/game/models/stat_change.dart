class StatChange {
  const StatChange({
    required this.label,
    required this.amount,
  });

  final String label;
  final int amount;

  bool get hasChange => amount != 0;

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'amount': amount,
    };
  }

  factory StatChange.fromJson(Map<String, dynamic> json) {
    return StatChange(
      label: json['label'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
    );
  }
}
