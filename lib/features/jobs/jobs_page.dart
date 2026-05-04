import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/metric_row.dart';
import '../../shared/widgets/status_chip.dart';
import '../dashboard/widgets/recommendation_card.dart';
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
                    color: const Color(0xFF1A2A2A),
                    border: Border.all(color: AppTheme.green.withOpacity(0.3), width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.work_rounded, size: 32, color: AppTheme.green),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Career', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                      Text(
                        'Build track experience, move upward, or switch careers carefully.',
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

          // 3. Current Role
          _CurrentJobCard(
            job: currentJob,
            performance: controller.jobPerformance.label,
            tenure: state.workHistory.currentJobTenure,
            readyForNextStep: controller.isReadyForNextCareerStep,
          ),
          const SizedBox(height: 14),

          // 4. History & Readiness
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _WorkHistoryCard(
                  totalMonths: state.workHistory.totalMonthsEmployed,
                  strongestTrack: state.workHistory.strongestTrack,
                  highestLevel: state.workHistory.highestCareerLevel,
                  trackMonths: state.workHistory.trackMonths,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ReadinessCard(
                  job: currentJob,
                  performanceScore: state.jobPerformanceScore,
                  reliability: state.player.reliabilityScore,
                  trackExperience: currentJob != null ? state.workHistory.monthsInTrack(currentJob.track) : 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 5. Listings Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Available Listings', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              Text(
                '${controller.jobSearchEnergyCost} EN',
                style: textTheme.labelSmall?.copyWith(color: AppTheme.mutedText, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Bar Placeholder style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppTheme.mutedText, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Search jobs by title, track, or keyword',
                    style: textTheme.bodyMedium?.copyWith(color: AppTheme.mutedText),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

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
            const SizedBox(height: 12),
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

    final textTheme = Theme.of(context).textTheme;

    return AppSectionCard(
      title: 'Current Role',
      icon: Icons.work_rounded,
      iconColor: AppTheme.green,
      action: const StatusChip(label: 'Strong Fit', color: AppTheme.green),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job!.title,
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StatusChip(label: '${job!.track} L${job!.level}', color: AppTheme.primary.withOpacity(0.1)),
                        const SizedBox(width: 8),
                        StatusChip(label: job!.isStarter ? 'Starter' : 'Career', color: AppTheme.green.withOpacity(0.1)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      job!.description,
                      style: textTheme.bodySmall?.copyWith(color: AppTheme.mutedText),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    MetricRow(label: 'Monthly Salary', value: '+${job!.monthlySalary}', valueColor: AppTheme.green),
                    MetricRow(label: 'Monthly Energy Load', value: '-${job!.monthlyEnergyLoad} EN', valueColor: AppTheme.amber),
                    const SizedBox(height: 12),
                    MetricRow(label: 'Performance', value: performance, valueColor: AppTheme.green),
                    MetricRow(label: 'Months in Role', value: '$tenure'),
                  ],
                ),
              ),
            ],
          ),
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
    final textTheme = Theme.of(context).textTheme;

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
            Align(
              alignment: Alignment.bottomRight,
              child: StatusChip(
                label: '${entries.first.key} ${entries.first.value}m', 
                color: AppTheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({
    required this.job,
    required this.performanceScore,
    required this.reliability,
    required this.trackExperience,
  });

  final Job? job;
  final int performanceScore;
  final int reliability;
  final int trackExperience;

  @override
  Widget build(BuildContext context) {
    if (job == null) return const SizedBox.shrink();
    
    final textTheme = Theme.of(context).textTheme;

    return AppSectionCard(
      title: 'Next Step Readiness',
      icon: Icons.upgrade_rounded,
      iconColor: AppTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReadinessBar(label: 'Experience', value: (trackExperience / (job!.level * 4 + 4)).clamp(0, 1), status: 'Good'),
          _ReadinessBar(label: 'Reliability', value: (reliability / 100).clamp(0, 1), status: 'Good'),
          _ReadinessBar(label: 'Education', value: 0.4, status: 'Building', color: AppTheme.primary),
          _ReadinessBar(label: 'Career Momentum', value: (performanceScore / 100).clamp(0, 1), status: 'Building', color: AppTheme.primary),
          
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: AppTheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Keep building stability.',
                  style: textTheme.labelSmall?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 2),
            child: Text(
              'Consider upskilling or saving to push up.',
              style: textTheme.bodySmall?.copyWith(color: AppTheme.mutedText, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessBar extends StatelessWidget {
  const _ReadinessBar({
    required this.label,
    required this.value,
    required this.status,
    this.color = AppTheme.green,
  });

  final String label;
  final double value;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(_getIconFor(label), size: 14, color: AppTheme.mutedText),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
          ),
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: AppTheme.border,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 50,
            child: Text(
              status, 
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconFor(String label) {
    if (label.contains('Experience')) return Icons.business_center_rounded;
    if (label.contains('Reliability')) return Icons.verified_user_rounded;
    if (label.contains('Education')) return Icons.school_rounded;
    return Icons.trending_up_rounded;
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

    return AppSectionCard(
      title: 'Job Opportunity',
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceRaised,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  job.track == 'Office' ? Icons.work_rounded : Icons.shopping_cart_rounded,
                  color: AppTheme.mutedText,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(job.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                        const SizedBox(width: 8),
                        StatusChip(label: '${job.track} L${job.level}', color: AppTheme.primary.withOpacity(0.1)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.description,
                      style: textTheme.bodySmall?.copyWith(color: AppTheme.mutedText),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _SmallMetric(icon: Icons.monetization_on_rounded, value: '+${job.monthlySalary}', color: AppTheme.green),
                        const SizedBox(width: 16),
                        _SmallMetric(icon: Icons.bolt_rounded, value: '-${job.monthlyEnergyLoad} EN', color: AppTheme.amber),
                        const SizedBox(width: 16),
                        _SmallMetric(icon: Icons.verified_user_rounded, value: 'Security ${job.jobSecurity}', color: AppTheme.mutedText),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(
                    label: '${suitability.level.label} (${suitability.score}/${suitability.threshold})',
                    color: AppTheme.green,
                    icon: Icons.stars_rounded,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 120,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: isCurrentJob || !suitability.level.canApply ? null : onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCurrentJob ? AppTheme.surfaceRaised : AppTheme.primary,
                        foregroundColor: isCurrentJob ? AppTheme.mutedText : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(isCurrentJob ? 'Current Job' : 'Apply', style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallMetric extends StatelessWidget {
  const _SmallMetric({required this.icon, required this.value, required this.color});
  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
