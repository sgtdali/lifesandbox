import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/conditions/widgets/conditions_snapshot.dart';
import '../../features/events/widgets/event_sheet.dart';
import '../../features/progression/models/run_state_evaluation.dart';
import '../../features/progression/widgets/progression_overview.dart';
import '../../features/wellbeing/models/wellbeing_state.dart';
import '../../game/state/game_scope.dart';
import '../../shared/widgets/warning_banner.dart';
import 'widgets/dashboard_hero.dart';
import 'widgets/commitments_summary.dart';
import 'widgets/action_decision_area.dart';
import 'widgets/end_month_support.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final player = state.player;
    final stats = player.stats;
    final currentJob = state.currentJob;
    final activeEducation = state.activeEducation;
    final housing = state.currentHousing;
    final pendingEvent = state.pendingEvent;
    final company = state.activeCompany;
    final finance = controller.financeSnapshot;
    final textTheme = Theme.of(context).textTheme;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Header
          DashboardHero(
            month: state.month,
            runState: controller.runState,
            reliabilityLabel: player.reliability.label,
            wellbeingLabel: controller.wellbeing.label,
            wellbeingColor: controller.wellbeing.tier == WellbeingTier.thriving
                ? AppTheme.green
                : (controller.wellbeing.tier == WellbeingTier.strained
                    ? AppTheme.amber
                    : AppTheme.red),
            cash: player.cash,
            stats: stats,
          ),
          const SizedBox(height: 18),

          // 2. Guidance & Warnings (Decision Support Brain)
          if (pendingEvent != null) ...[
            WarningBanner(
              title: 'Pending event',
              message: pendingEvent.event.title,
              severity: WarningSeverity.info,
              icon: Icons.event_note_rounded,
              action: TextButton(
                onPressed: () => showPendingEventSheet(context, pendingEvent),
                child: const Text('OPEN'),
              ),
            ),
            const SizedBox(height: 18),
          ],

          // 3. (Redundant section removed)
          const SizedBox(height: 4),

          // 4. Commitments summary
          CommitmentsSummary(
            state: state,
            finance: finance,
            companyOutlook: controller.companyOutlook,
          ),
          const SizedBox(height: 14),

          // 5. Conditions Snapshot
          if (state.activeConditions.isNotEmpty) ...[
            ConditionsSnapshot(conditions: state.activeConditions),
            const SizedBox(height: 14),
          ],

          // 6. Action Area (Prioritized)
          ActionDecisionArea(controller: controller),
          const SizedBox(height: 20),
          
          // 7. Progression (Milestones)
          ProgressionOverview(controller: controller),
          const SizedBox(height: 24),

          // 8. End Month Area
          EndMonthSupport(controller: controller),
        ],
      ),
    );
  }
}
