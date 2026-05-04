import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendations,
    this.onTap,
  });

  final List<String> recommendations;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.track_changes_rounded,
                  color: Color(0xFF63A0FF),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recommended this month:',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recommendations.first,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppTheme.text,
                          ),
                    ),
                    if (recommendations.length > 1) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 14, color: AppTheme.mutedText),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              recommendations[1],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.mutedText,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppTheme.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}
