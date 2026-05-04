import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/metric_row.dart';
import '../../shared/widgets/status_chip.dart';
import 'models/job.dart';
import 'models/suitability.dart';
import 'models/work_history.dart';

class JobsPage extends StatelessWidget {
  const JobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final currentJob = state.currentJob;
    final textTheme = Theme.of(context).textTheme;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Career', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Build track experience, move upward, or switch careers carefully.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          
          _CurrentJobCard(
            job: currentJob,
            performance: controller.jobPerformance.label,
            tenure: state.workHistory.currentJobTenure,
            readyForNextStep: controller.isReadyForNextCareerStep,
          ),
          const SizedBox(height: 12),
          
          _WorkHistoryCard(
            totalMonths: state.workHistory.totalMonthsEmployed,
            strongestTrack: state.workHistory.strongestTrack,
            highestLevel: state.workHistory.highestCareerLevel,
            trackMonths: state.workHistory.trackMonths,
          ),
          const SizedBox(height: 18),
          
          Row(
            children: [
              Expanded(child: Text('Available listings', style: textTheme.titleLarge)),
              Text('${controller.jobSearchEnergyCost} EN', style: textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 10),
          
          OutlinedButton.icon(
            onPressed: state.player.stats.energy >= controller.jobSearchEnergyCost
                ? () async {
                    final refreshed = await controller.refreshJobListings();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(refreshed ? 'Career listings refreshed.' : 'Not enough energy to search jobs.')),
                    );
                  }
                : null,
            icon: const Icon(Icons.search_rounded),
            label: const Text('Search Jobs'),
          ),
          const SizedBox(height: 12),
          
          for (final job in state.availableJobs) ...[
            _JobListingCard(
              job: job,
              suitability: controller.suitabilityFor(job),
              isCurrentJob: currentJob?.id == job.id,
              onApply: () async {
                final result = await controller.applyToJob(job);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
              },
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _CurrentJobCard extends StatelessWidget {
  const _CurrentJobCard({
    required this.job,
    required this.performance,
    required this.tenure,
    required this.readyForNextStep,
  });

  final Job? job;
  final String performance;
  final int tenure;
  final bool readyForNextStep;

  @override
  Widget build(BuildContext context) {
    if (job == null) {
      return const AppSectionCard(
        title: 'Unemployed',
        icon: Icons.work_off_rounded,
        iconColor: AppTheme.amber,
        child: Text('No salary and no automatic job energy burden.'),
      );
    }

    return AppSectionCard(
      title: job!.title,
      icon: Icons.badge_rounded,
      iconColor: AppTheme.green,
      action: StatusChip(label: '${job!.track} L${job!.level}', color: AppTheme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricRow(label: 'Layer', value: job!.layerLabel),
          MetricRow(label: 'Monthly Salary', value: '+${job!.monthlySalary}', valueColor: AppTheme.green),
          MetricRow(label: 'Monthly Energy Load', value: '-${job!.monthlyEnergyLoad} EN', valueColor: AppTheme.amber),
          const Divider(height: 24, color: AppTheme.border),
          MetricRow(label: 'Performance', value: performance),
          MetricRow(label: 'Months in Role', value: '$tenure'),
          if (readyForNextStep) ...[
            const SizedBox(height: 12),
            Text(
              'Ready for stronger ${job!.track} roles.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.green),
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkHistoryCard extends StatelessWidget {
  const _WorkHistoryCard({
    required this.totalMonths,
    required this.strongestTrack,
    required this.highestLevel,
    required this.trackMonths,
  });

  final int totalMonths;
  final String strongestTrack;
  final int highestLevel;
  final Map<String, int> trackMonths;

  @override
  Widget build(BuildContext context) {
    final entries = trackMonths.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return AppSectionCard(
      title: 'Work History',
      icon: Icons.history_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricRow(label: 'Total Employed', value: '$totalMonths months'),
          MetricRow(label: 'Strongest Track', value: strongestTrack),
          MetricRow(label: 'Highest Career Level', value: 'L$highestLevel'),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in entries.take(4))
                  StatusChip(label: '${entry.key} ${entry.value}m', color: AppTheme.primary),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _JobListingCard extends StatelessWidget {
  const _JobListingCard({
    required this.job,
    required this.suitability,
    required this.isCurrentJob,
    required this.onApply,
  });

  final Job job;
  final SuitabilityPreview suitability;
  final bool isCurrentJob;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: job.title,
      subtitle: job.description,
      action: StatusChip(label: job.layerLabel, color: AppTheme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricRow(label: 'Track / Level', value: '${job.track} L${job.level}'),
          MetricRow(label: 'Salary', value: '+${job.monthlySalary}', valueColor: AppTheme.green),
          MetricRow(label: 'Energy Load', value: '-${job.monthlyEnergyLoad} EN', valueColor: AppTheme.amber),
          MetricRow(label: 'Security', value: '${job.jobSecurity}'),
          const SizedBox(height: 12),
          _FitBlock(suitability: suitability),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: isCurrentJob || !suitability.level.canApply ? null : onApply,
            child: Text(isCurrentJob ? 'Current Job' : suitability.level.canApply ? 'Apply' : 'Build Fit First'),
          ),
        ],
      ),
    );
  }
}

class _FitBlock extends StatelessWidget {
  const _FitBlock({required this.suitability});

  final SuitabilityPreview suitability;

  @override
  Widget build(BuildContext context) {
    final color = switch (suitability.level) {
      SuitabilityLevel.strongFit => AppTheme.green,
      SuitabilityLevel.fit => AppTheme.primary,
      SuitabilityLevel.risky => AppTheme.amber,
      SuitabilityLevel.lowFit => AppTheme.red,
    };
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${suitability.level.label} (${suitability.score}/${suitability.threshold})',
            style: textTheme.labelLarge?.copyWith(color: color),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            runSpacing: 6,
            children: [
              for (final reason in suitability.reasons)
                Text(reason, style: textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
