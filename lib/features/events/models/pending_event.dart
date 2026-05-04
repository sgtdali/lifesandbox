import 'life_event.dart';

class PendingEvent {
  const PendingEvent({
    required this.event,
    required this.generatedMonth,
  });

  final LifeEvent event;
  final int generatedMonth;

  Map<String, dynamic> toJson() {
    return {
      'event': event.toJson(),
      'generatedMonth': generatedMonth,
    };
  }

  factory PendingEvent.fromJson(Map<String, dynamic> json) {
    return PendingEvent(
      event: LifeEvent.fromJson(
        Map<String, dynamic>.from(json['event'] as Map? ?? {}),
      ),
      generatedMonth: json['generatedMonth'] as int? ?? 1,
    );
  }
}
