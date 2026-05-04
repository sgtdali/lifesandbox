import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/metric_row.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Game Menu', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Local save tools for foundation testing.', style: textTheme.bodyMedium),
          const SizedBox(height: 18),
          
          AppSectionCard(
            title: 'Current Save State',
            icon: Icons.save_rounded,
            iconColor: AppTheme.primary,
            child: Column(
              children: [
                MetricRow(label: 'Month', value: '${state.month}'),
                MetricRow(label: 'Cash', value: '${state.player.cash}'),
                MetricRow(label: 'Job', value: state.currentJob?.title ?? 'Unemployed'),
                MetricRow(label: 'Education', value: state.activeEducation?.program.title ?? 'None'),
                MetricRow(label: 'Housing', value: state.currentHousing.title),
                MetricRow(label: 'Pending Event', value: state.pendingEvent?.event.title ?? 'None'),
                MetricRow(label: 'Active Debts', value: '${state.activeDebts.length}'),
                MetricRow(label: 'Active Deposits', value: '${state.activeDeposits.length}'),
                MetricRow(label: 'Company', value: state.activeCompany?.name ?? 'None'),
                MetricRow(label: 'Completed Education', value: '${state.completedEducations.length}'),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await controller.resetGame();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New game started.')),
              );
            },
            icon: const Icon(Icons.restart_alt_rounded, color: AppTheme.red),
            label: const Text('Reset / New Game'),
          ),
        ],
      ),
    );
  }
}
