import 'job.dart';

class ApplicationResult {
  const ApplicationResult({
    required this.job,
    required this.accepted,
    required this.score,
    required this.threshold,
    required this.message,
  });

  final Job job;
  final bool accepted;
  final int score;
  final int threshold;
  final String message;
}
