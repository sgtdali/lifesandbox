import 'stat_change.dart';

class MonthResult {
  const MonthResult({
    required this.previousMonth,
    required this.cashBefore,
    required this.cashAfter,
    required this.baseExpense,
    required this.housingCostPaid,
    required this.housingEnergyModifier,
    required this.salaryEarned,
    required this.jobEnergyLoad,
    required this.educationCostPaid,
    required this.educationStudyRequired,
    required this.educationStudyApplied,
    required this.educationProgressAdvanced,
    required this.debtPaid,
    required this.emergencyDebtCreated,
    required this.emergencyDebtPaid,
    required this.depositInterestEarned,
    required this.maturedDepositPayout,
    required this.companyRevenue,
    required this.companyOperatingCost,
    required this.companyNet,
    required this.companyHealthDelta,
    required this.companyMomentumDelta,
    required this.companyPipelineDelta,
    required this.companyOperationsDelta,
    required this.conditionEnergyModifier,
    required this.gainedConditions,
    required this.expiredConditions,
    required this.wellbeingLabel,
    required this.wellbeingEnergyModifier,
    this.companyName,
    this.completedEducationTitle,
    this.housingTitle,
    required this.cashChange,
    required this.statChanges,
    required this.messages,
  });

  final int previousMonth;
  final int cashBefore;
  final int cashAfter;
  final int baseExpense;
  final int housingCostPaid;
  final int housingEnergyModifier;
  final int salaryEarned;
  final int jobEnergyLoad;
  final int educationCostPaid;
  final int educationStudyRequired;
  final int educationStudyApplied;
  final bool educationProgressAdvanced;
  final int debtPaid;
  final int emergencyDebtCreated;
  final int emergencyDebtPaid;
  final int depositInterestEarned;
  final int maturedDepositPayout;
  final int companyRevenue;
  final int companyOperatingCost;
  final int companyNet;
  final int companyHealthDelta;
  final int companyMomentumDelta;
  final int companyPipelineDelta;
  final int companyOperationsDelta;
  final int conditionEnergyModifier;
  final List<String> gainedConditions;
  final List<String> expiredConditions;
  final String wellbeingLabel;
  final int wellbeingEnergyModifier;
  final String? companyName;
  final String? completedEducationTitle;
  final String? housingTitle;
  final int cashChange;
  final List<StatChange> statChanges;
  final List<String> messages;

  Map<String, dynamic> toJson() {
    return {
      'previousMonth': previousMonth,
      'cashBefore': cashBefore,
      'cashAfter': cashAfter,
      'baseExpense': baseExpense,
      'housingCostPaid': housingCostPaid,
      'housingEnergyModifier': housingEnergyModifier,
      'salaryEarned': salaryEarned,
      'jobEnergyLoad': jobEnergyLoad,
      'educationCostPaid': educationCostPaid,
      'educationStudyRequired': educationStudyRequired,
      'educationStudyApplied': educationStudyApplied,
      'educationProgressAdvanced': educationProgressAdvanced,
      'debtPaid': debtPaid,
      'emergencyDebtCreated': emergencyDebtCreated,
      'emergencyDebtPaid': emergencyDebtPaid,
      'depositInterestEarned': depositInterestEarned,
      'maturedDepositPayout': maturedDepositPayout,
      'companyRevenue': companyRevenue,
      'companyOperatingCost': companyOperatingCost,
      'companyNet': companyNet,
      'companyHealthDelta': companyHealthDelta,
      'companyMomentumDelta': companyMomentumDelta,
      'companyPipelineDelta': companyPipelineDelta,
      'companyOperationsDelta': companyOperationsDelta,
      'conditionEnergyModifier': conditionEnergyModifier,
      'gainedConditions': gainedConditions,
      'expiredConditions': expiredConditions,
      'wellbeingLabel': wellbeingLabel,
      'wellbeingEnergyModifier': wellbeingEnergyModifier,
      'companyName': companyName,
      'completedEducationTitle': completedEducationTitle,
      'housingTitle': housingTitle,
      'cashChange': cashChange,
      'statChanges': statChanges.map((change) => change.toJson()).toList(),
      'messages': messages,
    };
  }

  factory MonthResult.fromJson(Map<String, dynamic> json) {
    return MonthResult(
      previousMonth: json['previousMonth'] as int? ?? 1,
      cashBefore: json['cashBefore'] as int? ?? 0,
      cashAfter: json['cashAfter'] as int? ?? 0,
      baseExpense: json['baseExpense'] as int? ?? 0,
      housingCostPaid: json['housingCostPaid'] as int? ?? 0,
      housingEnergyModifier: json['housingEnergyModifier'] as int? ?? 0,
      salaryEarned: json['salaryEarned'] as int? ?? 0,
      jobEnergyLoad: json['jobEnergyLoad'] as int? ?? 0,
      educationCostPaid: json['educationCostPaid'] as int? ?? 0,
      educationStudyRequired: json['educationStudyRequired'] as int? ?? 0,
      educationStudyApplied: json['educationStudyApplied'] as int? ?? 0,
      educationProgressAdvanced:
          json['educationProgressAdvanced'] as bool? ?? false,
      debtPaid: json['debtPaid'] as int? ?? 0,
      emergencyDebtCreated: json['emergencyDebtCreated'] as int? ?? 0,
      emergencyDebtPaid: json['emergencyDebtPaid'] as int? ?? 0,
      depositInterestEarned: json['depositInterestEarned'] as int? ?? 0,
      maturedDepositPayout: json['maturedDepositPayout'] as int? ?? 0,
      companyRevenue: json['companyRevenue'] as int? ?? 0,
      companyOperatingCost: json['companyOperatingCost'] as int? ?? 0,
      companyNet: json['companyNet'] as int? ?? 0,
      companyHealthDelta: json['companyHealthDelta'] as int? ?? 0,
      companyMomentumDelta: json['companyMomentumDelta'] as int? ?? 0,
      companyPipelineDelta: json['companyPipelineDelta'] as int? ?? 0,
      companyOperationsDelta: json['companyOperationsDelta'] as int? ?? 0,
      conditionEnergyModifier: json['conditionEnergyModifier'] as int? ?? 0,
      gainedConditions:
          (json['gainedConditions'] as List? ?? []).map((item) => '$item').toList(),
      expiredConditions:
          (json['expiredConditions'] as List? ?? []).map((item) => '$item').toList(),
      wellbeingLabel: json['wellbeingLabel'] as String? ?? 'Stable',
      wellbeingEnergyModifier: json['wellbeingEnergyModifier'] as int? ?? 0,
      companyName: json['companyName'] as String?,
      completedEducationTitle: json['completedEducationTitle'] as String?,
      housingTitle: json['housingTitle'] as String?,
      cashChange: json['cashChange'] as int? ?? 0,
      statChanges: (json['statChanges'] as List? ?? [])
          .map((item) => StatChange.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      messages:
          (json['messages'] as List? ?? []).map((item) => '$item').toList(),
    );
  }
}
