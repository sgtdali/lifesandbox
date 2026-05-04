import '../../../game/models/game_state.dart';
import '../../conditions/services/condition_service.dart';
import '../../wellbeing/services/wellbeing_service.dart';
import '../models/job.dart';
import '../models/work_history.dart';

class JobCareerService {
  const JobCareerService();

  JobCareerMonthResult resolveMonth(GameState state) {
    final job = state.currentJob;
    if (job == null) {
      return JobCareerMonthResult(
        currentJob: null,
        workHistory: state.workHistory.clearCurrentJob(),
        performanceScore: state.jobPerformanceScore,
        messages: const [],
      );
    }

    final performanceScore = evaluatePerformance(state, job);
    final performance = performanceLevel(performanceScore);
    final lost = _jobLossTriggered(state, job, performanceScore);
    if (lost) {
      return JobCareerMonthResult(
        currentJob: null,
        workHistory: state.workHistory.clearCurrentJob(),
        performanceScore: performanceScore,
        messages: [
          '${job.title} was lost after poor work stability.',
          'Job performance ended the month as ${performance.label}.',
        ],
      );
    }

    return JobCareerMonthResult(
      currentJob: job,
      workHistory: state.workHistory.recordMonth(
        jobId: job.id,
        track: job.track,
        level: job.isCareer ? job.level : 0,
      ),
      performanceScore: performanceScore,
      messages: [
        'Job performance: ${performance.label}.',
        if (_readyForNextStep(state, job, performanceScore))
          'You look ready for stronger ${job.track} roles.',
      ],
    );
  }

  int evaluatePerformance(GameState state, Job job) {
    final stats = state.player.stats;
    final trackExperience = state.workHistory.monthsInTrack(job.track);
    final score = state.player.reliabilityScore * 0.36 +
        (100 - stats.stress) * 0.24 +
        stats.intelligence * 0.18 +
        stats.health * 0.12 +
        job.jobSecurity * 0.05 +
        trackExperience.clamp(0, 18) * 0.8 -
        job.level * 2.5 +
        const ConditionService().jobPerformanceModifier(state) +
        const WellbeingService().performanceModifier(state);
    return score.round().clamp(0, 100).toInt();
  }

  JobPerformanceLevel performanceLevel(int score) {
    if (score < 42) return JobPerformanceLevel.poor;
    if (score < 62) return JobPerformanceLevel.normal;
    if (score < 80) return JobPerformanceLevel.good;
    return JobPerformanceLevel.excellent;
  }

  bool isReadyForNextStep(GameState state) {
    final job = state.currentJob;
    if (job == null || job.isStarter) return false;
    return _readyForNextStep(state, job, state.jobPerformanceScore);
  }

  bool _readyForNextStep(GameState state, Job job, int performanceScore) {
    return job.isCareer &&
        job.level < 4 &&
        state.workHistory.currentJobTenure >= 4 &&
        state.workHistory.monthsInTrack(job.track) >= job.level * 4 &&
        performanceScore >= 64;
  }

  bool _jobLossTriggered(GameState state, Job job, int performanceScore) {
    if (performanceScore >= 38) return false;
    if (state.player.stats.stress < 82 && state.player.reliabilityScore >= 38) {
      return false;
    }

    final risk = (42 - performanceScore) +
        (state.player.stats.stress > 85 ? 8 : 0) +
        (state.player.reliabilityScore < 35 ? 8 : 0) -
        (job.jobSecurity / 8).round();
    final roll = _stableRoll(state.month, job.id);
    return roll < risk.clamp(4, 28);
  }

  int _stableRoll(int month, String jobId) {
    var value = month * 23;
    for (final unit in jobId.codeUnits) {
      value = (value * 31 + unit) & 0x7fffffff;
    }
    return value % 100;
  }
}

class JobCareerMonthResult {
  const JobCareerMonthResult({
    required this.currentJob,
    required this.workHistory,
    required this.performanceScore,
    required this.messages,
  });

  final Job? currentJob;
  final WorkHistory workHistory;
  final int performanceScore;
  final List<String> messages;
}
