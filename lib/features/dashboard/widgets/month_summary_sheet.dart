import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../game/models/month_result.dart';

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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Month ${result.previousMonth} summary',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _OutcomePill(result: result),
            const SizedBox(height: 14),
            _SummarySection(
              title: 'Cash flow',
              rows: [
                _SummaryRowData('Cash before', '${result.cashBefore}'),
                if (result.salaryEarned > 0)
                  _SummaryRowData('Job salary', '+${result.salaryEarned}'),
                if (result.companyRevenue > 0)
                  _SummaryRowData(
                    '${result.companyName ?? 'Company'} revenue',
                    '+${result.companyRevenue}',
                  ),
                if (result.maturedDepositPayout > 0)
                  _SummaryRowData(
                    'Deposit matured',
                    '+${result.maturedDepositPayout}',
                  ),
                _SummaryRowData('Net month', '${result.cashChange}'),
                _SummaryRowData('Cash after', '${result.cashAfter}'),
              ],
            ),
            const SizedBox(height: 10),
            _SummarySection(
              title: 'Expenses',
              rows: [
                if (result.educationCostPaid > 0)
                  _SummaryRowData(
                    'Education cost',
                    '-${result.educationCostPaid}',
                  ),
                _SummaryRowData('Personal expense', '-${result.baseExpense}'),
                if (result.housingCostPaid > 0)
                  _SummaryRowData(
                    result.housingTitle ?? 'Housing',
                    '-${result.housingCostPaid}',
                  ),
                if (result.companyOperatingCost > 0)
                  _SummaryRowData(
                    '${result.companyName ?? 'Company'} operating cost',
                    '-${result.companyOperatingCost}',
                  ),
              ],
            ),
            if (result.debtPaid > 0 ||
                result.emergencyDebtCreated > 0 ||
                result.depositInterestEarned > 0) ...[
              const SizedBox(height: 10),
              _SummarySection(
                title: 'Finance',
                rows: [
                  if (result.debtPaid > 0)
                    _SummaryRowData('Debt payments', '-${result.debtPaid}'),
                  if (result.emergencyDebtCreated > 0)
                    _SummaryRowData(
                      'Emergency debt',
                      '+${result.emergencyDebtCreated}',
                    ),
                  if (result.emergencyDebtPaid > 0)
                    _SummaryRowData(
                      'Emergency portion',
                      '${result.emergencyDebtPaid}',
                    ),
                  if (result.depositInterestEarned > 0)
                    _SummaryRowData(
                      'Deposit growth',
                      '+${result.depositInterestEarned}',
                    ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            _SummarySection(
              title: 'Progress',
              rows: [
                _SummaryRowData('Wellbeing', result.wellbeingLabel),
                if (result.educationStudyRequired > 0)
                  _SummaryRowData(
                    'Education study',
                    '${result.educationStudyApplied}/${result.educationStudyRequired}',
                  ),
                if (result.educationProgressAdvanced)
                  const _SummaryRowData('Education progress', '+1 month'),
                if (result.completedEducationTitle != null)
                  _SummaryRowData(
                    'Education completed',
                    result.completedEducationTitle!,
                  ),
                if (result.jobEnergyLoad > 0)
                  _SummaryRowData('Job energy load', '-${result.jobEnergyLoad} EN'),
                if (result.housingEnergyModifier != 0)
                  _SummaryRowData(
                    'Total energy recovery',
                    '${result.housingEnergyModifier} EN',
                  ),
                if (result.conditionEnergyModifier != 0)
                  _SummaryRowData(
                    'Condition recovery',
                    '${result.conditionEnergyModifier} EN',
                  ),
                if (result.wellbeingEnergyModifier != 0)
                  _SummaryRowData(
                    'Wellbeing recovery',
                    '${result.wellbeingEnergyModifier} EN',
                  ),
                if (result.companyName != null)
                  _SummaryRowData('Company net', '${result.companyNet}'),
                if (result.companyHealthDelta != 0)
                  _SummaryRowData(
                    'Company health',
                    '${result.companyHealthDelta}',
                  ),
                if (result.companyMomentumDelta != 0)
                  _SummaryRowData(
                    'Company momentum',
                    '${result.companyMomentumDelta}',
                  ),
                if (result.companyPipelineDelta != 0)
                  _SummaryRowData(
                    'Company pipeline',
                    '${result.companyPipelineDelta}',
                  ),
                if (result.companyOperationsDelta != 0)
                  _SummaryRowData(
                    'Company operations',
                    '${result.companyOperationsDelta}',
                  ),
              ],
              emptyText: 'No special progress changes this month.',
            ),
            if (result.gainedConditions.isNotEmpty ||
                result.expiredConditions.isNotEmpty) ...[
              const SizedBox(height: 10),
              _SummarySection(
                title: 'Conditions',
                rows: [
                  for (final title in result.gainedConditions)
                    _SummaryRowData('Gained', title),
                  for (final title in result.expiredConditions)
                    _SummaryRowData('Expired', title),
                ],
              ),
            ],
            const SizedBox(height: 10),
            _StatSection(result: result),
            if (result.messages.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final message in result.messages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(message, style: textTheme.bodyMedium),
                ),
            ],
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
          ],
        ),
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
  const _SummaryRowData(this.label, this.value);

  final String label;
  final String value;
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({
    required this.title,
    required this.rows,
    this.emptyText,
  });

  final String title;
  final List<_SummaryRowData> rows;
  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final visibleRows = rows.where((row) => row.value.isNotEmpty).toList();

    return Card(
      color: AppTheme.surfaceRaised,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            if (visibleRows.isEmpty)
              Text(emptyText ?? 'No entries.', style: textTheme.bodyMedium)
            else
              for (final row in visibleRows)
                _SummaryRow(label: row.label, value: row.value),
          ],
        ),
      ),
    );
  }
}

class _StatSection extends StatelessWidget {
  const _StatSection({required this.result});

  final MonthResult result;

  @override
  Widget build(BuildContext context) {
    final statChanges = result.statChanges.where((change) => change.hasChange);

    return _SummarySection(
      title: 'Stats',
      rows: [
        for (final change in statChanges)
          _SummaryRowData(change.label, '${change.amount}'),
      ],
      emptyText: 'No monthly stat changes were applied.',
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          Text(value, style: textTheme.titleMedium),
        ],
      ),
    );
  }
}
