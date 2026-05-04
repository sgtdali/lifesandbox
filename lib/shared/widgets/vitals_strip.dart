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
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border.withOpacity(0.5)),
      ),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            _VitalsItem(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Cash',
              value: '\$$cash',
              color: AppTheme.green,
            ),
            _VitalsDivider(),
            _VitalsItem(
              icon: Icons.bolt_rounded,
              label: 'Energy',
              value: '${stats.energy}',
              color: AppTheme.amber,
            ),
            _VitalsDivider(),
            _VitalsItem(
              icon: Icons.psychology_rounded,
              label: 'Stress',
              value: '${stats.stress}',
              color: const Color(0xFFF47B6D), // More coral/orange-red like the image
            ),
            _VitalsDivider(),
            _VitalsItem(
              icon: Icons.calendar_today_rounded,
              label: 'Month',
              value: 'M $month',
              color: const Color(0xFF63A0FF), // Lighter blue like the image
            ),
          ],
        ),
      ),
    );
  }
}

class _VitalsItem extends StatelessWidget {
  const _VitalsItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.mutedText,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VitalsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      color: AppTheme.border.withOpacity(0.5),
      thickness: 1,
      width: 1,
      indent: 4,
      endIndent: 4,
    );
  }
}
