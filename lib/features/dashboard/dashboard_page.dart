import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/conditions/widgets/conditions_snapshot.dart';
import '../../features/events/widgets/event_sheet.dart';
import '../../features/progression/models/run_state_evaluation.dart';
import '../../features/progression/widgets/progression_overview.dart';
import '../../features/wellbeing/widgets/wellbeing_card.dart';
import '../../game/state/game_scope.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/metric_row.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/warning_banner.dart';
import 'widgets/action_list.dart';
import 'widgets/month_summary_sheet.dart';
import 'widgets/stat_bar.dart';

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
          // 1. Primary Life Snapshot
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Month ${state.month}', style: textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(controller.runState.label, style: textTheme.bodyMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              StatusChip(
                label: player.reliability.label,
                color: AppTheme.primary,
                icon: Icons.shield_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2. Pressure / Warning Strip
          if (controller.pressureSignals.isNotEmpty) ...[
            for (final pressure in controller.pressureSignals.take(3)) ...[
              WarningBanner(
                title: pressure.label,
                message: pressure.detail,
                severity: pressure.level == PressureLevel.danger ? WarningSeverity.danger : WarningSeverity.warning,
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 8),
          ],

          if (pendingEvent != null) ...[
            WarningBanner(
              title: 'Pending event',
              message: pendingEvent.event.title,
              severity: WarningSeverity.info,
              icon: Icons.event_note_rounded,
              action: TextButton(
                onPressed: () => showPendingEventSheet(context, pendingEvent),
                child: const Text('Open'),
              ),
            ),
            const SizedBox(height: 18),
          ],

          // 3. Core Stats & Wellbeing
          WellbeingCard(evaluation: controller.wellbeing),
          const SizedBox(height: 14),

          AppSectionCard(
            title: 'Core Stats',
            icon: Icons.monitor_heart_rounded,
            child: Column(
              children: [
                StatBar(label: 'Health', value: stats.health, color: AppTheme.green),
                StatBar(label: 'Happiness', value: stats.happiness, color: AppTheme.amber),
                StatBar(label: 'Stress', value: stats.stress, color: AppTheme.red),
                StatBar(
                  label: 'Energy',
                  value: stats.energy,
                  maxValue: stats.maxEnergy,
                  color: AppTheme.primary,
                ),
                StatBar(
                  label: 'Intelligence',
                  value: stats.intelligence,
                  color: AppTheme.violet,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Current Commitments Snapshot
          AppSectionCard(
            title: 'Commitments',
            icon: Icons.account_balance_wallet_rounded,
            child: Column(
              children: [
                MetricRow(
                  label: 'Cash Flow',
                  value: '${player.cash}',
                  valueColor: player.cash >= 0 ? AppTheme.green : AppTheme.red,
                  icon: Icons.savings_rounded,
                ),
                MetricRow(
                  label: 'Net Month',
                  value: currentJob == null
                      ? '-${player.monthlyBaseExpense}'
                      : '+${currentJob.monthlySalary - player.monthlyBaseExpense}',
                  valueColor: (currentJob?.monthlySalary ?? 0) >= player.monthlyBaseExpense ? AppTheme.green : AppTheme.amber,
                  icon: Icons.receipt_long_rounded,
                ),
                const Divider(color: AppTheme.border, height: 24),
                MetricRow(
                  label: 'Occupation',
                  value: currentJob?.title ?? 'Unemployed',
                  icon: currentJob == null ? Icons.work_off_rounded : Icons.badge_rounded,
                ),
                MetricRow(
                  label: 'Housing',
                  value: '${housing.title} (-${housing.monthlyCost}/mo)',
                  icon: Icons.home_rounded,
                ),
                MetricRow(
                  label: 'Finance',
                  value: finance.label,
                  valueColor: finance.emergencyDebt > 0 ? AppTheme.red : AppTheme.text,
                  icon: Icons.account_balance_rounded,
                ),
                if (activeEducation != null)
                  MetricRow(
                    label: 'Education',
                    value: '${activeEducation.program.title} (${activeEducation.completedMonths}/${activeEducation.program.durationMonths})',
                    icon: Icons.school_rounded,
                  ),
                if (company != null)
                  MetricRow(
                    label: 'Company',
                    value: '${company.name} (${controller.companyOutlook})',
                    icon: Icons.business_center_rounded,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5. Conditions Snapshot
          if (state.activeConditions.isNotEmpty) ...[
            ConditionsSnapshot(conditions: state.activeConditions),
            const SizedBox(height: 14),
          ],

          // 6. Action Area
          AppSectionCard(
            title: 'Monthly Actions',
            icon: Icons.ads_click_rounded,
            action: !controller.hasMeaningfulEnergy
                ? StatusChip(label: 'Low energy', color: AppTheme.red)
                : null,
            child: ActionList(controller: controller),
          ),
          const SizedBox(height: 14),
          
          // 7. Progression
          ProgressionOverview(controller: controller),
          const SizedBox(height: 22),

          ElevatedButton.icon(
            onPressed: () async {
              final result = await controller.endMonth();
              if (!context.mounted) return;
              await showMonthSummarySheet(context, result);
              if (!context.mounted) return;
              final event = controller.state.pendingEvent;
              if (event != null) {
                await showPendingEventSheet(context, event);
              }
            },
            icon: const Icon(Icons.skip_next_rounded),
            label: const Text('End Month'),
          ),
        ],
      ),
    );
  }
}
