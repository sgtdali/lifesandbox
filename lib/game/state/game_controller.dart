import 'package:flutter/foundation.dart';

import '../../features/company/models/company_action.dart';
import '../../features/company/models/company_type.dart';
import '../../features/company/services/company_outlook_service.dart';
import '../../features/company/services/company_service.dart';
import '../../features/education/models/education_program.dart';
import '../../features/education/services/education_service.dart';
import '../../features/events/models/event_choice.dart';
import '../../features/events/models/event_resolution.dart';
import '../../features/events/services/event_service.dart';
import '../../features/finance/data/finance_products.dart';
import '../../features/finance/models/active_deposit.dart';
import '../../features/finance/models/deposit_product.dart';
import '../../features/finance/models/finance_snapshot.dart';
import '../../features/finance/models/loan_product.dart';
import '../../features/finance/services/finance_evaluator.dart';
import '../../features/finance/services/finance_service.dart';
import '../../features/housing/models/housing_option.dart';
import '../../features/housing/services/housing_service.dart';
import '../../features/jobs/models/application_result.dart';
import '../../features/jobs/models/job.dart';
import '../../features/jobs/models/suitability.dart';
import '../../features/jobs/models/work_history.dart';
import '../../features/jobs/services/application_evaluator.dart';
import '../../features/jobs/services/job_career_service.dart';
import '../../features/jobs/services/job_listing_service.dart';
import '../../features/progression/models/milestone_definition.dart';
import '../../features/progression/models/run_state_evaluation.dart';
import '../../features/progression/services/progression_service.dart';
import '../../features/wellbeing/models/wellbeing_state.dart';
import '../../features/wellbeing/services/wellbeing_service.dart';
import '../models/action_definition.dart';
import '../models/game_state.dart';
import '../models/month_result.dart';
import '../services/action_service.dart';
import '../services/game_persistence_service.dart';
import '../services/month_resolver.dart';

class GameController extends ChangeNotifier {
  GameController({
    required ActionService actionService,
    required CompanyService companyService,
    required EducationService educationService,
    required EventService eventService,
    required FinanceService financeService,
    required HousingService housingService,
    required JobListingService jobListingService,
    required ApplicationEvaluator applicationEvaluator,
    required JobCareerService jobCareerService,
    required ProgressionService progressionService,
    required WellbeingService wellbeingService,
    required MonthResolver monthResolver,
    required GamePersistenceService persistenceService,
  })  : _actionService = actionService,
        _companyService = companyService,
        _educationService = educationService,
        _eventService = eventService,
        _financeService = financeService,
        _housingService = housingService,
        _jobListingService = jobListingService,
        _applicationEvaluator = applicationEvaluator,
        _jobCareerService = jobCareerService,
        _progressionService = progressionService,
        _wellbeingService = wellbeingService,
        _monthResolver = monthResolver,
        _persistenceService = persistenceService;

  final ActionService _actionService;
  final CompanyService _companyService;
  final EducationService _educationService;
  final EventService _eventService;
  final FinanceService _financeService;
  final HousingService _housingService;
  final JobListingService _jobListingService;
  final ApplicationEvaluator _applicationEvaluator;
  final JobCareerService _jobCareerService;
  final ProgressionService _progressionService;
  final WellbeingService _wellbeingService;
  final MonthResolver _monthResolver;
  final GamePersistenceService _persistenceService;

  GameState _state = GameState.initial();
  bool _isLoading = true;

  GameState get state => _state;
  bool get isLoading => _isLoading;
  List<ActionDefinition> get actions => _actionService.availableActions;
  List<CompanyType> get companyTypes => _companyService.types;
  List<CompanyAction> get companyActions => _companyService.actions;
  int get jobSearchEnergyCost => JobListingService.searchEnergyCost;
  int get educationStudyEnergyCost => EducationService.studyEnergyCost;
  List<EducationProgram> get educationPrograms => _educationService.programs;
  List<LoanProduct> get loanProducts => _financeService.loans;
  List<DepositProduct> get depositProducts => _financeService.deposits;
  List<int> get depositAmounts => depositQuickAmounts;
  List<HousingOption> get housingOptions => _housingService.options;
  FinanceSnapshot get financeSnapshot {
    return const FinanceEvaluator().evaluate(_state);
  }
  List<MilestoneView> get milestones => _progressionService.milestonesFor(_state);
  RunStateEvaluation get runState => _progressionService.evaluateRunState(_state);
  List<String> get guidance => _progressionService.guidanceFor(_state);
  List<PressureSignal> get pressureSignals {
    return _progressionService.pressureSignalsFor(_state);
  }
  WellbeingEvaluation get wellbeing => _wellbeingService.evaluate(_state);
  JobPerformanceLevel get jobPerformance {
    return _jobCareerService.performanceLevel(_state.jobPerformanceScore);
  }
  bool get isReadyForNextCareerStep => _jobCareerService.isReadyForNextStep(_state);
  String get companyOutlook {
    final company = _state.activeCompany;
    return company == null
        ? 'No company'
        : const CompanyOutlookService().labelFor(company);
  }

  List<String> get companySignals {
    final company = _state.activeCompany;
    return company == null
        ? const []
        : const CompanyOutlookService().signalsFor(company);
  }

  bool get hasMeaningfulEnergy {
    return _actionService.hasMeaningfulEnergy(_state.player);
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _state = _progressionService.syncMilestones(
      await _persistenceService.load() ?? GameState.initial(),
    );
    if (_state.availableJobs.isEmpty) {
      _state = _state.copyWith(
        availableJobs: _jobListingService.generateListings(
          month: _state.month,
          refreshCount: _state.jobSearchCount,
          state: _state,
        ),
      );
    }
    await _persistenceService.save(_state);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> performAction(ActionDefinition action) async {
    final updatedState = _actionService.applyAction(_state, action);
    if (identical(updatedState, _state)) return;

    await _setState(updatedState);
  }

  Future<MonthResult> endMonth() async {
    final resolution = _monthResolver.resolve(_state);
    var nextState = resolution.state;
    final eventGeneration = _eventService.generateMonthlyEvent(nextState);
    nextState = eventGeneration.state;
    final pendingEvent = eventGeneration.pendingEvent;
    if (pendingEvent != null) {
      nextState = nextState.copyWith(pendingEvent: pendingEvent);
    }

    await _setState(nextState);
    return resolution.result;
  }

  Future<EventResolution> resolvePendingEvent(EventChoice choice) async {
    final result = _eventService.resolveChoice(state: _state, choice: choice);
    await _setState(result.state);
    return result.resolution;
  }

  Future<bool> refreshJobListings() async {
    final energy = _state.player.stats.energy;
    if (energy < JobListingService.searchEnergyCost) return false;

    final nextRefreshCount = _state.jobSearchCount + 1;
    final updatedStats = _state.player.stats.apply(
      energy: -JobListingService.searchEnergyCost,
      stress: 1,
    );

    await _setState(_state.copyWith(
      player: _state.player.copyWith(stats: updatedStats),
      availableJobs: _jobListingService.generateListings(
        month: _state.month,
        refreshCount: nextRefreshCount,
        state: _state,
      ),
      jobSearchCount: nextRefreshCount,
      clearLastApplicationResult: true,
      clearLastMonthResult: true,
    ));
    return true;
  }

  Future<ApplicationResult> applyToJob(Job job) async {
    final result = _applicationEvaluator.evaluate(state: _state, job: job);

    if (result.accepted) {
      await _setState(_state.copyWith(
        currentJob: job,
        player: _state.player.copyWith(occupation: job.title),
        workHistory: _state.workHistory.clearCurrentJob(),
        availableJobs:
            _state.availableJobs.where((listing) => listing.id != job.id).toList(),
        lastApplicationResult: result,
        clearLastMonthResult: true,
      ));
    } else {
      await _setState(_state.copyWith(
        lastApplicationResult: result,
        clearLastMonthResult: true,
      ));
    }

    return result;
  }

  SuitabilityPreview suitabilityFor(Job job) {
    return _applicationEvaluator.preview(state: _state, job: job);
  }

  Future<bool> startEducation(EducationProgram program) async {
    final updatedState = _educationService.startProgram(_state, program);
    if (identical(updatedState, _state)) return false;

    await _setState(updatedState);
    return true;
  }

  Future<bool> studyEducation() async {
    final updatedState = _educationService.study(_state);
    if (identical(updatedState, _state)) return false;

    await _setState(updatedState);
    return true;
  }

  Future<void> cancelEducation() async {
    await _setState(_educationService.cancelProgram(_state));
  }

  bool canStartEducation(EducationProgram program) {
    return _educationService.canStart(_state, program);
  }

  Future<bool> moveHousing(HousingOption option) async {
    final updatedState = _housingService.moveTo(_state, option);
    if (identical(updatedState, _state)) return false;

    await _setState(updatedState);
    return true;
  }

  bool canMoveHousing(HousingOption option) {
    return _housingService.canMoveTo(_state, option);
  }

  Future<void> takeLoan(LoanProduct product) async {
    await _setState(_financeService.takeLoan(_state, product));
  }

  Future<bool> payDownDebt(int amount) async {
    final updatedState = _financeService.payDownDebt(_state, amount);
    if (identical(updatedState, _state)) return false;

    await _setState(updatedState);
    return true;
  }

  Future<bool> openDeposit(DepositProduct product, int amount) async {
    final updatedState = _financeService.openDeposit(
      state: _state,
      product: product,
      amount: amount,
    );
    if (identical(updatedState, _state)) return false;

    await _setState(updatedState);
    return true;
  }

  Future<bool> withdrawDeposit(ActiveDeposit deposit) async {
    final updatedState = _financeService.withdrawDeposit(_state, deposit);
    if (identical(updatedState, _state)) return false;

    await _setState(updatedState);
    return true;
  }

  bool isCompanyUnlocked() {
    return _companyService.isUnlocked(_state);
  }

  String companyUnlockText() {
    return _companyService.unlockText(_state);
  }

  bool canFoundCompany(CompanyType type) {
    return _companyService.canFound(_state, type);
  }

  Future<bool> foundCompany(CompanyType type) async {
    final updatedState = _companyService.foundCompany(_state, type);
    if (identical(updatedState, _state)) return false;

    await _setState(updatedState);
    return true;
  }

  Future<bool> performCompanyAction(CompanyAction action) async {
    final updatedState = _companyService.applyAction(_state, action);
    if (identical(updatedState, _state)) return false;

    await _setState(updatedState);
    return true;
  }

  Future<void> closeCompany() async {
    await _setState(_companyService.closeCompany(_state));
  }

  Future<void> resetGame() async {
    _state = GameState.initial();
    _state = _state.copyWith(
      availableJobs: _jobListingService.generateListings(
        month: _state.month,
        refreshCount: _state.jobSearchCount,
        state: _state,
      ),
    );
    _state = _progressionService.syncMilestones(_state);
    notifyListeners();
    await _persistenceService.clear();
    await _persistenceService.save(_state);
  }

  bool canPerform(ActionDefinition action) {
    return _actionService.canAfford(_state, action);
  }

  Future<void> _setState(GameState state) async {
    _state = _progressionService.syncMilestones(state);
    notifyListeners();
    await _persistenceService.save(_state);
  }
}
