import '../../core/constants/game_balance.dart';
import '../../features/company/data/company_catalog.dart';
import '../../features/company/models/active_company.dart';
import '../../features/conditions/models/ongoing_condition.dart';
import '../../features/education/models/active_education.dart';
import '../../features/education/models/completed_education.dart';
import '../../features/events/models/pending_event.dart';
import '../../features/events/models/scheduled_event.dart';
import '../../features/finance/models/active_debt.dart';
import '../../features/finance/models/active_deposit.dart';
import '../../features/housing/data/housing_catalog.dart';
import '../../features/housing/models/housing_option.dart';
import '../../features/jobs/models/application_result.dart';
import '../../features/jobs/models/job.dart';
import '../../features/jobs/models/work_history.dart';
import 'month_result.dart';
import 'player_state.dart';

class GameState {
  const GameState({
    required this.month,
    required this.player,
    required this.availableJobs,
    required this.jobSearchCount,
    required this.completedEducations,
    required this.currentHousing,
    required this.recentEventIds,
    required this.recentEventCategories,
    required this.scheduledEvents,
    required this.activeDebts,
    required this.activeDeposits,
    required this.completedMilestoneIds,
    required this.workHistory,
    required this.jobPerformanceScore,
    required this.activeConditions,
    this.currentJob,
    this.activeEducation,
    this.activeCompany,
    this.pendingEvent,
    this.lastApplicationResult,
    this.lastMonthResult,
  });

  final int month;
  final PlayerState player;
  final Job? currentJob;
  final List<Job> availableJobs;
  final int jobSearchCount;
  final ActiveEducation? activeEducation;
  final List<CompletedEducation> completedEducations;
  final HousingOption currentHousing;
  final PendingEvent? pendingEvent;
  final List<String> recentEventIds;
  final List<String> recentEventCategories;
  final List<ScheduledEvent> scheduledEvents;
  final List<ActiveDebt> activeDebts;
  final List<ActiveDeposit> activeDeposits;
  final List<String> completedMilestoneIds;
  final WorkHistory workHistory;
  final int jobPerformanceScore;
  final List<OngoingCondition> activeConditions;
  final ActiveCompany? activeCompany;
  final ApplicationResult? lastApplicationResult;
  final MonthResult? lastMonthResult;

  factory GameState.initial() {
    return GameState(
      month: GameBalance.startingMonth,
      player: PlayerState.initial(),
      currentJob: null,
      availableJobs: const [],
      jobSearchCount: 0,
      activeEducation: null,
      completedEducations: const [],
      currentHousing: defaultHousing(),
      pendingEvent: null,
      recentEventIds: const [],
      recentEventCategories: const [],
      scheduledEvents: const [],
      activeDebts: const [],
      activeDeposits: const [],
      completedMilestoneIds: const [],
      workHistory: WorkHistory.initial(),
      jobPerformanceScore: 58,
      activeConditions: const [],
      activeCompany: null,
    );
  }

  GameState copyWith({
    int? month,
    PlayerState? player,
    Job? currentJob,
    List<Job>? availableJobs,
    int? jobSearchCount,
    ActiveEducation? activeEducation,
    List<CompletedEducation>? completedEducations,
    HousingOption? currentHousing,
    PendingEvent? pendingEvent,
    List<String>? recentEventIds,
    List<String>? recentEventCategories,
    List<ScheduledEvent>? scheduledEvents,
    List<ActiveDebt>? activeDebts,
    List<ActiveDeposit>? activeDeposits,
    List<String>? completedMilestoneIds,
    WorkHistory? workHistory,
    int? jobPerformanceScore,
    List<OngoingCondition>? activeConditions,
    ActiveCompany? activeCompany,
    ApplicationResult? lastApplicationResult,
    MonthResult? lastMonthResult,
    bool clearCurrentJob = false,
    bool clearActiveEducation = false,
    bool clearActiveCompany = false,
    bool clearPendingEvent = false,
    bool clearLastApplicationResult = false,
    bool clearLastMonthResult = false,
  }) {
    return GameState(
      month: month ?? this.month,
      player: player ?? this.player,
      currentJob: clearCurrentJob ? null : currentJob ?? this.currentJob,
      availableJobs: availableJobs ?? this.availableJobs,
      jobSearchCount: jobSearchCount ?? this.jobSearchCount,
      activeEducation:
          clearActiveEducation ? null : activeEducation ?? this.activeEducation,
      completedEducations: completedEducations ?? this.completedEducations,
      currentHousing: currentHousing ?? this.currentHousing,
      pendingEvent: clearPendingEvent ? null : pendingEvent ?? this.pendingEvent,
      recentEventIds: recentEventIds ?? this.recentEventIds,
      recentEventCategories:
          recentEventCategories ?? this.recentEventCategories,
      scheduledEvents: scheduledEvents ?? this.scheduledEvents,
      activeDebts: activeDebts ?? this.activeDebts,
      activeDeposits: activeDeposits ?? this.activeDeposits,
      completedMilestoneIds:
          completedMilestoneIds ?? this.completedMilestoneIds,
      workHistory: workHistory ?? this.workHistory,
      jobPerformanceScore: jobPerformanceScore ?? this.jobPerformanceScore,
      activeConditions: activeConditions ?? this.activeConditions,
      activeCompany:
          clearActiveCompany ? null : activeCompany ?? this.activeCompany,
      lastApplicationResult: clearLastApplicationResult
          ? null
          : lastApplicationResult ?? this.lastApplicationResult,
      lastMonthResult:
          clearLastMonthResult ? null : lastMonthResult ?? this.lastMonthResult,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'player': player.toJson(),
      'currentJob': currentJob?.toJson(),
      'availableJobs': availableJobs.map((job) => job.toJson()).toList(),
      'jobSearchCount': jobSearchCount,
      'activeEducation': activeEducation?.toJson(),
      'completedEducations': completedEducations
          .map((record) => record.toJson())
          .toList(),
      'currentHousing': currentHousing.toJson(),
      'pendingEvent': pendingEvent?.toJson(),
      'recentEventIds': recentEventIds,
      'recentEventCategories': recentEventCategories,
      'scheduledEvents':
          scheduledEvents.map((event) => event.toJson()).toList(),
      'activeDebts': activeDebts.map((debt) => debt.toJson()).toList(),
      'activeDeposits':
          activeDeposits.map((deposit) => deposit.toJson()).toList(),
      'completedMilestoneIds': completedMilestoneIds,
      'workHistory': workHistory.toJson(),
      'jobPerformanceScore': jobPerformanceScore,
      'activeConditions':
          activeConditions.map((condition) => condition.toJson()).toList(),
      'activeCompany': activeCompany?.toJson(),
      'lastMonthResult': lastMonthResult?.toJson(),
    };
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      month: json['month'] as int? ?? GameBalance.startingMonth,
      player: PlayerState.fromJson(
        Map<String, dynamic>.from(json['player'] as Map? ?? {}),
      ),
      currentJob: json['currentJob'] == null
          ? null
          : Job.fromJson(Map<String, dynamic>.from(json['currentJob'] as Map)),
      availableJobs: (json['availableJobs'] as List? ?? [])
          .map((item) => Job.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      jobSearchCount: json['jobSearchCount'] as int? ?? 0,
      activeEducation: json['activeEducation'] == null
          ? null
          : ActiveEducation.fromJson(
              Map<String, dynamic>.from(json['activeEducation'] as Map),
            ),
      completedEducations: (json['completedEducations'] as List? ?? [])
          .map((item) =>
              CompletedEducation.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      currentHousing: json['currentHousing'] == null
          ? defaultHousing()
          : HousingOption.fromJson(
              Map<String, dynamic>.from(json['currentHousing'] as Map),
            ),
      pendingEvent: json['pendingEvent'] == null
          ? null
          : PendingEvent.fromJson(
              Map<String, dynamic>.from(json['pendingEvent'] as Map),
            ),
      recentEventIds:
          (json['recentEventIds'] as List? ?? []).map((item) => '$item').toList(),
      recentEventCategories: (json['recentEventCategories'] as List? ?? [])
          .map((item) => '$item')
          .toList(),
      scheduledEvents: (json['scheduledEvents'] as List? ?? [])
          .map((item) =>
              ScheduledEvent.fromJson(Map<String, dynamic>.from(item)))
          .where((event) => event.eventId.isNotEmpty)
          .toList(),
      activeDebts: (json['activeDebts'] as List? ?? [])
          .map((item) => ActiveDebt.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      activeDeposits: (json['activeDeposits'] as List? ?? [])
          .map((item) =>
              ActiveDeposit.fromJson(Map<String, dynamic>.from(item)))
          .toList(),
      completedMilestoneIds: (json['completedMilestoneIds'] as List? ?? [])
          .map((item) => '$item')
          .toList(),
      workHistory: WorkHistory.fromJson(
        Map<String, dynamic>.from(json['workHistory'] as Map? ?? {}),
      ),
      jobPerformanceScore: json['jobPerformanceScore'] as int? ?? 58,
      activeConditions: (json['activeConditions'] as List? ?? [])
          .map((item) =>
              OngoingCondition.fromJson(Map<String, dynamic>.from(item)))
          .where((condition) => condition.id.isNotEmpty)
          .toList(),
      activeCompany: json['activeCompany'] == null
          ? null
          : _companyFromJson(
              Map<String, dynamic>.from(json['activeCompany'] as Map),
            ),
      lastMonthResult: json['lastMonthResult'] == null
          ? null
          : MonthResult.fromJson(
              Map<String, dynamic>.from(json['lastMonthResult'] as Map),
            ),
    );
  }

  static ActiveCompany _companyFromJson(Map<String, dynamic> json) {
    final typeId = json['typeId'] as String? ?? '';
    final type = companyTypes.firstWhere(
      (item) => item.id == typeId,
      orElse: () => companyTypes.first,
    );

    return ActiveCompany(
      name: json['name'] as String? ?? '${type.title} Co.',
      type: type,
      monthsActive: json['monthsActive'] as int? ?? 0,
      health: json['health'] as int? ?? 50,
      momentum: json['momentum'] as int? ?? 35,
      pipeline: json['pipeline'] as int? ?? 38,
      operations: json['operations'] as int? ?? 52,
      effortThisMonth: json['effortThisMonth'] as int? ?? 0,
      clientFocusThisMonth: json['clientFocusThisMonth'] as int? ?? 0,
      operationsFocusThisMonth: json['operationsFocusThisMonth'] as int? ?? 0,
      lastNetResult: json['lastNetResult'] as int? ?? 0,
    );
  }
}
