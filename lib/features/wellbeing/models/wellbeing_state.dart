enum WellbeingTier {
  thriving,
  stable,
  strained,
  drained,
  burnoutRisk,
}

class WellbeingEvaluation {
  const WellbeingEvaluation({
    required this.tier,
    required this.label,
    required this.description,
    required this.drivers,
    required this.energyRecoveryModifier,
    required this.performanceModifier,
    required this.studyModifier,
    required this.companyActionPercent,
  });

  final WellbeingTier tier;
  final String label;
  final String description;
  final List<String> drivers;
  final int energyRecoveryModifier;
  final int performanceModifier;
  final int studyModifier;
  final int companyActionPercent;
}
