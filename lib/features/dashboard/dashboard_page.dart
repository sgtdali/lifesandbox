import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/conditions/widgets/conditions_snapshot.dart';
import '../../features/events/widgets/event_sheet.dart';
import '../../features/progression/models/run_state_evaluation.dart';
import '../../features/progression/widgets/progression_overview.dart';
import '../../features/wellbeing/models/wellbeing_state.dart';
import '../../game/state/game_scope.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/warning_banner.dart';
import 'widgets/dashboard_hero.dart';
import 'widgets/commitments_summary.dart';
import 'widgets/action_decision_area.dart';
import 'widgets/critical_snapshot_card.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/end_month_support.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final player = state.player;
    final stats = player.stats;
    final pendingEvent = state.pendingEvent;
    final finance = controller.financeSnapshot;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Header
          DashboardHero(
            runState: controller.runState,
            reliabilityLabel: player.reliability.label,
            wellbeingLabel: controller.wellbeing.label,
            wellbeingColor: controller.wellbeing.tier == WellbeingTier.thriving
                ? AppTheme.green
                : (controller.wellbeing.tier == WellbeingTier.strained
                    ? AppTheme.amber
                    : AppTheme.red),
          ),
          
          // 2. Guidance & Warnings (Recommendation Card)
          RecommendationCard(
            recommendations: controller.guidance,
            onTap: () {
              // Maybe show a detail sheet if clicked
            },
          ),
          
          if (pendingEvent != null) ...[
            const SizedBox(height: 8),
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
          ],
          const SizedBox(height: 16),

          // 3. Two Column Stats Area
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CriticalSnapshotCard(
                  stats: stats,
                  wellbeingLabel: controller.wellbeing.label,
                  wellbeingColor: controller.wellbeing.tier == WellbeingTier.thriving
                      ? AppTheme.green
                      : (controller.wellbeing.tier == WellbeingTier.strained
                          ? AppTheme.amber
                          : AppTheme.red),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: CommitmentsSummary(
                  state: state,
                  finance: finance,
                  companyOutlook: controller.companyOutlook,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Action Area (Prioritized)
          ActionDecisionArea(controller: controller),
          const SizedBox(height: 16),
          
          // 5. Two Column Bottom Area (Conditions & Milestones)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: state.activeConditions.isNotEmpty 
                    ? ConditionsSnapshot(conditions: state.activeConditions)
                    : AppSectionCard(title: 'CONDITIONS', child: const Text('No active conditions.')),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ProgressionOverview(controller: controller),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 6. End Month Area
          EndMonthSupport(controller: controller),
        ],
      ),
    );
  }
}
