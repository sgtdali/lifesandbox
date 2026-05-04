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
      title: 'Life & Finance',
      icon: Icons.account_balance_wallet_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // This Month Section
          _SubHeader('THIS MONTH'),
          const SizedBox(height: 8),
          MetricRow(
            label: 'Cash on Hand',
            value: '${player.cash}',
            valueColor: player.cash >= 100 ? AppTheme.green : (player.cash >= 0 ? AppTheme.amber : AppTheme.red),
            icon: Icons.attach_money_rounded,
          ),
          MetricRow(
            label: 'Net Cash Flow',
            value: '${netMonth >= 0 ? "+" : ""}$netMonth',
            valueColor: netMonth >= 0 ? AppTheme.green : AppTheme.amber,
            icon: Icons.receipt_long_rounded,
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppTheme.border, height: 1),
          ),
          
          // Current Commitments Section
          _SubHeader('COMMITMENTS'),
          const SizedBox(height: 8),
          MetricRow(
            label: 'Occupation',
            value: currentJob?.title ?? 'Unemployed',
            valueColor: currentJob == null ? AppTheme.amber : AppTheme.text,
            icon: currentJob == null ? Icons.work_off_rounded : Icons.badge_rounded,
          ),
          MetricRow(
            label: 'Housing',
            value: housing.title,
            icon: Icons.home_rounded,
          ),
          MetricRow(
            label: 'Finance State',
            value: finance.label,
            valueColor: finance.emergencyDebt > 0
                ? AppTheme.red
                : (finance.tier == FinanceStateTier.pressured ||
                        finance.tier == FinanceStateTier.fragile
                    ? AppTheme.amber
                    : AppTheme.text),
            icon: Icons.account_balance_rounded,
          ),
          if (activeEducation != null)
            MetricRow(
              label: 'Education',
              value: '${activeEducation.program.title} (${activeEducation.completedMonths}/${activeEducation.program.durationMonths}m)',
              valueColor: activeEducation.studyRequirementMet ? AppTheme.green : AppTheme.amber,
              icon: Icons.school_rounded,
            ),
          if (company != null)
            MetricRow(
              label: 'Company',
              value: '$companyOutlook outlook',
              valueColor: company.health > 70 ? AppTheme.green : (company.health < 40 ? AppTheme.red : AppTheme.amber),
              icon: Icons.business_center_rounded,
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
