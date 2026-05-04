class ConditionEffect {
  const ConditionEffect({
    this.health = 0,
    this.happiness = 0,
    this.stress = 0,
    this.intelligence = 0,
    this.reliability = 0,
    this.energyRecovery = 0,
    this.studyProgressBonus = 0,
    this.jobPerformance = 0,
    this.companyHealth = 0,
    this.companyMomentum = 0,
  });

  final int health;
  final int happiness;
  final int stress;
  final int intelligence;
  final int reliability;
  final int energyRecovery;
  final int studyProgressBonus;
  final int jobPerformance;
  final int companyHealth;
  final int companyMomentum;

  bool get hasMonthlyStatEffect {
    return health != 0 ||
        happiness != 0 ||
        stress != 0 ||
        intelligence != 0 ||
        reliability != 0;
  }
}
