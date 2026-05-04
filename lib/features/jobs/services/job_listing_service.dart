import '../../../game/models/game_state.dart';
import '../data/career_jobs.dart';
import '../data/starter_jobs.dart';
import '../models/job.dart';

class JobListingService {
  const JobListingService();

  static const searchEnergyCost = 20;

  List<Job> generateListings({
    required int month,
    required int refreshCount,
    GameState? state,
    int count = 4,
  }) {
    final maxLevel = _maxVisibleCareerLevel(state, month);
    final starterPool = [...starterJobs];
    final careerPool = [
      ...careerJobs.where((job) => job.level <= maxLevel),
    ];
    final seed = month * 37 + refreshCount * 17;

    int compare(Job a, Job b) {
      final aScore = _stableScore(a.id, seed);
      final bScore = _stableScore(b.id, seed);
      return aScore.compareTo(bScore);
    }

    starterPool.sort(compare);
    careerPool.sort(compare);

    if (state == null) return starterPool.take(count).toList();
    return [
      ...starterPool.take(2),
      ...careerPool.take(3),
    ].take(5).toList();
  }

  int _stableScore(String id, int seed) {
    var value = seed;
    for (final unit in id.codeUnits) {
      value = (value * 31 + unit) & 0x7fffffff;
    }
    return value;
  }

  int _maxVisibleCareerLevel(GameState? state, int month) {
    if (state == null) return 1;
    final currentLevel = state.currentJob?.level ?? 0;
    final historyLevel = state.workHistory.highestCareerLevel;
    final base = currentLevel > historyLevel ? currentLevel : historyLevel;
    final progressionLevel = month >= 12 ? 3 : month >= 6 ? 2 : 1;
    final educationLift = state.completedEducations.isNotEmpty ? 1 : 0;
    return (base + 1 + educationLift)
        .clamp(1, progressionLevel + educationLift)
        .toInt()
        .clamp(1, 4)
        .toInt();
  }
}
