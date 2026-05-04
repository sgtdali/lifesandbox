enum CompanyActionType {
  workOnBusiness,
  findClients,
  improveOperations,
  takeItEasy,
}

class CompanyAction {
  const CompanyAction({
    required this.type,
    required this.title,
    required this.description,
    required this.energyCost,
    this.momentum = 0,
    this.health = 0,
    this.pipeline = 0,
    this.operations = 0,
    this.clientFocus = 0,
    this.operationsFocus = 0,
  });

  final CompanyActionType type;
  final String title;
  final String description;
  final int energyCost;
  final int momentum;
  final int health;
  final int pipeline;
  final int operations;
  final int clientFocus;
  final int operationsFocus;
}
