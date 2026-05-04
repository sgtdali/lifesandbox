import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../game/models/action_definition.dart';
import '../../../game/state/game_controller.dart';

class ActionList extends StatelessWidget {
  const ActionList({
    super.key,
    required this.controller,
  });

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final action in controller.actions) ...[
          _ActionTile(
            action: action,
            enabled: controller.canPerform(action),
            onPressed: () => controller.performAction(action),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.action,
    required this.enabled,
    required this.onPressed,
  });

  final ActionDefinition action;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(action.title, style: textTheme.titleMedium),
                    const SizedBox(height: 5),
                    Text(action.description, style: textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: enabled
                      ? AppTheme.primary.withOpacity(0.13)
                      : AppTheme.surfaceRaised,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  action.cashCost > 0
                      ? '${action.energyCost} EN / ${action.cashCost}'
                      : '${action.energyCost} EN',
                  style: textTheme.labelLarge?.copyWith(
                    color: enabled ? AppTheme.primary : AppTheme.mutedText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
