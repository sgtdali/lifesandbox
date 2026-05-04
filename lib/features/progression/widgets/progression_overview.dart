import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../game/state/game_controller.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../models/milestone_definition.dart';

class ProgressionOverview extends StatelessWidget {
  const ProgressionOverview({
    super.key,
    required this.controller,
  });

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final milestones = controller.milestones;
    final completed = milestones.where((item) => item.completed).length;
    final next = milestones.where((item) => !item.completed).take(3).toList();

    return AppSectionCard(
      title: 'MILESTONES',
      action: Text(
        '$completed of ${milestones.length} completed',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppTheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (next.isEmpty)
            const Text('All milestones are complete.')
          else
            for (final item in next)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      item.completed ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                      color: item.completed ? AppTheme.green : AppTheme.mutedText,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.definition.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          const Divider(color: AppTheme.border, height: 24),
          InkWell(
            onTap: () {
              // Show full list
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'View all milestones',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
