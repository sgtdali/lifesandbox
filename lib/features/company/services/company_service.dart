import '../../../game/models/game_state.dart';
import '../data/company_catalog.dart';
import '../models/active_company.dart';
import '../models/company_action.dart';
import '../models/company_type.dart';
import '../../wellbeing/services/wellbeing_service.dart';
import 'company_profile_service.dart';

class CompanyService {
  const CompanyService();

  List<CompanyType> get types => companyTypes;

  List<CompanyAction> get actions => const [
        CompanyAction(
          type: CompanyActionType.workOnBusiness,
          title: 'Work on Business',
          description: 'Balanced effort across stability, pipeline, and operations.',
          energyCost: 35,
          momentum: 6,
          health: 2,
          pipeline: 4,
          operations: 4,
        ),
        CompanyAction(
          type: CompanyActionType.findClients,
          title: 'Find Clients',
          description: 'Build future pipeline, but add delivery pressure.',
          energyCost: 30,
          momentum: 5,
          pipeline: 14,
          operations: -4,
          clientFocus: 14,
        ),
        CompanyAction(
          type: CompanyActionType.improveOperations,
          title: 'Improve Operations',
          description: 'Stabilize delivery and reduce operational drag.',
          energyCost: 25,
          health: 4,
          momentum: -1,
          operations: 14,
          operationsFocus: 12,
        ),
        CompanyAction(
          type: CompanyActionType.takeItEasy,
          title: 'Take It Easy',
          description: 'Protect stability and wellbeing while growth cools.',
          energyCost: 5,
          health: 3,
          momentum: -4,
          pipeline: -3,
          operations: 5,
        ),
      ];

  bool isUnlocked(GameState state) {
    return state.month >= 8 ||
        state.completedEducations.isNotEmpty ||
        state.player.reliabilityScore >= 65;
  }

  String unlockText(GameState state) {
    if (isUnlocked(state)) return 'Company creation is unlocked.';
    return 'Unlock by reaching Month 8, completing education, or reaching Good reliability.';
  }

  bool canFound(GameState state, CompanyType type) {
    return state.activeCompany == null &&
        isUnlocked(state) &&
        state.player.cash >= type.startupCost;
  }

  GameState foundCompany(GameState state, CompanyType type) {
    if (!canFound(state, type)) return state;

    return state.copyWith(
      player: state.player.copyWith(cash: state.player.cash - type.startupCost),
      activeCompany: ActiveCompany(
        name: _defaultCompanyName(type),
        type: type,
        monthsActive: 0,
        health: 58,
        momentum: 36,
        pipeline: 36,
        operations: 52,
        effortThisMonth: 0,
        clientFocusThisMonth: 0,
        operationsFocusThisMonth: 0,
      ),
      clearLastMonthResult: true,
    );
  }

  GameState applyAction(GameState state, CompanyAction action) {
    final company = state.activeCompany;
    if (company == null) return state;
    if (state.player.stats.energy < action.energyCost) return state;

    final stats = state.player.stats.apply(
      energy: -action.energyCost,
      stress: action.type == CompanyActionType.takeItEasy ? -1 : 2,
    );

    final wellbeingPercent = const WellbeingService().companyActionPercent(state);
    final multiplier = (100 + wellbeingPercent) / 100;

    return state.copyWith(
      player: state.player.copyWith(stats: stats),
      activeCompany: company.copyWith(
        momentum: _clamp(company.momentum + (action.momentum * multiplier).round()),
        health: _clamp(company.health + (action.health * multiplier).round()),
        pipeline: _clamp(company.pipeline + (action.pipeline * multiplier).round()),
        operations:
            _clamp(company.operations + (action.operations * multiplier).round()),
        effortThisMonth: company.effortThisMonth + action.energyCost,
        clientFocusThisMonth:
            company.clientFocusThisMonth + (action.clientFocus * multiplier).round(),
        operationsFocusThisMonth:
            company.operationsFocusThisMonth +
                (action.operationsFocus * multiplier).round(),
      ),
      clearLastMonthResult: true,
    );
  }

  GameState closeCompany(GameState state) {
    if (state.activeCompany == null) return state;

    return state.copyWith(
      player: state.player.copyWith(
        stats: state.player.stats.apply(stress: 4, happiness: -3),
      ),
      clearActiveCompany: true,
      clearLastMonthResult: true,
    );
  }

  CompanyMonthResult resolveMonth(GameState state) {
    final company = state.activeCompany;
    if (company == null) {
      return const CompanyMonthResult.empty();
    }

    final type = company.type;
    final profile = const CompanyProfileService().profileFor(type);
    final seed = state.month * 41 +
        company.health * 7 +
        company.momentum * 11 +
        company.pipeline * 13 +
        company.operations * 5 +
        company.clientFocusThisMonth;
    final variance = (seed % (profile.volatility * 2 + 1)) - profile.volatility;
    final pipelineValue =
        (company.pipeline * profile.pipelineConversion).round();
    final operationsGate =
        ((company.operations - 45) / 3).round().clamp(-18, 18).toInt();
    final qualityBonus = ((company.health / 8) +
            (company.momentum * profile.momentumSensitivity / 100) +
            operationsGate)
        .round();
    final actionBonus =
        (company.clientFocusThisMonth * 0.9 + company.effortThisMonth * 0.25)
            .round();
    final conditionHealthPressure = state.activeConditions.fold<int>(
      0,
      (total, condition) => total + condition.effect.companyHealth,
    );
    final conditionMomentumPressure = state.activeConditions.fold<int>(
      0,
      (total, condition) => total + condition.effect.companyMomentum,
    );
    final deliveryStrain =
        ((company.pipeline - company.operations) / 6).round().clamp(0, 14).toInt();
    final stabilityLoss = company.operationsFocusThisMonth > 0
        ? deliveryStrain ~/ 2
        : deliveryStrain + profile.operationsDrag;
    final revenue = (type.minRevenue +
            pipelineValue +
            variance +
            qualityBonus +
            actionBonus)
        .clamp(0, type.maxRevenue + 120)
        .toInt();
    final operatingCost = type.monthlyOperatingCost + deliveryStrain;
    final net = revenue - operatingCost;

    final healthDelta = (net >= 0 ? 2 : -5) +
        (company.operationsFocusThisMonth / 5).round() -
        stabilityLoss +
        conditionHealthPressure;
    final momentumDelta = (net / 25).round() +
        (company.clientFocusThisMonth / 6).round() -
        2 +
        conditionMomentumPressure;
    final pipelineDelta = profile.pipelineBias +
        (company.clientFocusThisMonth / 4).round() -
        (revenue / 20).round() +
        (company.momentum / 30).round();
    final operationsDelta = profile.operationsBias +
        (company.operationsFocusThisMonth / 4).round() -
        deliveryStrain -
        (company.pipeline / 45).round();
    final nextHealth = _clamp(company.health + healthDelta);
    final nextMomentum = _clamp(company.momentum + momentumDelta);
    final nextPipeline = _clamp(company.pipeline + pipelineDelta);
    final nextOperations = _clamp(company.operations + operationsDelta);
    final failed = nextHealth <= 5;

    final nextCompany = failed
        ? null
        : company
            .copyWith(
              monthsActive: company.monthsActive + 1,
              health: nextHealth,
              momentum: nextMomentum,
              pipeline: nextPipeline,
              operations: nextOperations,
              lastNetResult: net,
            )
            .resetMonthlyFocus();

    return CompanyMonthResult(
      company: nextCompany,
      companyClosed: failed,
      companyName: company.name,
      revenue: revenue,
      operatingCost: operatingCost,
      net: net,
      healthDelta: nextHealth - company.health,
      momentumDelta: nextMomentum - company.momentum,
      pipelineDelta: nextPipeline - company.pipeline,
      operationsDelta: nextOperations - company.operations,
    );
  }

  CompanyType typeById(String id) {
    return companyTypes.firstWhere(
      (type) => type.id == id,
      orElse: () => companyTypes.first,
    );
  }

  String _defaultCompanyName(CompanyType type) {
    switch (type.id) {
      case 'service_agency':
        return 'Practical Service Co.';
      case 'sales_office':
        return 'Brightline Sales Office';
      case 'digital_studio':
        return 'Small Signal Studio';
      case 'operations_firm':
        return 'Steady Ops Firm';
    }
    return '${type.title} Co.';
  }

  static int _clamp(int value) => value.clamp(0, 100).toInt();
}

class CompanyMonthResult {
  const CompanyMonthResult({
    required this.company,
    required this.companyClosed,
    required this.companyName,
    required this.revenue,
    required this.operatingCost,
    required this.net,
    required this.healthDelta,
    required this.momentumDelta,
    required this.pipelineDelta,
    required this.operationsDelta,
  });

  const CompanyMonthResult.empty()
      : company = null,
        companyClosed = false,
        companyName = null,
        revenue = 0,
        operatingCost = 0,
        net = 0,
        healthDelta = 0,
        momentumDelta = 0,
        pipelineDelta = 0,
        operationsDelta = 0;

  final ActiveCompany? company;
  final bool companyClosed;
  final String? companyName;
  final int revenue;
  final int operatingCost;
  final int net;
  final int healthDelta;
  final int momentumDelta;
  final int pipelineDelta;
  final int operationsDelta;
}
