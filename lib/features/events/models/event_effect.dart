class EventEffect {
  const EventEffect({
    this.cash = 0,
    this.health = 0,
    this.happiness = 0,
    this.stress = 0,
    this.intelligence = 0,
    this.reliability = 0,
    this.addConditionIds = const [],
    this.removeConditionIds = const [],
    this.followUpEventId,
    this.followUpDelayMonths = 1,
  });

  final int cash;
  final int health;
  final int happiness;
  final int stress;
  final int intelligence;
  final int reliability;
  final List<String> addConditionIds;
  final List<String> removeConditionIds;
  final String? followUpEventId;
  final int followUpDelayMonths;

  bool get hasEffect {
    return cash != 0 ||
        health != 0 ||
        happiness != 0 ||
        stress != 0 ||
        intelligence != 0 ||
        reliability != 0 ||
        addConditionIds.isNotEmpty ||
        removeConditionIds.isNotEmpty ||
        followUpEventId != null;
  }

  String get summary {
    final parts = <String>[];
    if (cash != 0) parts.add('Cash ${_signed(cash)}');
    if (health != 0) parts.add('Health ${_signed(health)}');
    if (happiness != 0) parts.add('Happiness ${_signed(happiness)}');
    if (stress != 0) parts.add('Stress ${_signed(stress)}');
    if (intelligence != 0) parts.add('Intelligence ${_signed(intelligence)}');
    if (reliability != 0) parts.add('Reliability ${_signed(reliability)}');
    if (addConditionIds.isNotEmpty) parts.add('Condition added');
    if (removeConditionIds.isNotEmpty) parts.add('Condition relieved');
    if (followUpEventId != null) parts.add('May continue later');
    return parts.isEmpty ? 'No direct effect' : parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'cash': cash,
      'health': health,
      'happiness': happiness,
      'stress': stress,
      'intelligence': intelligence,
      'reliability': reliability,
      'addConditionIds': addConditionIds,
      'removeConditionIds': removeConditionIds,
      'followUpEventId': followUpEventId,
      'followUpDelayMonths': followUpDelayMonths,
    };
  }

  factory EventEffect.fromJson(Map<String, dynamic> json) {
    return EventEffect(
      cash: json['cash'] as int? ?? 0,
      health: json['health'] as int? ?? 0,
      happiness: json['happiness'] as int? ?? 0,
      stress: json['stress'] as int? ?? 0,
      intelligence: json['intelligence'] as int? ?? 0,
      reliability: json['reliability'] as int? ?? 0,
      addConditionIds:
          (json['addConditionIds'] as List? ?? []).map((item) => '$item').toList(),
      removeConditionIds: (json['removeConditionIds'] as List? ?? [])
          .map((item) => '$item')
          .toList(),
      followUpEventId: json['followUpEventId'] as String?,
      followUpDelayMonths: json['followUpDelayMonths'] as int? ?? 1,
    );
  }

  static String _signed(int value) {
    return value > 0 ? '+$value' : '$value';
  }
}
