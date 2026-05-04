class ScheduledEvent {
  const ScheduledEvent({
    required this.eventId,
    required this.targetMonth,
    required this.sourceEventId,
  });

  final String eventId;
  final int targetMonth;
  final String sourceEventId;

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'targetMonth': targetMonth,
      'sourceEventId': sourceEventId,
    };
  }

  factory ScheduledEvent.fromJson(Map<String, dynamic> json) {
    return ScheduledEvent(
      eventId: json['eventId'] as String? ?? '',
      targetMonth: json['targetMonth'] as int? ?? 1,
      sourceEventId: json['sourceEventId'] as String? ?? '',
    );
  }
}
