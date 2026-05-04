import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/progression/models/run_state_evaluation.dart';
import '../../../shared/widgets/status_chip.dart';

class DashboardHero extends StatelessWidget {
  const DashboardHero({
    super.key,
    required this.runState,
    required this.reliabilityLabel,
    required this.wellbeingLabel,
    required this.wellbeingColor,
  });

  final RunStateEvaluation runState;
  final String reliabilityLabel;
  final String wellbeingLabel;
  final Color wellbeingColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2. Current State Dominance
        Text(
          runState.label,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: AppTheme.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          runState.description,
          style: textTheme.bodyLarge?.copyWith(
            color: AppTheme.mutedText,
            height: 1.3,
          ),
        ),
        
        const SizedBox(height: 14),
        
        // 3. Compact Badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StatusChip(
              label: 'Reliability: $reliabilityLabel',
              color: AppTheme.primary,
              icon: Icons.shield_rounded,
            ),
            StatusChip(
              label: 'Wellbeing: $wellbeingLabel',
              color: wellbeingColor,
              icon: Icons.favorite_rounded,
            ),
          ],
        ),
      ],
    );
  }
}
