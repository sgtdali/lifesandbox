import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../game/state/game_scope.dart';
import '../models/event_resolution.dart';
import '../models/pending_event.dart';

Future<void> showPendingEventSheet(
  BuildContext context,
  PendingEvent pendingEvent,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surface,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) => _EventSheet(pendingEvent: pendingEvent),
  );
}

class _EventSheet extends StatefulWidget {
  const _EventSheet({required this.pendingEvent});

  final PendingEvent pendingEvent;

  @override
  State<_EventSheet> createState() => _EventSheetState();
}

class _EventSheetState extends State<_EventSheet> {
  EventResolution? _resolution;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final event = widget.pendingEvent.event;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(event.category, style: textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(event.title, style: textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(event.description, style: textTheme.bodyMedium),
            if (event.triggerHint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(event.triggerHint, style: textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            if (_resolution == null && event.choices.isEmpty) ...[
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue'),
              ),
            ] else if (_resolution == null)
              for (final choice in event.choices) ...[
                ElevatedButton(
                  onPressed: () async {
                    final resolution = await GameScope.of(context)
                        .resolvePendingEvent(choice);
                    if (!mounted) return;
                    setState(() => _resolution = resolution);
                  },
                  child: Text(choice.label),
                ),
                const SizedBox(height: 10),
                Text(choice.effect.summary, style: textTheme.bodyMedium),
                const SizedBox(height: 10),
              ]
            else ...[
              Text(_resolution!.resultText, style: textTheme.bodyLarge),
              const SizedBox(height: 10),
              Text(_resolution!.effectSummary, style: textTheme.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
