import '../../../game/models/game_state.dart';
import '../models/application_result.dart';
import '../models/job.dart';
import '../models/suitability.dart';

class ApplicationEvaluator {
  const ApplicationEvaluator();

  SuitabilityPreview preview({
    required GameState state,
    required Job job,
  }) {
    final stats = state.player.stats;
    final reliability = state.player.reliabilityScore;
    final lowStress = 100 - stats.stress;
    final readiness =
        ((stats.health + stats.happiness + stats.energy) / 3).round();
    final educationBonus = _educationBonus(state, job);
    final experienceBonus = _experienceBonus(state, job);
    final transitionBonus = _transitionBonus(state, job);
    final levelPenalty = _levelPenalty(state, job);

    final rawScore = stats.intelligence * job.intelligenceWeight +
        reliability * job.reliabilityWeight +
        lowStress * job.stressWeight +
        readiness * job.readinessWeight +
        job.accessibility * 0.32 +
        educationBonus +
        experienceBonus +
        transitionBonus -
        levelPenalty;
    final score = rawScore.round();
    final threshold = job.isStarter ? 54 : 62 + (job.level - 1) * 5;
    final level = _levelFor(score, threshold);

    return SuitabilityPreview(
      score: score,
      threshold: threshold,
      level: level,
      reasons: _reasons(
        state: state,
        job: job,
        educationBonus: educationBonus,
        experienceBonus: experienceBonus,
        transitionBonus: transitionBonus,
        levelPenalty: levelPenalty,
      ),
    );
  }

  ApplicationResult evaluate({
    required GameState state,
    required Job job,
  }) {
    final suitability = preview(state: state, job: job);
    if (!suitability.level.canApply) {
      return ApplicationResult(
        job: job,
        accepted: false,
        score: suitability.score,
        threshold: suitability.threshold,
        message: 'Low Fit. Build experience or education before applying.',
      );
    }

    final variance = _variance(state.month, job.id);
    final score = suitability.score + variance;
    final threshold = suitability.threshold;
    final accepted = score >= threshold;

    return ApplicationResult(
      job: job,
      accepted: accepted,
      score: score,
      threshold: threshold,
      message: accepted
          ? 'Accepted. You start as ${job.title}.'
          : 'Rejected. The employer chose another candidate.',
    );
  }

  int _variance(int month, String jobId) {
    var value = month * 19;
    for (final unit in jobId.codeUnits) {
      value = (value * 29 + unit) & 0x7fffffff;
    }
    return (value % 19) - 8;
  }

  int _educationBonus(GameState state, Job job) {
    final tags = job.educationTags.map((tag) => tag.toLowerCase()).toSet();
    final category = job.category.toLowerCase();

    for (final record in state.completedEducations) {
      final recordTags = record.tags.map((tag) => tag.toLowerCase()).toSet();
      if (recordTags.contains(category) ||
          recordTags.any((tag) => tags.contains(tag))) {
        return job.isStarter ? 5 : 10;
      }
    }

    return 0;
  }

  int _experienceBonus(GameState state, Job job) {
    final history = state.workHistory;
    final trackMonths = history.monthsInTrack(job.track);
    final total = history.totalMonthsEmployed;
    final trackBonus = (trackMonths * 2).clamp(0, job.isStarter ? 8 : 24).toInt();
    final totalBonus = (total / 3).floor().clamp(0, 10).toInt();
    return trackBonus + totalBonus;
  }

  int _transitionBonus(GameState state, Job job) {
    final current = state.currentJob;
    if (current == null) return job.isStarter ? 4 : 0;
    if (current.track == job.track) return job.isStarter ? 2 : 10;
    final hasRelevantEducation = _educationBonus(state, job) > 0;
    if (hasRelevantEducation && state.player.stats.intelligence >= 58) return 3;
    return job.isCareer ? -8 : 0;
  }

  int _levelPenalty(GameState state, Job job) {
    if (job.isStarter) return 0;
    final currentLevel = state.currentJob?.level ?? 0;
    final historyLevel = state.workHistory.highestCareerLevel;
    final reachableLevel = currentLevel > historyLevel ? currentLevel : historyLevel;
    final jump = job.level - reachableLevel - 1;
    return jump > 0 ? jump * 12 : 0;
  }

  SuitabilityLevel _levelFor(int score, int threshold) {
    if (score < threshold - 12) return SuitabilityLevel.lowFit;
    if (score < threshold) return SuitabilityLevel.risky;
    if (score < threshold + 16) return SuitabilityLevel.fit;
    return SuitabilityLevel.strongFit;
  }

  List<String> _reasons({
    required GameState state,
    required Job job,
    required int educationBonus,
    required int experienceBonus,
    required int transitionBonus,
    required int levelPenalty,
  }) {
    final reasons = <String>[];
    if (experienceBonus >= 12) reasons.add('Relevant experience');
    if (educationBonus > 0) reasons.add('Helpful education');
    if (transitionBonus >= 8) reasons.add('Same-track progression');
    if (transitionBonus < 0) reasons.add('Cross-track jump');
    if (levelPenalty > 0) reasons.add('Aspirational level');
    if (state.player.reliabilityScore < 45) reasons.add('Low reliability');
    if (state.player.stats.stress > 70) reasons.add('High stress');
    if (state.workHistory.totalMonthsEmployed >= 8) {
      reasons.add('Strong work stability');
    }
    if (reasons.isEmpty) reasons.add(job.isStarter ? 'Accessible starter role' : 'Career track role');
    return reasons.take(2).toList();
  }
}
