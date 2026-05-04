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
      title: 'Monthly Actions',
      icon: Icons.ads_click_rounded,
      action: !widget.controller.hasMeaningfulEnergy
          ? const StatusChip(label: 'Low energy', color: AppTheme.red)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recommended Section
          if (recommendations.isNotEmpty) ...[
            _Label('RECOMMENDED FOR YOU'),
            const SizedBox(height: 8),
            for (final rec in recommendations)
              _DecisionTile(
                title: rec.title,
                description: rec.description,
                icon: rec.icon,
                onTap: rec.onTap,
                enabled: rec.enabled,
                energyCost: rec.energyCost,
                color: rec.color,
              ),
            const SizedBox(height: 8),
          ],

          // Toggle for All Actions
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _showAll = !_showAll),
              icon: Icon(_showAll
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded),
              label: Text(_showAll ? 'Show Fewer Actions' : 'Show All Actions'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
            ),
          ),

          if (_showAll) ...[
            const SizedBox(height: 8),
            ActionList(controller: widget.controller),
          ],
        ],
      ),
    );
  }

  List<_Recommendation> _getRecommendations() {
    final state = widget.controller.state;
    final stats = state.player.stats;
    final allActions = widget.controller.actions;
    final recs = <_Recommendation>[];

    // 1. Critical Debt
    if (widget.controller.financeSnapshot.emergencyDebt > 0) {
      recs.add(_Recommendation(
        title: 'Manage Debt',
        description: 'You have emergency debt. Consider paying it down.',
        icon: Icons.account_balance_wallet_rounded,
        color: AppTheme.red,
        onTap: () {
          // Navigation to finance tab would be better, but we can't do that easily here.
          // For now, we just suggest it. 
        },
        enabled: true,
      ));
    }

    // 2. Recovery
    if (stats.stress > 65) {
      final reset = allActions.where((a) => a.type == ActionType.personalReset).firstOrNull;
      if (reset != null && widget.controller.canPerform(reset)) {
        recs.add(_Recommendation(
          title: reset.title,
          description: reset.description,
          icon: Icons.refresh_rounded,
          energyCost: reset.energyCost,
          onTap: () => widget.controller.performAction(reset),
          enabled: true,
        ));
      } else {
        final rest = allActions.where((a) => a.type == ActionType.rest).firstOrNull;
        if (rest != null && widget.controller.canPerform(rest)) {
          recs.add(_Recommendation(
            title: rest.title,
            description: rest.description,
            icon: Icons.bedtime_rounded,
            energyCost: rest.energyCost,
            onTap: () => widget.controller.performAction(rest),
            enabled: true,
          ));
        }
      }
    }

    // 3. Education Study
    final edu = state.activeEducation;
    if (edu != null && !edu.studyRequirementMet) {
      recs.add(_Recommendation(
        title: 'Study: ${edu.program.title}',
        description: 'Complete your monthly study goal.',
        icon: Icons.school_rounded,
        energyCost: 20, // Constant cost
        onTap: () => widget.controller.studyEducation(),
        enabled: stats.energy >= 20,
      ));
    }

    // 4. Progress / Growth
    if (stats.stress < 40 && stats.energy > 40 && edu == null) {
      final selfStudy = allActions.where((a) => a.type == ActionType.selfStudy).firstOrNull;
      if (selfStudy != null && widget.controller.canPerform(selfStudy)) {
        recs.add(_Recommendation(
          title: selfStudy.title,
          description: selfStudy.description,
          icon: Icons.lightbulb_rounded,
          energyCost: selfStudy.energyCost,
          onTap: () => widget.controller.performAction(selfStudy),
          enabled: true,
        ));
      }
    }

    // 5. Job Search if unemployed
    if (state.currentJob == null && state.activeCompany == null) {
      recs.add(_Recommendation(
        title: 'Find a Job',
        description: 'You are unemployed. Search for new listings.',
        icon: Icons.search_rounded,
        energyCost: widget.controller.jobSearchEnergyCost,
        onTap: () => widget.controller.refreshJobListings(),
        enabled: stats.energy >= widget.controller.jobSearchEnergyCost,
      ));
    }

    return recs.take(3).toList();
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
            color: AppTheme.primary,
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

class _DecisionTile extends StatelessWidget {
  const _DecisionTile({
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final themeColor = color ?? AppTheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: themeColor.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: themeColor.withOpacity(0.2), width: 1.2),
        ),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, color: themeColor, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: enabled ? AppTheme.text : AppTheme.mutedText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (energyCost != null) ...[
                  const SizedBox(width: 12),
                  StatusChip(
                    label: '$energyCost EN',
                    color: enabled ? AppTheme.primary : AppTheme.mutedText,
                    icon: Icons.bolt_rounded,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
