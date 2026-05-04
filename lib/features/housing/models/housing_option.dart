class HousingOption {
  const HousingOption({
    required this.id,
    required this.title,
    required this.description,
    required this.monthlyCost,
    required this.moveFee,
    required this.happinessModifier,
    required this.stressModifier,
    required this.healthModifier,
    required this.energyRecoveryModifier,
    required this.quality,
  });

  final String id;
  final String title;
  final String description;
  final int monthlyCost;
  final int moveFee;
  final int happinessModifier;
  final int stressModifier;
  final int healthModifier;
  final int energyRecoveryModifier;
  final String quality;

  String get modifierSummary {
    final parts = <String>[];
    if (happinessModifier != 0) parts.add('HAP ${_signed(happinessModifier)}');
    if (stressModifier != 0) parts.add('STR ${_signed(stressModifier)}');
    if (healthModifier != 0) parts.add('HLT ${_signed(healthModifier)}');
    if (energyRecoveryModifier != 0) {
      parts.add('EN ${_signed(energyRecoveryModifier)}');
    }
    return parts.isEmpty ? 'No modifiers' : parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'monthlyCost': monthlyCost,
      'moveFee': moveFee,
      'happinessModifier': happinessModifier,
      'stressModifier': stressModifier,
      'healthModifier': healthModifier,
      'energyRecoveryModifier': energyRecoveryModifier,
      'quality': quality,
    };
  }

  factory HousingOption.fromJson(Map<String, dynamic> json) {
    return HousingOption(
      id: json['id'] as String? ?? 'shared_room',
      title: json['title'] as String? ?? 'Shared Room',
      description: json['description'] as String? ?? '',
      monthlyCost: json['monthlyCost'] as int? ?? 35,
      moveFee: json['moveFee'] as int? ?? 0,
      happinessModifier: json['happinessModifier'] as int? ?? -2,
      stressModifier: json['stressModifier'] as int? ?? 3,
      healthModifier: json['healthModifier'] as int? ?? 0,
      energyRecoveryModifier: json['energyRecoveryModifier'] as int? ?? -5,
      quality: json['quality'] as String? ?? 'Basic',
    );
  }

  static String _signed(int value) {
    return value > 0 ? '+$value' : '$value';
  }
}
