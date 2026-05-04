enum RunStateTier {
  unstable,
  recovering,
  stable,
  growing,
  businessReady,
}

class RunStateEvaluation {
  const RunStateEvaluation({
    required this.tier,
    required this.label,
    required this.description,
  });

  final RunStateTier tier;
  final String label;
  final String description;
}

enum PressureLevel {
  warning,
  danger,
}

class PressureSignal {
  const PressureSignal({
    required this.label,
    required this.detail,
    required this.level,
  });

  final String label;
  final String detail;
  final PressureLevel level;
}
