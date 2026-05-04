import 'condition_effect.dart';

enum ConditionTone {
  positive,
  negative,
  mixed,
}

class OngoingCondition {
  const OngoingCondition({
    required this.id,
    required this.title,
    required this.description,
    required this.effectHint,
    required this.remainingMonths,
    required this.effect,
    required this.tone,
    required this.source,
  });

  final String id;
  final String title;
  final String description;
  final String effectHint;
  final int remainingMonths;
  final ConditionEffect effect;
  final ConditionTone tone;
  final String source;

  OngoingCondition copyWith({
    int? remainingMonths,
  }) {
    return OngoingCondition(
      id: id,
      title: title,
      description: description,
      effectHint: effectHint,
      remainingMonths: remainingMonths ?? this.remainingMonths,
      effect: effect,
      tone: tone,
      source: source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'effectHint': effectHint,
      'remainingMonths': remainingMonths,
      'effect': {
        'health': effect.health,
        'happiness': effect.happiness,
        'stress': effect.stress,
        'intelligence': effect.intelligence,
        'reliability': effect.reliability,
        'energyRecovery': effect.energyRecovery,
        'studyProgressBonus': effect.studyProgressBonus,
        'jobPerformance': effect.jobPerformance,
        'companyHealth': effect.companyHealth,
        'companyMomentum': effect.companyMomentum,
      },
      'tone': tone.name,
      'source': source,
    };
  }

  factory OngoingCondition.fromJson(Map<String, dynamic> json) {
    final effectJson = Map<String, dynamic>.from(json['effect'] as Map? ?? {});
    return OngoingCondition(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Condition',
      description: json['description'] as String? ?? '',
      effectHint: json['effectHint'] as String? ?? '',
      remainingMonths: json['remainingMonths'] as int? ?? 1,
      effect: ConditionEffect(
        health: effectJson['health'] as int? ?? 0,
        happiness: effectJson['happiness'] as int? ?? 0,
        stress: effectJson['stress'] as int? ?? 0,
        intelligence: effectJson['intelligence'] as int? ?? 0,
        reliability: effectJson['reliability'] as int? ?? 0,
        energyRecovery: effectJson['energyRecovery'] as int? ?? 0,
        studyProgressBonus: effectJson['studyProgressBonus'] as int? ?? 0,
        jobPerformance: effectJson['jobPerformance'] as int? ?? 0,
        companyHealth: effectJson['companyHealth'] as int? ?? 0,
        companyMomentum: effectJson['companyMomentum'] as int? ?? 0,
      ),
      tone: ConditionTone.values.firstWhere(
        (tone) => tone.name == json['tone'],
        orElse: () => ConditionTone.mixed,
      ),
      source: json['source'] as String? ?? 'Unknown',
    );
  }
}
