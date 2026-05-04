import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';
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
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: AppTheme.surfaceRaised,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.home_rounded, color: AppTheme.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(housing.title, style: textTheme.titleLarge),
                ),
                _QualityPill(label: housing.quality),
              ],
            ),
            const SizedBox(height: 10),
            Text(housing.description, style: textTheme.bodyMedium),
            const SizedBox(height: 14),
            _HousingMetric(label: 'Monthly rent', value: '${housing.monthlyCost}'),
            _HousingMetric(label: 'Modifiers', value: housing.modifierSummary),
            _HousingMetric(
              label: 'Energy recovery',
              value: _signed(housing.energyRecoveryModifier),
            ),
          ],
        ),
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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(option.title, style: textTheme.titleMedium)),
                const SizedBox(width: 10),
                _QualityPill(label: option.quality),
              ],
            ),
            const SizedBox(height: 8),
            Text(option.description, style: textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _HousingMetric(
                    label: 'Rent',
                    value: '${option.monthlyCost}/mo',
                  ),
                ),
                Expanded(
                  child: _HousingMetric(
                    label: 'Move fee',
                    value: isCurrent ? 'Current' : '${option.moveFee}',
                  ),
                ),
              ],
            ),
            _HousingMetric(label: 'Monthly effects', value: option.modifierSummary),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isCurrent || !canMove ? null : onMove,
              child: Text(isCurrent ? 'Current Housing' : 'Move Here'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HousingMetric extends StatelessWidget {
  const _HousingMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _QualityPill extends StatelessWidget {
  const _QualityPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.primary,
            ),
      ),
    );
  }
}

String _signed(int value) {
  return value > 0 ? '+$value' : '$value';
}
