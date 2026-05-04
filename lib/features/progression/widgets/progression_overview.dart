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
    final guidance = controller.guidance;
    final milestones = controller.milestones;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GuidanceCard(guidance: guidance),
        const SizedBox(height: 14),
        _MilestonePreview(milestones: milestones),
      ],
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.guidance});

  final List<String> guidance;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Current Guidance',
      icon: Icons.assistant_direction_rounded,
      iconColor: AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in guidance)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_right_rounded, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 6),
                  Expanded(child: Text(item, style: Theme.of(context).textTheme.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MilestonePreview extends StatelessWidget {
  const _MilestonePreview({required this.milestones});

  final List<MilestoneView> milestones;

  @override
  Widget build(BuildContext context) {
    final completed = milestones.where((item) => item.completed).length;
    final next = milestones.where((item) => !item.completed).take(3).toList();

    return AppSectionCard(
      title: 'Milestones',
      subtitle: '$completed of ${milestones.length} completed',
      icon: Icons.flag_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (next.isEmpty)
            Text('All current milestones are complete.', style: Theme.of(context).textTheme.bodyMedium)
          else
            for (final item in next)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.radio_button_unchecked_rounded, color: AppTheme.mutedText, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.definition.title, style: Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text(item.definition.description, style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
