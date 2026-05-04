import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../game/models/game_state.dart';
import '../../../features/finance/models/finance_snapshot.dart';
import '../../../shared/widgets/metric_row.dart';
import '../../../shared/widgets/app_section_card.dart';

class CommitmentsSummary extends StatelessWidget {
  const CommitmentsSummary({
    super.key,
    required this.state,
    required this.finance,
    required this.companyOutlook,
  });

  final GameState state;
  final FinanceSnapshot finance;
  final String companyOutlook;

  @override
  Widget build(BuildContext context) {
    final player = state.player;
    final currentJob = state.currentJob;
    final housing = state.currentHousing;
    final activeEducation = state.activeEducation;
    final company = state.activeCompany;
    final textTheme = Theme.of(context).textTheme;

    final netMonth = currentJob == null
        ? -player.monthlyBaseExpense
        : (currentJob.monthlySalary - player.monthlyBaseExpense);

    return AppSectionCard(
      title: 'CURRENT COMMITMENTS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricRow(
            label: 'Job',
            value: currentJob?.title ?? 'Unemployed',
            valueColor: currentJob == null ? AppTheme.amber : AppTheme.text,
            icon: Icons.work_rounded,
          ),
          MetricRow(
            label: 'Housing',
            value: housing.title,
            valueColor: housing.id == 'shared_room' ? AppTheme.amber : AppTheme.text,
            icon: Icons.home_rounded,
          ),
          MetricRow(
            label: 'Education',
            value: activeEducation != null 
                ? '${activeEducation.program.title} (${activeEducation.completedMonths}/${activeEducation.program.durationMonths})' 
                : 'None',
            valueColor: activeEducation != null ? AppTheme.primary : AppTheme.mutedText,
            icon: Icons.school_rounded,
          ),
          MetricRow(
            label: 'Finance',
            value: finance.label,
            valueColor: AppTheme.green,
            icon: Icons.monetization_on_rounded,
          ),
          MetricRow(
            label: 'Company',
            value: company?.name ?? 'Not founded',
            valueColor: company == null ? AppTheme.mutedText : AppTheme.text,
            icon: Icons.business_rounded,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: AppTheme.border, height: 1),
          ),
          MetricRow(
            label: 'Monthly Net',
            value: '${netMonth >= 0 ? "+" : ""}$netMonth',
            valueColor: netMonth >= 0 ? AppTheme.green : AppTheme.red,
            icon: Icons.trending_up_rounded,
          ),
        ],
      ),
    );
  }
}

class _SubHeader extends StatelessWidget {
  const _SubHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.mutedText,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}
