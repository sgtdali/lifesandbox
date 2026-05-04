class CompanyType {
  const CompanyType({
    required this.id,
    required this.title,
    required this.description,
    required this.startupCost,
    required this.monthlyOperatingCost,
    required this.minRevenue,
    required this.maxRevenue,
    required this.risk,
    required this.tags,
  });

  final String id;
  final String title;
  final String description;
  final int startupCost;
  final int monthlyOperatingCost;
  final int minRevenue;
  final int maxRevenue;
  final String risk;
  final List<String> tags;
}
