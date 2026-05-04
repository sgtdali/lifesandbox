import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/wellbeing_state.dart';

class WellbeingCard extends StatelessWidget {
  const WellbeingCard({
    super.key,
    required this.evaluation,
  });

  final WellbeingEvaluation evaluation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = _color(evaluation.tier);

    return Card(
      color: AppTheme.surfaceRaised,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.favorite_rounded, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(evaluation.label, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(evaluation.description, style: textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final driver in evaluation.drivers)
                        Text(driver, style: textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
