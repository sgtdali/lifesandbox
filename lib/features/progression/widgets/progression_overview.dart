import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../game/state/game_controller.dart';
import '../models/milestone_definition.dart';
import '../models/run_state_evaluation.dart';

class ProgressionOverview extends StatelessWidget {
  const ProgressionOverview({
    super.key,
    required this.controller,
  });

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final runState = controller.runState;
    final guidance = controller.guidance;
    final milestones = controller.milestones;
    final signals = controller.pressureSignals;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RunStateCard(runState: runState),
        const SizedBox(height: 10),
        _GuidanceCard(guidance: guidance),
        const SizedBox(height: 10),
        _MilestonePreview(milestones: milestones),
        if (signals.isNotEmpty) ...[
          const SizedBox(height: 10),
          _PressureCard(signals: signals),
        ],
      ],
    );
  }
}

class _RunStateCard extends StatelessWidget {
  const _RunStateCard({required this.runState});

  final RunStateEvaluation runState;

  @override
  Widget build(BuildContext context) {
    final color = _tierColor(runState.tier);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      color: AppTheme.surfaceRaised,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.timeline_rounded, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(runState.label, style: textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(runState.description, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _tierColor(RunStateTier tier) {
    switch (tier) {
      case RunStateTier.unstable:
        return AppTheme.red;
      case RunStateTier.recovering:
        return AppTheme.amber;
      case RunStateTier.stable:
        return AppTheme.green;
      case RunStateTier.growing:
        return AppTheme.primary;
      case RunStateTier.businessReady:
        return AppTheme.violet;
    }
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.guidance});

  final List<String> guidance;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Next direction', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final item in guidance)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.arrow_right_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(item, style: textTheme.bodyMedium)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MilestonePreview extends StatelessWidget {
  const _MilestonePreview({required this.milestones});

  final List<MilestoneView> milestones;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final completed = milestones.where((item) => item.completed).length;
    final next = milestones.where((item) => !item.completed).take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Milestones', style: textTheme.titleMedium),
                ),
                Text('$completed/${milestones.length}', style: textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 10),
            if (next.isEmpty)
              Text('All current milestones are complete.', style: textTheme.bodyMedium)
            else
              for (final item in next)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.radio_button_unchecked_rounded,
                        color: AppTheme.mutedText,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.definition.title, style: textTheme.labelLarge),
                            Text(
                              item.definition.description,
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _PressureCard extends StatelessWidget {
  const _PressureCard({required this.signals});

  final List<PressureSignal> signals;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pressure signals', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            for (final signal in signals)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: signal.level == PressureLevel.danger
                          ? AppTheme.red
                          : AppTheme.amber,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(signal.label, style: textTheme.labelLarge),
                          Text(signal.detail, style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
