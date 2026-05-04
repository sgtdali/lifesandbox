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
            child: Text(
              label, 
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                fontSize: 13,
              )
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w700,
                fontSize: value.length > 20 ? 11 : 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
