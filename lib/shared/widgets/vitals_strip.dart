import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../game/models/core_stats.dart';

class VitalsStrip extends StatelessWidget {
  const VitalsStrip({
    super.key,
    required this.stats,
    required this.cash,
    required this.month,
  });

  final CoreStats stats;
  final int cash;
  final int month;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Circles Row (Prioritized)
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatCircle(
                  label: 'Energy',
                  icon: Icons.bolt_rounded,
                  current: stats.energy,
                  max: stats.maxEnergy,
                  color: AppTheme.primary,
                ),
                _StatCircle(
                  label: 'Stress',
                  icon: Icons.psychology_rounded,
                  current: stats.stress,
                  max: 100,
                  color: AppTheme.red,
                ),
                _StatCircle(
                  label: 'Health',
                  icon: Icons.favorite_rounded,
                  current: stats.health,
                  max: 100,
                  color: AppTheme.green,
                ),
                _StatCircle(
                  label: 'Happy',
                  icon: Icons.sentiment_satisfied_rounded,
                  current: stats.happiness,
                  max: 100,
                  color: AppTheme.amber,
                ),
                _StatCircle(
                  label: 'Intel',
                  icon: Icons.lightbulb_rounded,
                  current: stats.intelligence,
                  max: 100,
                  color: AppTheme.violet,
                ),
              ],
            ),
          ),
          
          // Vertical Divider
          Container(
            height: 40,
            width: 1,
            color: AppTheme.border,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Right: Cash and Month
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.attach_money_rounded, size: 16, color: AppTheme.green),
                  const SizedBox(width: 4),
                  Text(
                    '$cash',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.text,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'MO $month',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.mutedText,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      fontSize: 10,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCircle extends StatelessWidget {
  const _StatCircle({
    required this.label,
    required this.icon,
    required this.current,
    required this.max,
    required this.color,
  });

  final String label;
  final IconData icon;
  final int current;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final value = (current / max).clamp(0.0, 1.0);
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.background.withOpacity(0.3),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: value,
                  backgroundColor: Colors.transparent,
                  color: color,
                  strokeWidth: 2.5,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 14, color: color.withOpacity(0.9)),
                  const SizedBox(height: 1),
                  Text(
                    '$current',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppTheme.text,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.mutedText,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}
