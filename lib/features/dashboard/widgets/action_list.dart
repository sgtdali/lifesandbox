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
    final allActions = controller.actions;
    
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final action in allActions) 
          _ActionChip(action: action, controller: controller),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.action,
    required this.controller,
  });

  final ActionDefinition action;
  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final enabled = controller.canPerform(action);
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: (MediaQuery.of(context).size.width - 60) / 2, // 2 columns roughly
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: InkWell(
        onTap: enabled ? () => controller.performAction(action) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(_getIconFor(action.type), size: 18, color: enabled ? AppTheme.primary : AppTheme.mutedText),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  action.title,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: enabled ? AppTheme.text : AppTheme.mutedText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${action.energyCost} EN',
                style: textTheme.labelSmall?.copyWith(
                  color: AppTheme.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconFor(ActionType type) {
    switch (type) {
      case ActionType.rest: return Icons.hotel_rounded;
      case ActionType.deepRest: return Icons.bed_rounded;
      case ActionType.walk: return Icons.directions_walk_rounded;
      case ActionType.personalReset: return Icons.refresh_rounded;
      case ActionType.socialTime: return Icons.group_rounded;
      case ActionType.selfStudy: return Icons.lightbulb_rounded;
      case ActionType.lookAround: return Icons.search_rounded;
    }
  }
}
