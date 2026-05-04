import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';
import 'models/active_education.dart';
import 'models/education_program.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final active = state.activeEducation;
    final textTheme = Theme.of(context).textTheme;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Education', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Build longer-term skills through monthly study commitments.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          _ActiveEducationCard(active: active),
          if (active != null) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: state.player.stats.energy >=
                      controller.educationStudyEnergyCost
                  ? () async {
                      final studied = await controller.studyEducation();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            studied
                                ? 'Study progress increased.'
                                : 'Unable to study right now.',
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.menu_book_rounded),
              label: Text(
                'Study (${controller.educationStudyEnergyCost} EN)',
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () async {
                await controller.cancelEducation();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Education program cancelled.')),
                );
              },
              icon: const Icon(Icons.close_rounded),
              label: const Text('Cancel Program'),
            ),
          ],
          const SizedBox(height: 22),
          Text('Program catalog', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final program in controller.educationPrograms) ...[
            _ProgramCard(
              program: program,
              canStart: controller.canStartEducation(program),
              isCompleted: state.completedEducations.any(
                (record) => record.programId == program.id,
              ),
              onStart: () async {
                final started = await controller.startEducation(program);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      started
                          ? '${program.title} started.'
                          : 'Only one active education program is allowed.',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          Text('Completed education', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          if (state.completedEducations.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No completed programs yet.',
                  style: textTheme.bodyMedium,
                ),
              ),
            )
          else
            for (final record in state.completedEducations) ...[
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.verified_rounded,
                    color: AppTheme.green,
                  ),
                  title: Text(record.title),
                  subtitle: Text(
                    'Completed month ${record.completedOnMonth} - ${record.tags.join(', ')}',
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _ActiveEducationCard extends StatelessWidget {
  const _ActiveEducationCard({required this.active});

  final ActiveEducation? active;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final activeEducation = active;
    final program = activeEducation?.program;

    return Card(
      color: AppTheme.surfaceRaised,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  program == null
                      ? Icons.school_outlined
                      : Icons.school_rounded,
                  color: program == null ? AppTheme.amber : AppTheme.green,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    program?.title ?? 'No active program',
                    style: textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (activeEducation == null)
              Text(
                'Start one program to begin multi-month progression.',
                style: textTheme.bodyMedium,
              )
            else _ActiveEducationProgress(active: activeEducation),
          ],
        ),
      ),
    );
  }
}

class _ActiveEducationProgress extends StatelessWidget {
  const _ActiveEducationProgress({required this.active});

  final ActiveEducation active;

  @override
  Widget build(BuildContext context) {
    final program = active.program;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EducationMetric(
          label: 'Progress',
          value: '${active.completedMonths}/${program.durationMonths} months',
        ),
        _EducationMetric(
          label: 'Monthly cost',
          value: '${program.monthlyCost}',
        ),
        _EducationMetric(
          label: 'Study target',
          value:
              '${active.studyProgressThisMonth}/${program.monthlyStudyRequired}',
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: (active.studyProgressThisMonth /
                    program.monthlyStudyRequired)
                .clamp(0.0, 1.0)
                .toDouble(),
            minHeight: 8,
            color: AppTheme.primary,
            backgroundColor: AppTheme.surface,
          ),
        ),
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.canStart,
    required this.isCompleted,
    required this.onStart,
  });

  final EducationProgram program;
  final bool canStart;
  final bool isCompleted;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(program.title, style: textTheme.titleMedium)),
                const SizedBox(width: 10),
                _CommitmentPill(label: program.commitment),
              ],
            ),
            const SizedBox(height: 8),
            Text(program.description, style: textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _EducationMetric(
                    label: 'Duration',
                    value: '${program.durationMonths} months',
                  ),
                ),
                Expanded(
                  child: _EducationMetric(
                    label: 'Cost',
                    value: '${program.monthlyCost}/mo',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _EducationMetric(
                    label: 'Study',
                    value: '${program.monthlyStudyRequired}/mo',
                  ),
                ),
                Expanded(
                  child: _EducationMetric(
                    label: 'Reward',
                    value: program.rewardSummary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: canStart ? onStart : null,
              child: Text(isCompleted ? 'Completed' : 'Start Program'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EducationMetric extends StatelessWidget {
  const _EducationMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _CommitmentPill extends StatelessWidget {
  const _CommitmentPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.violet.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.violet,
            ),
      ),
    );
  }
}
