import 'company_type.dart';

class ActiveCompany {
  const ActiveCompany({
    required this.name,
    required this.type,
    required this.monthsActive,
    required this.health,
    required this.momentum,
    required this.pipeline,
    required this.operations,
    required this.effortThisMonth,
    required this.clientFocusThisMonth,
    required this.operationsFocusThisMonth,
    this.lastNetResult = 0,
  });

  final String name;
  final CompanyType type;
  final int monthsActive;
  final int health;
  final int momentum;
  final int pipeline;
  final int operations;
  final int effortThisMonth;
  final int clientFocusThisMonth;
  final int operationsFocusThisMonth;
  final int lastNetResult;

  ActiveCompany copyWith({
    int? monthsActive,
    int? health,
    int? momentum,
    int? pipeline,
    int? operations,
    int? effortThisMonth,
    int? clientFocusThisMonth,
    int? operationsFocusThisMonth,
    int? lastNetResult,
  }) {
    return ActiveCompany(
      name: name,
      type: type,
      monthsActive: monthsActive ?? this.monthsActive,
      health: health ?? this.health,
      momentum: momentum ?? this.momentum,
      pipeline: pipeline ?? this.pipeline,
      operations: operations ?? this.operations,
      effortThisMonth: effortThisMonth ?? this.effortThisMonth,
      clientFocusThisMonth:
          clientFocusThisMonth ?? this.clientFocusThisMonth,
      operationsFocusThisMonth:
          operationsFocusThisMonth ?? this.operationsFocusThisMonth,
      lastNetResult: lastNetResult ?? this.lastNetResult,
    );
  }

  ActiveCompany resetMonthlyFocus() {
    return copyWith(
      effortThisMonth: 0,
      clientFocusThisMonth: 0,
      operationsFocusThisMonth: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'typeId': type.id,
      'monthsActive': monthsActive,
      'health': health,
      'momentum': momentum,
      'pipeline': pipeline,
      'operations': operations,
      'effortThisMonth': effortThisMonth,
      'clientFocusThisMonth': clientFocusThisMonth,
      'operationsFocusThisMonth': operationsFocusThisMonth,
      'lastNetResult': lastNetResult,
    };
  }
}
