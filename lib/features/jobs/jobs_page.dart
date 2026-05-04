import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';
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
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
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
              Expanded(
                child: Text('Available listings', style: textTheme.titleLarge),
              ),
              Text(
                '${controller.jobSearchEnergyCost} EN',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: state.player.stats.energy >= controller.jobSearchEnergyCost
                ? () async {
                    final refreshed = await controller.refreshJobListings();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          refreshed
                              ? 'Career listings refreshed.'
                              : 'Not enough energy to search jobs.',
                        ),
                      ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(result.message)),
                );
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
    final textTheme = Theme.of(context).textTheme;
    final employed = job != null;

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
                  employed ? Icons.badge_rounded : Icons.work_off_rounded,
                  color: employed ? AppTheme.green : AppTheme.amber,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    employed ? job!.title : 'Unemployed',
                    style: textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (employed) ...[
              _Metric(label: 'Track', value: '${job!.track} L${job!.level}'),
              _Metric(label: 'Layer', value: job!.layerLabel),
              _Metric(label: 'Monthly salary', value: '+${job!.monthlySalary}'),
              _Metric(
                label: 'Monthly energy load',
                value: '-${job!.monthlyEnergyLoad} EN',
              ),
              _Metric(label: 'Performance', value: performance),
              _Metric(label: 'Months in role', value: '$tenure'),
              if (readyForNextStep)
                Text(
                  'Ready for stronger ${job!.track} roles.',
                  style: textTheme.bodyMedium?.copyWith(color: AppTheme.green),
                ),
            ] else
              Text(
                'No salary and no automatic job energy burden.',
                style: textTheme.bodyMedium,
              ),
          ],
        ),
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
    final textTheme = Theme.of(context).textTheme;
    final entries = trackMonths.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work history', style: textTheme.titleMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Total employed',
                    value: '$totalMonths months',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Strongest track',
                    value: strongestTrack,
                  ),
                ),
              ],
            ),
            _Metric(label: 'Highest career level', value: 'L$highestLevel'),
            if (entries.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in entries.take(4))
                    _Pill(label: '${entry.key} ${entry.value}m'),
                ],
              ),
            ],
          ],
        ),
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
                Expanded(child: Text(job.title, style: textTheme.titleMedium)),
                const SizedBox(width: 10),
                _Pill(label: job.layerLabel),
              ],
            ),
            const SizedBox(height: 8),
            Text(job.description, style: textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Track / level',
                    value: '${job.track} L${job.level}',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Salary',
                    value: '+${job.monthlySalary}',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: 'Energy load',
                    value: '-${job.monthlyEnergyLoad} EN',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Security',
                    value: '${job.jobSecurity}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _FitBlock(suitability: suitability),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isCurrentJob || !suitability.level.canApply
                  ? null
                  : onApply,
              child: Text(
                isCurrentJob
                    ? 'Current Job'
                    : suitability.level.canApply
                        ? 'Apply'
                        : 'Build Fit First',
              ),
            ),
          ],
        ),
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

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.bodyMedium),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.primary,
            ),
      ),
    );
  }
}
