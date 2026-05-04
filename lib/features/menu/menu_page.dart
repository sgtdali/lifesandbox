import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Game Menu', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Local save tools for foundation testing.', style: textTheme.bodyMedium),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current save', style: textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Text('Month ${state.month}', style: textTheme.bodyMedium),
                  Text('Cash ${state.player.cash}', style: textTheme.bodyMedium),
                  Text(
                    'Job ${state.currentJob?.title ?? 'Unemployed'}',
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    'Education ${state.activeEducation?.program.title ?? 'None'}',
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    'Housing ${state.currentHousing.title}',
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    'Pending event ${state.pendingEvent?.event.title ?? 'None'}',
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    'Active debts ${state.activeDebts.length}',
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    'Active deposits ${state.activeDeposits.length}',
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    'Company ${state.activeCompany?.name ?? 'None'}',
                    style: textTheme.bodyMedium,
                  ),
                  Text(
                    'Completed education ${state.completedEducations.length}',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
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
