import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.maxValue = 100,
  });

  final String label;
  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final progress = maxValue <= 0
        ? 0.0
        : (value / maxValue).clamp(0.0, 1.0).toDouble();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Text(label, style: textTheme.labelLarge)),
                  Text('$value / $maxValue', style: textTheme.bodyMedium),
                ],
              ),
              const SizedBox(height: 9),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  color: color,
                  backgroundColor: AppTheme.surfaceRaised,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
