import 'package:flutter/material.dart';

class MetricRow extends StatelessWidget {
  const MetricRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: iconColor ?? textTheme.bodyMedium?.color),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(label, style: textTheme.bodyMedium),
          ),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
