class CompletedEducation {
  const CompletedEducation({
    required this.programId,
    required this.title,
    required this.completedOnMonth,
    required this.tags,
  });

  final String programId;
  final String title;
  final int completedOnMonth;
  final List<String> tags;

  Map<String, dynamic> toJson() {
    return {
      'programId': programId,
      'title': title,
      'completedOnMonth': completedOnMonth,
      'tags': tags,
    };
  }

  factory CompletedEducation.fromJson(Map<String, dynamic> json) {
    return CompletedEducation(
      programId: json['programId'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown Program',
      completedOnMonth: json['completedOnMonth'] as int? ?? 1,
      tags: (json['tags'] as List? ?? []).map((item) => '$item').toList(),
    );
  }
}
