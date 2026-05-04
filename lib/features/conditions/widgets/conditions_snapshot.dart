import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/ongoing_condition.dart';

class ConditionsSnapshot extends StatelessWidget {
  const ConditionsSnapshot({
    super.key,
    required this.conditions,
  });

  final List<OngoingCondition> conditions;

  @override
  Widget build(BuildContext context) {
    if (conditions.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ongoing conditions', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final condition in conditions.take(4))
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome_motion_rounded,
                      color: _toneColor(condition.tone),
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  condition.title,
                                  style: textTheme.labelLarge,
                                ),
                              ),
                              Text(
                                '${condition.remainingMonths}m',
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(condition.effectHint, style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _toneColor(ConditionTone tone) {
    switch (tone) {
      case ConditionTone.positive:
        return AppTheme.green;
      case ConditionTone.negative:
        return AppTheme.red;
      case ConditionTone.mixed:
        return AppTheme.amber;
    }
  }
}
