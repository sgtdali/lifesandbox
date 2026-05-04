class CompanyProfile {
  const CompanyProfile({
    required this.pipelineBias,
    required this.operationsBias,
    required this.volatility,
    required this.momentumSensitivity,
    required this.pipelineConversion,
    required this.operationsDrag,
    required this.summary,
  });

  final int pipelineBias;
  final int operationsBias;
  final int volatility;
  final int momentumSensitivity;
  final double pipelineConversion;
  final int operationsDrag;
  final String summary;
}
