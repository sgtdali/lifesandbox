import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/wellbeing_state.dart';

class WellbeingCard extends StatelessWidget {
  const WellbeingCard({
    super.key,
    required this.evaluation,
  });

  final WellbeingEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final color = _color(evaluation.tier);

    return AppSectionCard(
      title: 'Wellbeing',
      subtitle: evaluation.description,
      icon: Icons.favorite_rounded,
      iconColor: color,
      action: StatusChip(label: evaluation.label, color: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final driver in evaluation.drivers)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceRaised,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(driver, style: Theme.of(context).textTheme.bodyMedium),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _color(WellbeingTier tier) {
    switch (tier) {
      case WellbeingTier.thriving:
        return AppTheme.green;
      case WellbeingTier.stable:
        return AppTheme.primary;
      case WellbeingTier.strained:
        return AppTheme.amber;
      case WellbeingTier.drained:
      case WellbeingTier.burnoutRisk:
        return AppTheme.red;
    }
  }
}
