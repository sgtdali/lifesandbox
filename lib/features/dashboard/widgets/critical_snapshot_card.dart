import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../game/models/core_stats.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../shared/widgets/status_chip.dart';

class CriticalSnapshotCard extends StatelessWidget {
  const CriticalSnapshotCard({
    super.key,
    required this.stats,
    required this.wellbeingLabel,
    required this.wellbeingColor,
  });

  final CoreStats stats;
  final String wellbeingLabel;
  final Color wellbeingColor;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'CRITICAL SNAPSHOT',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatBar(
            label: 'Health',
            current: stats.health,
            max: 100,
            color: AppTheme.green,
            icon: Icons.favorite_rounded,
          ),
          const SizedBox(height: 14),
          _StatBar(
            label: 'Happiness',
            current: stats.happiness,
            max: 100,
            color: AppTheme.amber,
            icon: Icons.sentiment_satisfied_rounded,
          ),
          const SizedBox(height: 14),
          _StatBar(
            label: 'Intelligence',
            current: stats.intelligence,
            max: 100,
            color: AppTheme.primary,
            icon: Icons.psychology_rounded,
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'WELLBEING',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.mutedText,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        fontSize: 10,
                      ),
                ),
                const SizedBox(width: 12),
                StatusChip(
                  label: wellbeingLabel,
                  color: wellbeingColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.label,
    required this.current,
    required this.max,
    required this.color,
    required this.icon,
  });

  final String label;
  final int current;
  final int max;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final progress = (current / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
              ),
            ),
            Text(
              '$current',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withOpacity(0.12),
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
