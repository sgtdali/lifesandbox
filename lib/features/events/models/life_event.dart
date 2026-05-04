import 'event_choice.dart';

enum EventCondition {
  always,
  employed,
  unemployed,
  activeEducation,
  lowQualityHousing,
  highStress,
  wellbeingPressure,
  positiveWellbeing,
  debtPressure,
  activeCompany,
  fragileCompany,
  careerMomentum,
  activeCondition,
  scheduledFollowUp,
}

enum EventTone {
  positive,
  negative,
  mixed,
}

class LifeEvent {
  const LifeEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.weight,
    required this.condition,
    required this.choices,
    this.tone = EventTone.mixed,
    this.contextConditionIds = const [],
    this.triggerHint = '',
    this.followUpOnly = false,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final int weight;
  final EventCondition condition;
  final List<EventChoice> choices;
  final EventTone tone;
  final List<String> contextConditionIds;
  final String triggerHint;
  final bool followUpOnly;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'weight': weight,
      'condition': condition.name,
      'choices': choices.map((choice) => choice.toJson()).toList(),
      'tone': tone.name,
      'contextConditionIds': contextConditionIds,
      'triggerHint': triggerHint,
      'followUpOnly': followUpOnly,
    };
  }

  factory LifeEvent.fromJson(Map<String, dynamic> json) {
    return LifeEvent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Monthly Event',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Life',
      weight: json['weight'] as int? ?? 10,
      condition: EventCondition.values.firstWhere(
        (condition) => condition.name == json['condition'],
        orElse: () => EventCondition.always,
      ),
      choices: (json['choices'] as List? ?? [])
          .map((item) => EventChoice.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      tone: EventTone.values.firstWhere(
        (tone) => tone.name == json['tone'],
        orElse: () => EventTone.mixed,
      ),
      contextConditionIds: (json['contextConditionIds'] as List? ?? [])
          .map((item) => '$item')
          .toList(),
      triggerHint: json['triggerHint'] as String? ?? '',
      followUpOnly: json['followUpOnly'] as bool? ?? false,
    );
  }
}
