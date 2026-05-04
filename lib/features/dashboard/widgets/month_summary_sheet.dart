import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../game/models/month_result.dart';
import '../../../shared/widgets/app_section_card.dart';
import '../../../shared/widgets/metric_row.dart';

Future<void> showMonthSummarySheet(
  BuildContext context,
  MonthResult result,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) => _MonthSummarySheet(result: result),
  );
}

class _MonthSummarySheet extends StatelessWidget {
  const _MonthSummarySheet({required this.result});

  final MonthResult result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Month ${result.previousMonth}',
                          style: textTheme.titleLarge,
                        ),
                        _OutcomePill(result: result),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Main Highlight
                    _HighlightCard(result: result),
                    const SizedBox(height: 16),

                    _buildSection(
                      title: 'Cash Flow',
                      icon: Icons.attach_money_rounded,
                      rows: [
                        _SummaryRowData('Cash Before', '${result.cashBefore}'),
                        if (result.salaryEarned > 0) _SummaryRowData('Job Salary', '+${result.salaryEarned}', AppTheme.green),
                        if (result.companyRevenue > 0) _SummaryRowData('${result.companyName ?? 'Company'} Revenue', '+${result.companyRevenue}', AppTheme.green),
                        if (result.maturedDepositPayout > 0) _SummaryRowData('Deposit Matured', '+${result.maturedDepositPayout}', AppTheme.green),
                        _SummaryRowData('Net Change', '${result.cashChange}', result.cashChange >= 0 ? AppTheme.green : AppTheme.red),
                        _SummaryRowData('Cash After', '${result.cashAfter}'),
                      ],
                    ),

                    _buildSection(
                      title: 'Expenses',
                      icon: Icons.receipt_long_rounded,
                      rows: [
                        if (result.educationCostPaid > 0) _SummaryRowData('Education', '-${result.educationCostPaid}', AppTheme.red),
                        _SummaryRowData('Personal Expense', '-${result.baseExpense}', AppTheme.red),
                        if (result.housingCostPaid > 0) _SummaryRowData(result.housingTitle ?? 'Housing', '-${result.housingCostPaid}', AppTheme.red),
                        if (result.companyOperatingCost > 0) _SummaryRowData('${result.companyName ?? 'Company'} Ops', '-${result.companyOperatingCost}', AppTheme.red),
                      ],
                    ),

                    if (result.debtPaid > 0 || result.emergencyDebtCreated > 0 || result.depositInterestEarned > 0)
                      _buildSection(
                        title: 'Finance',
                        icon: Icons.account_balance_rounded,
                        rows: [
                          if (result.debtPaid > 0) _SummaryRowData('Debt Paid', '-${result.debtPaid}'),
                          if (result.emergencyDebtCreated > 0) _SummaryRowData('Emergency Debt', '+${result.emergencyDebtCreated}', AppTheme.red),
                          if (result.emergencyDebtPaid > 0) _SummaryRowData('Emergency Portion', '${result.emergencyDebtPaid}'),
                          if (result.depositInterestEarned > 0) _SummaryRowData('Deposit Growth', '+${result.depositInterestEarned}', AppTheme.green),
                        ],
                      ),

                    _buildSection(
                      title: 'Progress',
                      icon: Icons.trending_up_rounded,
                      rows: [
                        _SummaryRowData('Wellbeing', result.wellbeingLabel),
                        if (result.educationStudyRequired > 0) _SummaryRowData('Education Study', '${result.educationStudyApplied}/${result.educationStudyRequired}'),
                        if (result.educationProgressAdvanced) const _SummaryRowData('Education Progress', '+1 month', AppTheme.primary),
                        if (result.completedEducationTitle != null) _SummaryRowData('Completed', result.completedEducationTitle!, AppTheme.green),
                        if (result.jobEnergyLoad > 0) _SummaryRowData('Job Energy Load', '-${result.jobEnergyLoad} EN', AppTheme.amber),
                        if (result.housingEnergyModifier != 0) _SummaryRowData('Housing Recovery', '${result.housingEnergyModifier} EN', AppTheme.green),
                        if (result.conditionEnergyModifier != 0) _SummaryRowData('Condition Effect', '${result.conditionEnergyModifier} EN'),
                        if (result.wellbeingEnergyModifier != 0) _SummaryRowData('Wellbeing Effect', '${result.wellbeingEnergyModifier} EN'),
                        if (result.companyName != null) _SummaryRowData('Company Net', '${result.companyNet}', result.companyNet >= 0 ? AppTheme.green : AppTheme.red),
                      ],
                    ),

                    if (result.gainedConditions.isNotEmpty || result.expiredConditions.isNotEmpty)
                      _buildSection(
                        title: 'Conditions',
                        icon: Icons.healing_rounded,
                        rows: [
                          for (final title in result.gainedConditions) _SummaryRowData('Gained', title, AppTheme.amber),
                          for (final title in result.expiredConditions) _SummaryRowData('Expired', title, AppTheme.green),
                        ],
                      ),
                      
                    _buildSection(
                      title: 'Stats Changed',
                      icon: Icons.bar_chart_rounded,
                      rows: [
                        for (final change in result.statChanges.where((c) => c.hasChange))
                          _SummaryRowData(change.label, change.amount > 0 ? '+${change.amount}' : '${change.amount}', change.amount > 0 ? AppTheme.green : AppTheme.red),
                      ],
                    ),

                    if (result.messages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      for (final message in result.messages)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(message, style: textTheme.bodyMedium),
                        ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<_SummaryRowData> rows,
  }) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppSectionCard(
        title: title,
        icon: icon,
        iconColor: AppTheme.text,
        child: Column(
          children: rows.map((r) => MetricRow(
            label: r.label,
            value: r.value,
            valueColor: r.color,
          )).toList(),
        ),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({required this.result});
  final MonthResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Net Change', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  '${result.cashChange >= 0 ? '+' : ''}${result.cashChange}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: result.cashChange >= 0 ? AppTheme.green : AppTheme.red,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppTheme.border,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cash After', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  '${result.cashAfter}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomePill extends StatelessWidget {
  const _OutcomePill({required this.result});

  final MonthResult result;

  @override
  Widget build(BuildContext context) {
    final outcome = _outcome();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: outcome.color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: outcome.color.withOpacity(0.45)),
      ),
      child: Text(
        outcome.label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: outcome.color,
            ),
      ),
    );
  }

  _Outcome _outcome() {
    if (result.emergencyDebtCreated > 0 ||
        result.cashAfter < 50 ||
        result.cashChange <= -120) {
      return const _Outcome('Rough Month', AppTheme.red);
    }
    if (result.cashChange >= 90 ||
        result.companyNet >= 60 ||
        result.completedEducationTitle != null) {
      return const _Outcome('Strong Month', AppTheme.green);
    }
    if (result.cashChange >= 0 || result.educationProgressAdvanced) {
      return const _Outcome('Good Month', AppTheme.primary);
    }
    return const _Outcome('Stable Month', AppTheme.amber);
  }
}

class _Outcome {
  const _Outcome(this.label, this.color);

  final String label;
  final Color color;
}

class _SummaryRowData {
  const _SummaryRowData(this.label, this.value, [this.color]);

  final String label;
  final String value;
  final Color? color;
}
