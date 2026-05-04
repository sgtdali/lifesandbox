import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/metric_row.dart';
import '../../shared/widgets/status_chip.dart';
import 'models/housing_option.dart';

class HousingPage extends StatelessWidget {
  const HousingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final current = state.currentHousing;
    final textTheme = Theme.of(context).textTheme;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Housing', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Choose where you live and shape monthly pressure.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),

          _CurrentHousingCard(housing: current),
          const SizedBox(height: 22),

          Text('Housing options', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final option in controller.housingOptions) ...[
            _HousingOptionCard(
              option: option,
              isCurrent: option.id == current.id,
              canMove: controller.canMoveHousing(option),
              onMove: () async {
                final moved = await controller.moveHousing(option);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      moved
                          ? 'Moved to ${option.title}.'
                          : 'Not enough cash for the move fee.',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _CurrentHousingCard extends StatelessWidget {
  const _CurrentHousingCard({required this.housing});

  final HousingOption housing;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Current Residence',
      icon: Icons.home_rounded,
      iconColor: AppTheme.green,
      action: StatusChip(label: housing.quality, color: AppTheme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(housing.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(housing.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          MetricRow(label: 'Monthly Rent', value: '${housing.monthlyCost}', valueColor: AppTheme.red),
          MetricRow(label: 'Modifiers', value: housing.modifierSummary),
          MetricRow(label: 'Energy Recovery', value: _signed(housing.energyRecoveryModifier), valueColor: AppTheme.green),
        ],
      ),
    );
  }
}

class _HousingOptionCard extends StatelessWidget {
  const _HousingOptionCard({
    required this.option,
    required this.isCurrent,
    required this.canMove,
    required this.onMove,
  });

  final HousingOption option;
  final bool isCurrent;
  final bool canMove;
  final VoidCallback onMove;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: option.title,
      subtitle: option.description,
      action: StatusChip(label: option.quality, color: AppTheme.primary),
      child: Column(
        children: [
          MetricRow(label: 'Rent', value: '${option.monthlyCost}/mo'),
          MetricRow(label: 'Move Fee', value: isCurrent ? 'Current' : '${option.moveFee}'),
          MetricRow(label: 'Effects', value: option.modifierSummary),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isCurrent || !canMove ? null : onMove,
            child: Text(isCurrent ? 'Current Housing' : 'Move Here'),
          ),
        ],
      ),
    );
  }
}

String _signed(int value) {
  return value > 0 ? '+$value' : '$value';
}
