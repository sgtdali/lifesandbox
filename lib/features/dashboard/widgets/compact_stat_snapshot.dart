import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../game/models/core_stats.dart';

class CompactStatSnapshot extends StatelessWidget {
  const CompactStatSnapshot({
    super.key,
    required this.stats,
  });

  final CoreStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _CompactBar(
                  label: 'Energy',
                  value: stats.energy,
                  maxValue: stats.maxEnergy,
                  color: AppTheme.primary,
                  icon: Icons.bolt_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CompactBar(
                  label: 'Stress',
                  value: stats.stress,
                  maxValue: 100,
                  color: AppTheme.red,
                  icon: Icons.psychology_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CompactBar(
                  label: 'Health',
                  value: stats.health,
                  maxValue: 100,
                  color: AppTheme.green,
                  icon: Icons.favorite_rounded,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CompactBar(
                  label: 'Happiness',
                  value: stats.happiness,
                  maxValue: 100,
                  color: AppTheme.amber,
                  icon: Icons.sentiment_satisfied_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppTheme.border),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppTheme.violet),
              const SizedBox(width: 6),
              Text(
                'Intelligence: ${stats.intelligence}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.violet,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactBar extends StatelessWidget {
  const _CompactBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.icon,
  });

  final String label;
  final int value;
  final int maxValue;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final progress = (value / maxValue).clamp(0.0, 1.0).toDouble();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: textTheme.labelSmall?.copyWith(color: AppTheme.mutedText)),
            const Spacer(),
            Text('$value', style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            color: color,
            backgroundColor: AppTheme.border,
          ),
        ),
      ],
    );
  }
}
