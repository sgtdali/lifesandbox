import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/metric_row.dart';
import '../../shared/widgets/status_chip.dart';
import '../dashboard/widgets/recommendation_card.dart';
import 'models/active_education.dart';
import 'models/completed_education.dart';
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Header
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1A1A2A),
                    border: Border.all(color: AppTheme.violet.withOpacity(0.3), width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.school_rounded, size: 32, color: AppTheme.violet),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Education', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                      Text(
                        'Build longer-term skills through monthly study commitments.',
                        style: textTheme.bodySmall?.copyWith(color: AppTheme.mutedText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Recommendation
          RecommendationCard(
            recommendations: controller.guidance,
          ),
          const SizedBox(height: 12),

          // 3. Active Program
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
          const SizedBox(height: 24),

          // 4. Catalog Header & Filter
          Row(
            children: [
              Expanded(child: Text('Program Catalog', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceRaised,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, size: 18, color: AppTheme.mutedText),
                    SizedBox(width: 8),
                    Icon(Icons.tune_rounded, size: 18, color: AppTheme.mutedText),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _CategoryChip(label: 'All', active: true),
                _CategoryChip(label: 'Light'),
                _CategoryChip(label: 'Moderate'),
                _CategoryChip(label: 'Focused'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. Catalog Catalog (Using Wrap instead of GridView to fix scrolling freezes)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final program in controller.educationPrograms)
                SizedBox(
                  width: 248, // Balanced for 540px container
                  height: 260,
                  child: _ProgramCard(
                    program: program,
                    canStart: controller.canStartEducation(program),
                    isCompleted: state.completedEducations.any(
                      (record) => record.programId == program.id,
                    ),
                    onStart: () async {
                      final started = await controller.startEducation(program);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(started ? '${program.title} started.' : 'Only one active program allowed.')),
                      );
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // 6. Completed Section
          Text('Completed Education', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          
          if (state.completedEducations.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceRaised,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Icon(Icons.emoji_events_rounded, size: 48, color: AppTheme.mutedText.withOpacity(0.3)),
                  const SizedBox(height: 12),
                  Text('No completed programs yet.', style: textTheme.bodyMedium?.copyWith(color: AppTheme.mutedText)),
                  Text('Keep learning to unlock powerful rewards.', style: textTheme.bodySmall?.copyWith(color: AppTheme.mutedText.withOpacity(0.7))),
                ],
              ),
            )
          else
            for (final record in state.completedEducations) ...[
              _CompletedItem(record: record),
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
    final textTheme = Theme.of(context).textTheme;

    return AppSectionCard(
      title: 'ACTIVE PROGRAM',
      icon: Icons.menu_book_rounded,
      iconColor: AppTheme.violet,
      action: const StatusChip(label: 'Active', color: AppTheme.green),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(program.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ActiveMetric(icon: Icons.timelapse_rounded, label: 'Progress', value: '${active!.completedMonths}/${program.durationMonths}', unit: 'months'),
              _ActiveMetric(icon: Icons.monetization_on_rounded, label: 'Monthly Cost', value: '${program.monthlyCost}', color: AppTheme.red),
              _ActiveMetric(icon: Icons.track_changes_rounded, label: 'Study Target', value: '${active!.studyProgressThisMonth}/${program.monthlyStudyRequired}'),
              _ActiveMetric(icon: Icons.analytics_rounded, label: 'Focus', value: program.commitment, isTag: true),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: onStudy,
                    icon: const Icon(Icons.menu_book_rounded, size: 18),
                    label: Text('Study ($studyEnergyCost EN)', style: const TextStyle(fontWeight: FontWeight.w900)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Cancel Program', style: TextStyle(fontWeight: FontWeight.w900)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                _StatusSubItem(
                  icon: Icons.bolt_rounded,
                  label: 'Study Target Remaining',
                  value: '${program.monthlyStudyRequired - active!.studyProgressThisMonth}',
                  subLabel: 'Keep going!',
                  color: AppTheme.amber,
                ),
                const Spacer(),
                _StatusSubItem(
                  icon: Icons.monetization_on_rounded,
                  label: 'Affordability',
                  value: 'Affordable',
                  subLabel: '${program.monthlyCost}/mo',
                  color: AppTheme.green,
                ),
                const Spacer(),
                _StatusSubItem(
                  icon: Icons.stars_rounded,
                  label: 'Next Reward',
                  value: program.rewardSummary.split(', ').take(2).join(', '),
                  subLabel: 'Upon completion',
                  color: AppTheme.violet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveMetric extends StatelessWidget {
  const _ActiveMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.unit,
    this.color,
    this.isTag = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? unit;
  final Color? color;
  final bool isTag;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color ?? AppTheme.primary),
            const SizedBox(width: 4),
            Text(label, style: textTheme.labelSmall?.copyWith(color: AppTheme.mutedText, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 4),
        if (isTag)
          StatusChip(label: value, color: AppTheme.surfaceRaised)
        else
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w900)),
                if (unit != null)
                  TextSpan(text: ' $unit', style: textTheme.labelSmall?.copyWith(color: AppTheme.mutedText)),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatusSubItem extends StatelessWidget {
  const _StatusSubItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.subLabel,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.labelSmall?.copyWith(color: AppTheme.mutedText, fontSize: 9)),
                Text(value, style: textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w900)),
                Text(subLabel, style: textTheme.labelSmall?.copyWith(color: AppTheme.mutedText.withOpacity(0.5), fontSize: 9)),
              ],
            ),
          ],
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

    return AppSectionCard(
      title: 'Program Info',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.violet.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getIconFor(program.title), size: 20, color: AppTheme.violet),
              ),
              const Spacer(),
              StatusChip(label: program.commitment, color: AppTheme.surfaceRaised),
            ],
          ),
          const SizedBox(height: 12),
          Text(program.title, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(
            program.description,
            style: textTheme.bodySmall?.copyWith(color: AppTheme.mutedText, fontSize: 10),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TinyMetric(label: 'Duration', value: '${program.durationMonths}m'),
              _TinyMetric(label: 'Cost', value: '${program.monthlyCost}/mo', color: AppTheme.red),
              _TinyMetric(label: 'Study', value: '${program.monthlyStudyRequired}/mo'),
            ],
          ),
          const SizedBox(height: 8),
          Text('Reward: ${program.rewardSummary}', style: textTheme.labelSmall?.copyWith(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.w700)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: canStart ? onStart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCompleted ? AppTheme.violet.withOpacity(0.1) : AppTheme.primary,
                foregroundColor: isCompleted ? AppTheme.violet : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(isCompleted ? 'Current Program' : 'Start Program', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconFor(String title) {
    if (title.contains('Office')) return Icons.school_rounded;
    if (title.contains('Sales')) return Icons.trending_up_rounded;
    if (title.contains('Data')) return Icons.assignment_rounded;
    return Icons.chat_bubble_rounded;
  }
}

class _TinyMetric extends StatelessWidget {
  const _TinyMetric({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 8, color: AppTheme.mutedText)),
        Text(value, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, this.active = false});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: active ? AppTheme.violet.withOpacity(0.15) : AppTheme.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? AppTheme.violet.withOpacity(0.3) : AppTheme.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: active ? AppTheme.violet : AppTheme.mutedText,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _CompletedItem extends StatelessWidget {
  const _CompletedItem({required this.record});
  final CompletedEducation record;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Certificate',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.verified_rounded, color: AppTheme.green),
        title: Text(record.title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('Completed month ${record.completedOnMonth} - ${record.tags.join(', ')}'),
      ),
    );
  }
}
