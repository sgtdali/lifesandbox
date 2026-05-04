import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../game/state/game_controller.dart';
import 'month_summary_sheet.dart';
import '../../events/widgets/event_sheet.dart';

class EndMonthSupport extends StatelessWidget {
  const EndMonthSupport({
    super.key,
    required this.controller,
  });

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final hint = _getEndMonthHint();
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        if (hint != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceRaised,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hint,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await controller.endMonth();
              if (!context.mounted) return;
              await showMonthSummarySheet(context, result);
              if (!context.mounted) return;
              final event = controller.state.pendingEvent;
              if (event != null) {
                await showPendingEventSheet(context, event);
              }
            },
            icon: const Icon(Icons.skip_next_rounded),
            label: Text(
              'END MONTH',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String? _getEndMonthHint() {
    final state = controller.state;
    final energy = state.player.stats.energy;
    final stress = state.player.stats.stress;
    final edu = state.activeEducation;

    if (state.pendingEvent != null) {
      return 'You must resolve the pending event first.';
    }

    if (edu != null && !edu.studyRequirementMet) {
      return 'Unfinished education target. You may fail this month.';
    }

    if (energy > 30) {
      return 'You still have $energy EN. Consider taking more actions.';
    }

    if (stress > 80) {
      return 'Extreme stress detected. Recovery is highly recommended.';
    }

    if (energy < 10) {
      return 'You are ready to end the month.';
    }

    return 'No urgent action remains this month.';
  }
}
