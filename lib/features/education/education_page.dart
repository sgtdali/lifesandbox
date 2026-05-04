import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/metric_row.dart';
import '../../shared/widgets/status_chip.dart';
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
          
          _ActiveEducationCard(
            active: active,
            studyEnergyCost: controller.educationStudyEnergyCost,
            onStudy: state.player.stats.energy >= controller.educationStudyEnergyCost
                ? () async {
                    final studied = await controller.studyEducation();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(studied ? 'Study progress increased.' : 'Unable to study right now.')),
                    );
                  }
                : null,
            onCancel: () async {
              await controller.cancelEducation();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Education program cancelled.')),
              );
            },
          ),
          
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
                      started ? '${program.title} started.' : 'Only one active education program is allowed.',
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
                child: Text('No completed programs yet.', style: textTheme.bodyMedium),
              ),
            )
          else
            for (final record in state.completedEducations) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.verified_rounded, color: AppTheme.green),
                  title: Text(record.title),
                  subtitle: Text('Completed month ${record.completedOnMonth} - ${record.tags.join(', ')}'),
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
  const _ActiveEducationCard({
    required this.active,
    required this.studyEnergyCost,
    required this.onStudy,
    required this.onCancel,
  });

  final ActiveEducation? active;
  final int studyEnergyCost;
  final VoidCallback? onStudy;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    if (active == null) {
      return const AppSectionCard(
        title: 'No active program',
        icon: Icons.school_outlined,
        iconColor: AppTheme.amber,
        child: Text('Start one program to begin multi-month progression.'),
      );
    }

    final program = active!.program;

    return AppSectionCard(
      title: program.title,
      icon: Icons.school_rounded,
      iconColor: AppTheme.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricRow(label: 'Progress', value: '${active!.completedMonths}/${program.durationMonths} months'),
          MetricRow(label: 'Monthly Cost', value: '${program.monthlyCost}', valueColor: AppTheme.red),
          MetricRow(label: 'Study Target', value: '${active!.studyProgressThisMonth}/${program.monthlyStudyRequired}'),
          
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (active!.studyProgressThisMonth / program.monthlyStudyRequired).clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
            ),
          ),
          const SizedBox(height: 16),
          
          ElevatedButton.icon(
            onPressed: onStudy,
            icon: const Icon(Icons.menu_book_rounded),
            label: Text('Study ($studyEnergyCost EN)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded),
            label: const Text('Cancel Program'),
          ),
        ],
      ),
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
    return AppSectionCard(
      title: program.title,
      subtitle: program.description,
      action: StatusChip(label: program.commitment, color: AppTheme.violet),
      child: Column(
        children: [
          MetricRow(label: 'Duration', value: '${program.durationMonths} months'),
          MetricRow(label: 'Cost', value: '${program.monthlyCost}/mo'),
          MetricRow(label: 'Study Req.', value: '${program.monthlyStudyRequired}/mo'),
          MetricRow(label: 'Reward', value: program.rewardSummary, valueColor: AppTheme.primary),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: canStart ? onStart : null,
            child: Text(isCompleted ? 'Completed' : 'Start Program'),
          ),
        ],
      ),
    );
  }
}
