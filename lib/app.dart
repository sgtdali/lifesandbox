import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/company/services/company_service.dart';
import 'features/education/services/education_service.dart';
import 'features/events/services/event_service.dart';
import 'features/finance/services/finance_service.dart';
import 'features/housing/services/housing_service.dart';
import 'features/jobs/services/application_evaluator.dart';
import 'features/jobs/services/job_career_service.dart';
import 'features/jobs/services/job_listing_service.dart';
import 'features/progression/services/progression_service.dart';
import 'features/wellbeing/services/wellbeing_service.dart';
import 'game/services/action_service.dart';
import 'game/services/game_persistence_service.dart';
import 'game/services/month_resolver.dart';
import 'game/state/game_controller.dart';
import 'game/state/game_scope.dart';
import 'ui/app_shell.dart';

class LifeSandboxApp extends StatefulWidget {
  const LifeSandboxApp({super.key});

  @override
  State<LifeSandboxApp> createState() => _LifeSandboxAppState();
}

class _LifeSandboxAppState extends State<LifeSandboxApp> {
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController(
      actionService: const ActionService(),
      companyService: const CompanyService(),
      educationService: const EducationService(),
      eventService: const EventService(),
      financeService: const FinanceService(),
      housingService: const HousingService(),
      jobListingService: const JobListingService(),
      applicationEvaluator: const ApplicationEvaluator(),
      jobCareerService: const JobCareerService(),
      progressionService: const ProgressionService(),
      wellbeingService: const WellbeingService(),
      monthResolver: MonthResolver.foundation(),
      persistenceService: GamePersistenceService(),
    )..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameScope(
      controller: _controller,
      child: MaterialApp(
        title: 'Life Sandbox',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AppShell(),
      ),
    );
  }
}
