import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../game/models/action_definition.dart';
import '../../../game/models/action_type.dart';
import '../../../game/state/game_controller.dart';
import '../../../shared/widgets/status_chip.dart';

class ActionList extends StatelessWidget {
  const ActionList({
    super.key,
    required this.controller,
  });

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final recoveryActions = controller.actions.where((a) => a.type == ActionType.rest || a.type == ActionType.deepRest || a.type == ActionType.walk).toList();
    final wellbeingActions = controller.actions.where((a) => a.type == ActionType.personalReset || a.type == ActionType.socialTime).toList();
    final progressActions = controller.actions.where((a) => a.type == ActionType.selfStudy || a.type == ActionType.lookAround).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recoveryActions.isNotEmpty) ...[
          _ActionGroupLabel('Recovery'),
          for (final action in recoveryActions) _ActionTile(action: action, controller: controller),
          const SizedBox(height: 12),
        ],
        if (wellbeingActions.isNotEmpty) ...[
          _ActionGroupLabel('Wellbeing'),
          for (final action in wellbeingActions) _ActionTile(action: action, controller: controller),
          const SizedBox(height: 12),
        ],
        if (progressActions.isNotEmpty) ...[
          _ActionGroupLabel('Progress'),
          for (final action in progressActions) _ActionTile(action: action, controller: controller),
        ],
      ],
    );
  }
}

class _ActionGroupLabel extends StatelessWidget {
  const _ActionGroupLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.mutedText,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.action,
    required this.controller,
  });

  final ActionDefinition action;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final enabled = controller.canPerform(action);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? () => controller.performAction(action) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action.title, 
                        style: textTheme.titleMedium?.copyWith(
                          color: enabled ? AppTheme.text : AppTheme.mutedText,
                        ),
                      ),
                      if (action.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          action.description, 
                          style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusChip(
                      label: '${action.energyCost} EN',
                      color: enabled ? AppTheme.primary : AppTheme.mutedText,
                      icon: Icons.bolt_rounded,
                    ),
                    if (action.cashCost > 0) ...[
                      const SizedBox(height: 4),
                      StatusChip(
                        label: '-${action.cashCost}',
                        color: enabled ? AppTheme.red : AppTheme.mutedText,
                        icon: Icons.attach_money_rounded,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
