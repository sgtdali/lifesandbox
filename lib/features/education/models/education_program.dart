class EducationProgram {
  const EducationProgram({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.durationMonths,
    required this.monthlyCost,
    required this.monthlyStudyRequired,
    required this.intelligenceReward,
    required this.reliabilityReward,
    required this.happinessReward,
    required this.commitment,
    required this.tags,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final int durationMonths;
  final int monthlyCost;
  final int monthlyStudyRequired;
  final int intelligenceReward;
  final int reliabilityReward;
  final int happinessReward;
  final String commitment;
  final List<String> tags;

  String get rewardSummary {
    final parts = <String>[];
    if (intelligenceReward != 0) parts.add('INT +$intelligenceReward');
    if (reliabilityReward != 0) parts.add('REL +$reliabilityReward');
    if (happinessReward != 0) parts.add('HAP +$happinessReward');
    return parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'durationMonths': durationMonths,
      'monthlyCost': monthlyCost,
      'monthlyStudyRequired': monthlyStudyRequired,
      'intelligenceReward': intelligenceReward,
      'reliabilityReward': reliabilityReward,
      'happinessReward': happinessReward,
      'commitment': commitment,
      'tags': tags,
    };
  }

  factory EducationProgram.fromJson(Map<String, dynamic> json) {
    return EducationProgram(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Program',
      category: json['category'] as String? ?? 'General',
      description: json['description'] as String? ?? '',
      durationMonths: json['durationMonths'] as int? ?? 1,
      monthlyCost: json['monthlyCost'] as int? ?? 0,
      monthlyStudyRequired: json['monthlyStudyRequired'] as int? ?? 20,
      intelligenceReward: json['intelligenceReward'] as int? ?? 0,
      reliabilityReward: json['reliabilityReward'] as int? ?? 0,
      happinessReward: json['happinessReward'] as int? ?? 0,
      commitment: json['commitment'] as String? ?? 'Light',
      tags: (json['tags'] as List? ?? []).map((item) => '$item').toList(),
    );
  }
}
