class WorkHistory {
  const WorkHistory({
    required this.totalMonthsEmployed,
    required this.trackMonths,
    required this.currentJobTenure,
    required this.currentJobId,
    required this.highestCareerLevel,
  });

  final int totalMonthsEmployed;
  final Map<String, int> trackMonths;
  final int currentJobTenure;
  final String? currentJobId;
  final int highestCareerLevel;

  factory WorkHistory.initial() {
    return const WorkHistory(
      totalMonthsEmployed: 0,
      trackMonths: {},
      currentJobTenure: 0,
      currentJobId: null,
      highestCareerLevel: 0,
    );
  }

  int monthsInTrack(String track) => trackMonths[track] ?? 0;

  String get strongestTrack {
    if (trackMonths.isEmpty) return 'None';
    final entries = trackMonths.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }

  WorkHistory recordMonth({
    required String jobId,
    required String track,
    required int level,
  }) {
    final sameJob = currentJobId == jobId;
    return WorkHistory(
      totalMonthsEmployed: totalMonthsEmployed + 1,
      trackMonths: {
        ...trackMonths,
        track: monthsInTrack(track) + 1,
      },
      currentJobTenure: sameJob ? currentJobTenure + 1 : 1,
      currentJobId: jobId,
      highestCareerLevel:
          level > highestCareerLevel ? level : highestCareerLevel,
    );
  }

  WorkHistory clearCurrentJob() {
    return WorkHistory(
      totalMonthsEmployed: totalMonthsEmployed,
      trackMonths: trackMonths,
      currentJobTenure: 0,
      currentJobId: null,
      highestCareerLevel: highestCareerLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMonthsEmployed': totalMonthsEmployed,
      'trackMonths': trackMonths,
      'currentJobTenure': currentJobTenure,
      'currentJobId': currentJobId,
      'highestCareerLevel': highestCareerLevel,
    };
  }

  factory WorkHistory.fromJson(Map<String, dynamic> json) {
    return WorkHistory(
      totalMonthsEmployed: json['totalMonthsEmployed'] as int? ?? 0,
      trackMonths: (json['trackMonths'] as Map? ?? {}).map(
        (key, value) => MapEntry('$key', (value as num?)?.toInt() ?? 0),
      ),
      currentJobTenure: json['currentJobTenure'] as int? ?? 0,
      currentJobId: json['currentJobId'] as String?,
      highestCareerLevel: json['highestCareerLevel'] as int? ?? 0,
    );
  }
}

enum JobPerformanceLevel {
  poor,
  normal,
  good,
  excellent,
}

extension JobPerformanceLevelLabel on JobPerformanceLevel {
  String get label {
    switch (this) {
      case JobPerformanceLevel.poor:
        return 'Poor';
      case JobPerformanceLevel.normal:
        return 'Normal';
      case JobPerformanceLevel.good:
        return 'Good';
      case JobPerformanceLevel.excellent:
        return 'Excellent';
    }
  }
}
