import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GameStatusStrip extends StatelessWidget {
  const GameStatusStrip({
    super.key,
    required this.cash,
    required this.energy,
    required this.maxEnergy,
    required this.stress,
    required this.month,
  });

  final int cash;
  final int energy;
  final int maxEnergy;
  final int stress;
  final int month;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cash
          _Metric(
            icon: Icons.attach_money_rounded,
            value: '$cash',
            color: cash >= 0 ? AppTheme.green : AppTheme.red,
          ),
          const _Divider(),
          
          // Energy
          _Metric(
            icon: Icons.bolt_rounded,
            value: '$energy',
            color: AppTheme.primary,
          ),
          const _Divider(),

          // Stress
          _Metric(
            icon: Icons.psychology_rounded,
            value: '$stress',
            color: AppTheme.red,
          ),
          
          const Spacer(),
          
          // Month
          Text(
            'MO $month',
            style: textTheme.labelSmall?.copyWith(
              color: AppTheme.mutedText,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppTheme.text,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 14,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: AppTheme.border,
    );
  }
}
