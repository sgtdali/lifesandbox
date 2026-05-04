class CoreStats {
  const CoreStats({
    required this.health,
    required this.happiness,
    required this.stress,
    required this.energy,
    required this.maxEnergy,
    required this.intelligence,
  });

  final int health;
  final int happiness;
  final int stress;
  final int energy;
  final int maxEnergy;
  final int intelligence;

  factory CoreStats.initial() {
    return const CoreStats(
      health: 70,
      happiness: 62,
      stress: 34,
      energy: 100,
      maxEnergy: 100,
      intelligence: 52,
    );
  }

  CoreStats copyWith({
    int? health,
    int? happiness,
    int? stress,
    int? energy,
    int? maxEnergy,
    int? intelligence,
  }) {
    return CoreStats(
      health: health ?? this.health,
      happiness: happiness ?? this.happiness,
      stress: stress ?? this.stress,
      energy: energy ?? this.energy,
      maxEnergy: maxEnergy ?? this.maxEnergy,
      intelligence: intelligence ?? this.intelligence,
    );
  }

  CoreStats apply({
    int health = 0,
    int happiness = 0,
    int stress = 0,
    int energy = 0,
    int intelligence = 0,
  }) {
    return copyWith(
      health: _clampStat(this.health + health),
      happiness: _clampStat(this.happiness + happiness),
      stress: _clampStat(this.stress + stress),
      energy: (this.energy + energy).clamp(0, maxEnergy).toInt(),
      intelligence: _clampStat(this.intelligence + intelligence),
    );
  }

  CoreStats resetEnergy() => copyWith(energy: maxEnergy);

  Map<String, dynamic> toJson() {
    return {
      'health': health,
      'happiness': happiness,
      'stress': stress,
      'energy': energy,
      'maxEnergy': maxEnergy,
      'intelligence': intelligence,
    };
  }

  factory CoreStats.fromJson(Map<String, dynamic> json) {
    return CoreStats(
      health: json['health'] as int? ?? 70,
      happiness: json['happiness'] as int? ?? 62,
      stress: json['stress'] as int? ?? 34,
      energy: json['energy'] as int? ?? 100,
      maxEnergy: json['maxEnergy'] as int? ?? 100,
      intelligence: json['intelligence'] as int? ?? 52,
    );
  }

  static int _clampStat(int value) => value.clamp(0, 100).toInt();
}
