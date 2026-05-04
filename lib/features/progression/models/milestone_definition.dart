import '../../../game/models/game_state.dart';

typedef MilestoneCondition = bool Function(GameState state);

enum MilestoneStage {
  early,
  stable,
  growth,
  business,
}

class MilestoneDefinition {
  const MilestoneDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.stage,
    required this.isComplete,
  });

  final String id;
  final String title;
  final String description;
  final MilestoneStage stage;
  final MilestoneCondition isComplete;
}

class MilestoneView {
  const MilestoneView({
    required this.definition,
    required this.completed,
  });

  final MilestoneDefinition definition;
  final bool completed;
}
