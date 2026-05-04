import 'event_effect.dart';

class EventChoice {
  const EventChoice({
    required this.id,
    required this.label,
    required this.resultText,
    required this.effect,
  });

  final String id;
  final String label;
  final String resultText;
  final EventEffect effect;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'resultText': resultText,
      'effect': effect.toJson(),
    };
  }

  factory EventChoice.fromJson(Map<String, dynamic> json) {
    return EventChoice(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? 'Continue',
      resultText: json['resultText'] as String? ?? '',
      effect: EventEffect.fromJson(
        Map<String, dynamic>.from(json['effect'] as Map? ?? {}),
      ),
    );
  }
}
