class Job {
  const Job({
    required this.id,
    required this.title,
    required this.category,
    required this.monthlySalary,
    required this.monthlyEnergyLoad,
    required this.stressImpact,
    required this.intelligenceWeight,
    required this.reliabilityWeight,
    required this.stressWeight,
    required this.readinessWeight,
    required this.accessibility,
    required this.description,
    this.isStarter = true,
    this.track = 'Starter',
    this.level = 0,
    this.jobSecurity = 60,
    this.careerValue = 1,
    this.educationTags = const [],
  });

  final String id;
  final String title;
  final String category;
  final int monthlySalary;
  final int monthlyEnergyLoad;
  final int stressImpact;
  final double intelligenceWeight;
  final double reliabilityWeight;
  final double stressWeight;
  final double readinessWeight;
  final int accessibility;
  final String description;
  final bool isStarter;
  final String track;
  final int level;
  final int jobSecurity;
  final int careerValue;
  final List<String> educationTags;

  bool get isCareer => !isStarter;

  String get layerLabel => isStarter ? 'Starter' : 'Career L$level';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'monthlySalary': monthlySalary,
      'monthlyEnergyLoad': monthlyEnergyLoad,
      'stressImpact': stressImpact,
      'intelligenceWeight': intelligenceWeight,
      'reliabilityWeight': reliabilityWeight,
      'stressWeight': stressWeight,
      'readinessWeight': readinessWeight,
      'accessibility': accessibility,
      'description': description,
      'isStarter': isStarter,
      'track': track,
      'level': level,
      'jobSecurity': jobSecurity,
      'careerValue': careerValue,
      'educationTags': educationTags,
    };
  }

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Job',
      category: json['category'] as String? ?? 'General',
      monthlySalary: json['monthlySalary'] as int? ?? 0,
      monthlyEnergyLoad: json['monthlyEnergyLoad'] as int? ?? 0,
      stressImpact: json['stressImpact'] as int? ?? 0,
      intelligenceWeight: (json['intelligenceWeight'] as num?)?.toDouble() ?? 0,
      reliabilityWeight: (json['reliabilityWeight'] as num?)?.toDouble() ?? 0,
      stressWeight: (json['stressWeight'] as num?)?.toDouble() ?? 0,
      readinessWeight: (json['readinessWeight'] as num?)?.toDouble() ?? 0,
      accessibility: json['accessibility'] as int? ?? 50,
      description: json['description'] as String? ?? '',
      isStarter: json['isStarter'] as bool? ?? true,
      track: json['track'] as String? ?? json['category'] as String? ?? 'Starter',
      level: json['level'] as int? ?? 0,
      jobSecurity: json['jobSecurity'] as int? ?? 60,
      careerValue: json['careerValue'] as int? ?? 1,
      educationTags:
          (json['educationTags'] as List? ?? []).map((item) => '$item').toList(),
    );
  }
}
