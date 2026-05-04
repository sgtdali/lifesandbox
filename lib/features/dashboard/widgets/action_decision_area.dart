import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../game/models/action_definition.dart';
import '../../../game/models/action_type.dart';
import '../../../game/state/game_controller.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/app_section_card.dart';
import 'action_list.dart';

class ActionDecisionArea extends StatefulWidget {
  const ActionDecisionArea({
    super.key,
    required this.controller,
  });

  final GameController controller;

  @override
  State<ActionDecisionArea> createState() => _ActionDecisionAreaState();
}

class _ActionDecisionAreaState extends State<ActionDecisionArea> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final recommendations = _getRecommendations();
    final textTheme = Theme.of(context).textTheme;

    return AppSectionCard(
      title: 'RECOMMENDED ACTIONS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommended Horizontal Cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final rec in recommendations)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _DecisionCard(
                      title: rec.title,
                      description: rec.description,
                      icon: rec.icon,
                      onTap: rec.onTap,
                      enabled: rec.enabled,
                      energyCost: rec.energyCost,
                      color: rec.color,
                    ),
                  ),
                // End Month Card
                _DecisionCard(
                  title: 'End Month',
                  description: 'Advance to next month.',
                  icon: Icons.flag_rounded,
                  onTap: () => widget.controller.endMonth(),
                  enabled: true,
                  color: AppTheme.violet,
                  isEndMonth: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _Label('ALL ACTIONS'),
          const SizedBox(height: 12),
          ActionList(controller: widget.controller),
        ],
      ),
    );
  }

  List<_Recommendation> _getRecommendations() {
    final state = widget.controller.state;
    final stats = state.player.stats;
    final allActions = widget.controller.actions;
    final recs = <_Recommendation>[];

    // 1. Recovery if needed
    if (stats.stress > 60 || stats.energy < 25) {
      final rest = allActions.where((a) => a.type == ActionType.rest).firstOrNull;
      if (rest != null) {
        recs.add(_Recommendation(
          title: rest.title,
          description: 'Recover energy and reduce stress.',
          icon: Icons.hotel_rounded,
          energyCost: rest.energyCost,
          onTap: () => widget.controller.performAction(rest),
          enabled: widget.controller.canPerform(rest),
          color: AppTheme.green,
        ));
      }
    }

    // 2. Education Study
    final edu = state.activeEducation;
    if (edu != null && !edu.studyRequirementMet) {
      recs.add(_Recommendation(
        title: 'Self Study',
        description: 'Make progress on your current education.',
        icon: Icons.school_rounded,
        energyCost: 20,
        onTap: () => widget.controller.studyEducation(),
        enabled: stats.energy >= 20,
        color: AppTheme.primary,
      ));
    }

    // 3. Job Search if unemployed
    if (state.currentJob == null && state.activeCompany == null) {
      recs.add(_Recommendation(
        title: 'Find a Job',
        description: 'Search for new career listings.',
        icon: Icons.search_rounded,
        energyCost: widget.controller.jobSearchEnergyCost,
        onTap: () => widget.controller.refreshJobListings(),
        enabled: stats.energy >= widget.controller.jobSearchEnergyCost,
        color: AppTheme.amber,
      ));
    }

    return recs.take(2).toList();
  }
}

class _Label extends StatelessWidget {
  const _Label(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.mutedText,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _Recommendation {
  _Recommendation({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.enabled,
    this.energyCost,
    this.color,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final int? energyCost;
  final Color? color;
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.enabled,
    this.energyCost,
    this.color,
    this.isEndMonth = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final int? energyCost;
  final Color? color;
  final bool isEndMonth;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final themeColor = color ?? AppTheme.primary;

    return Container(
      width: 160,
      height: 180,
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withOpacity(0.2), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: themeColor, size: 24),
                  ),
                  if (energyCost != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$energyCost EN',
                        style: textTheme.labelSmall?.copyWith(
                          color: themeColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: enabled ? AppTheme.text : AppTheme.mutedText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.mutedText,
                      fontSize: 11,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward_rounded, size: 16, color: themeColor.withOpacity(0.5)),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
