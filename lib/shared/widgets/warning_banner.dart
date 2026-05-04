import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

enum WarningSeverity { info, warning, danger, success }

class WarningBanner extends StatelessWidget {
  const WarningBanner({
    super.key,
    required this.title,
    this.message,
    this.severity = WarningSeverity.warning,
    this.icon,
    this.action,
  });

  final String title;
  final String? message;
  final WarningSeverity severity;
  final IconData? icon;
  final Widget? action;

  Color get _color {
    switch (severity) {
      case WarningSeverity.info:
        return AppTheme.primary;
      case WarningSeverity.warning:
        return AppTheme.amber;
      case WarningSeverity.danger:
        return AppTheme.red;
      case WarningSeverity.success:
        return AppTheme.green;
    }
  }

  IconData get _defaultIcon {
    switch (severity) {
      case WarningSeverity.info:
        return Icons.info_outline_rounded;
      case WarningSeverity.warning:
        return Icons.warning_amber_rounded;
      case WarningSeverity.danger:
        return Icons.error_outline_rounded;
      case WarningSeverity.success:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _color;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? _defaultIcon, color: themeColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(color: themeColor),
                ),
                if (message != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    message!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.text.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            action!,
          ],
        ],
      ),
    );
  }
}
