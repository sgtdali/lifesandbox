import 'action_type.dart';

class ActionDefinition {
  const ActionDefinition({
    required this.type,
    required this.title,
    required this.description,
    required this.energyCost,
    this.health = 0,
    this.happiness = 0,
    this.stress = 0,
    this.intelligence = 0,
    this.cashCost = 0,
    this.conditionId,
  });

  final ActionType type;
  final String title;
  final String description;
  final int energyCost;
  final int health;
  final int happiness;
  final int stress;
  final int intelligence;
  final int cashCost;
  final String? conditionId;
}
