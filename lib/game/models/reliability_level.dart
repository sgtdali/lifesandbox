enum ReliabilityLevel {
  low('Low'),
  medium('Medium'),
  good('Good'),
  veryGood('Very Good');

  const ReliabilityLevel(this.label);

  final String label;

  static ReliabilityLevel fromScore(int score) {
    if (score >= 85) return ReliabilityLevel.veryGood;
    if (score >= 65) return ReliabilityLevel.good;
    if (score >= 40) return ReliabilityLevel.medium;
    return ReliabilityLevel.low;
  }
}
