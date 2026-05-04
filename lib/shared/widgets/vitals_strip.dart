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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Cash and Month
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.attach_money_rounded, size: 16, color: AppTheme.green),
                  const SizedBox(width: 4),
                  Text(
                    '$cash',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                ],
              ),
              Text(
                'MONTH $month',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.mutedText,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Circles Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatCircle(
                icon: Icons.bolt_rounded,
                current: stats.energy,
                max: stats.maxEnergy,
                color: AppTheme.primary,
              ),
              _StatCircle(
                icon: Icons.psychology_rounded,
                current: stats.stress,
                max: 100,
                color: AppTheme.red,
              ),
              _StatCircle(
                icon: Icons.favorite_rounded,
                current: stats.health,
                max: 100,
                color: AppTheme.green,
              ),
              _StatCircle(
                icon: Icons.sentiment_satisfied_rounded,
                current: stats.happiness,
                max: 100,
                color: AppTheme.amber,
              ),
              _StatCircle(
                icon: Icons.lightbulb_rounded,
                current: stats.intelligence,
                max: 100,
                color: AppTheme.violet,
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
    required this.icon,
    required this.current,
    required this.max,
    required this.color,
  });

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
        SizedBox(
          width: 42,
          height: 42,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                backgroundColor: color.withOpacity(0.1),
                color: color,
                strokeWidth: 3.5,
                strokeCap: StrokeCap.round,
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$current',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppTheme.text.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}
