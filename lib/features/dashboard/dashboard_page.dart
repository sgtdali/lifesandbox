import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../features/conditions/widgets/conditions_snapshot.dart';
import '../../features/events/widgets/event_sheet.dart';
import '../../features/progression/widgets/progression_overview.dart';
import '../../features/wellbeing/widgets/wellbeing_card.dart';
import '../../game/state/game_scope.dart';
import 'widgets/action_list.dart';
import 'widgets/month_summary_sheet.dart';
import 'widgets/stat_bar.dart';
import 'widgets/status_card.dart';

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
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Month ${state.month}', style: textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text('Life control center', style: textTheme.bodyMedium),
                  ],
                ),
              ),
              _StatusPill(label: player.reliability.label),
            ],
          ),
          const SizedBox(height: 18),
          if (pendingEvent != null) ...[
            Card(
              color: AppTheme.surfaceRaised,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.event_note_rounded, color: AppTheme.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pending event', style: textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(pendingEvent.event.title, style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => showPendingEventSheet(
                        context,
                        pendingEvent,
                      ),
                      child: const Text('Open'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          ProgressionOverview(controller: controller),
          const SizedBox(height: 14),
          WellbeingCard(evaluation: controller.wellbeing),
          const SizedBox(height: 14),
          ConditionsSnapshot(conditions: state.activeConditions),
          if (state.activeConditions.isNotEmpty) const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: StatusCard(
                  label: 'Cash',
                  value: '${player.cash}',
                  icon: Icons.savings_rounded,
                  color: player.cash >= 0 ? AppTheme.green : AppTheme.red,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: StatusCard(
                  label: 'Occupation',
                  value: currentJob?.title ?? 'Unemployed',
                  icon: currentJob == null
                      ? Icons.work_off_rounded
                      : Icons.badge_rounded,
                  color: currentJob == null ? AppTheme.amber : AppTheme.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          StatusCard(
            label: currentJob == null
                ? 'Personal expense'
                : 'Job salary / load',
            value: currentJob == null
                ? '${player.monthlyBaseExpense}'
                : '+${currentJob.monthlySalary} / -${currentJob.monthlyEnergyLoad} EN',
            icon: currentJob == null
                ? Icons.receipt_long_rounded
                : Icons.payments_rounded,
            color: currentJob == null ? AppTheme.violet : AppTheme.primary,
          ),
          const SizedBox(height: 10),
          StatusCard(
            label: 'Housing',
            value: '${housing.title} - ${housing.monthlyCost}/mo',
            icon: Icons.home_rounded,
            color: AppTheme.green,
          ),
          const SizedBox(height: 10),
          StatusCard(
            label: 'Finance',
            value:
                '${finance.label} - Debt ${finance.totalDebt} / Deposits ${finance.totalDeposits}',
            icon: Icons.account_balance_rounded,
            color: finance.emergencyDebt > 0
                ? AppTheme.red
                : finance.totalDebt > 0
                    ? AppTheme.amber
                    : AppTheme.primary,
          ),
          if (company != null) ...[
            const SizedBox(height: 10),
            StatusCard(
              label: 'Company',
              value:
                  '${company.name} - ${controller.companyOutlook} / Net ${company.lastNetResult}',
              icon: Icons.business_center_rounded,
              color: AppTheme.amber,
            ),
          ],
          if (activeEducation != null) ...[
            const SizedBox(height: 10),
            StatusCard(
              label: 'Education',
              value:
                  '${activeEducation.program.title} - ${activeEducation.completedMonths}/${activeEducation.program.durationMonths}',
              icon: Icons.school_rounded,
              color: AppTheme.violet,
            ),
          ],
          const SizedBox(height: 22),
          Text('Core stats', style: textTheme.titleLarge),
          const SizedBox(height: 12),
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
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: Text('Monthly actions', style: textTheme.titleLarge)),
              if (!controller.hasMeaningfulEnergy)
                Text('Low energy', style: textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 12),
          ActionList(controller: controller),
          const SizedBox(height: 14),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        'Reliability: $label',
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }
}
