import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/progression/models/run_state_evaluation.dart';

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

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          // Large circular status icon with gradient-like look
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A2A2A),
              border: Border.all(color: AppTheme.green.withOpacity(0.3), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.green.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.trending_up_rounded,
                size: 40,
                color: AppTheme.green,
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // Title and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  runState.label,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.text,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  runState.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
