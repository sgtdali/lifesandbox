enum SuitabilityLevel {
  lowFit,
  risky,
  fit,
  strongFit,
}

extension SuitabilityLevelLabel on SuitabilityLevel {
  String get label {
    switch (this) {
      case SuitabilityLevel.lowFit:
        return 'Low Fit';
      case SuitabilityLevel.risky:
        return 'Risky';
      case SuitabilityLevel.fit:
        return 'Fit';
      case SuitabilityLevel.strongFit:
        return 'Strong Fit';
    }
  }

  bool get canApply => this != SuitabilityLevel.lowFit;
}

class SuitabilityPreview {
  const SuitabilityPreview({
    required this.score,
    required this.threshold,
    required this.level,
    required this.reasons,
  });

  final int score;
  final int threshold;
  final SuitabilityLevel level;
  final List<String> reasons;
}
