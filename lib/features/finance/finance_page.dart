import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/metric_row.dart';
import '../../shared/widgets/status_chip.dart';
import 'models/active_debt.dart';
import 'models/active_deposit.dart';
import 'models/deposit_product.dart';
import 'models/finance_snapshot.dart';
import 'models/loan_product.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameScope.of(context);
    final state = controller.state;
    final debts = state.activeDebts;
    final deposits = state.activeDeposits;
    final snapshot = controller.financeSnapshot;
    final textTheme = Theme.of(context).textTheme;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Finance', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Manage loans, emergency debt, and simple deposits.', style: textTheme.bodyMedium),
          const SizedBox(height: 18),
          
          _OverviewCard(snapshot: snapshot),
          const SizedBox(height: 12),
          _ObligationsCard(snapshot: snapshot),
          const SizedBox(height: 22),
          
          Text('Active Debts', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          if (debts.isEmpty)
            const AppSectionCard(
              title: 'No Active Debt',
              icon: Icons.check_circle_rounded,
              iconColor: AppTheme.green,
              child: Text('You are completely debt free.'),
            )
          else
            for (final debt in debts) ...[
              _DebtCard(debt: debt),
              const SizedBox(height: 10),
            ],
            
          const SizedBox(height: 14),
          if (debts.isNotEmpty) ...[
            Text('Pay Down Debt', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            _PaydownCard(
              cash: state.player.cash,
              onPay: (amount) async {
                final paid = await controller.payDownDebt(amount);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(paid ? 'Debt reduced.' : 'Not enough cash or no active debt.')),
                );
              },
            ),
            const SizedBox(height: 14),
          ],
          
          Text('Loan Products', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final loan in controller.loanProducts) ...[
            _LoanProductCard(
              loan: loan,
              onTake: () async {
                await controller.takeLoan(loan);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loan.title} received.')));
              },
            ),
            const SizedBox(height: 10),
          ],
          
          const SizedBox(height: 14),
          Text('Active Deposits', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          if (deposits.isEmpty)
            const AppSectionCard(
              title: 'No Active Deposits',
              icon: Icons.savings_outlined,
              child: Text('Open a deposit to start earning interest.'),
            )
          else
            for (final deposit in deposits) ...[
              _DepositCard(
                deposit: deposit,
                onWithdraw: deposit.isFlexible
                    ? () async {
                        final withdrawn = await controller.withdrawDeposit(deposit);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(withdrawn ? '${deposit.title} withdrawn.' : 'This deposit cannot be withdrawn yet.')),
                        );
                      }
                    : null,
              ),
              const SizedBox(height: 10),
            ],
            
          const SizedBox(height: 14),
          Text('Deposit Products', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final product in controller.depositProducts) ...[
            _DepositProductCard(
              product: product,
              amounts: controller.depositAmounts,
              cash: state.player.cash,
              onOpen: (amount) async {
                final opened = await controller.openDeposit(product, amount);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(opened ? '${product.title} opened.' : 'Not enough cash for that deposit.')),
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

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.snapshot});

  final FinanceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Finance Overview',
      icon: Icons.account_balance_rounded,
      action: StatusChip(label: snapshot.label, color: AppTheme.primary),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricRow(label: 'Available Cash', value: '${snapshot.cash}', valueColor: AppTheme.green),
          MetricRow(label: 'Total Debt', value: '${snapshot.totalDebt}', valueColor: snapshot.totalDebt > 0 ? AppTheme.red : null),
          MetricRow(label: 'Emergency Debt', value: '${snapshot.emergencyDebt}', valueColor: snapshot.emergencyDebt > 0 ? AppTheme.red : null),
          MetricRow(label: 'Monthly Obligations', value: '${snapshot.totalMonthlyObligations}'),
          MetricRow(label: 'Safety Cushion', value: '${snapshot.cushionMonths.toStringAsFixed(1)} mo'),
          MetricRow(label: 'Total Deposits', value: '${snapshot.totalDeposits}', valueColor: AppTheme.primary),
          
          if (snapshot.signals.isNotEmpty) ...[
            const Divider(height: 24, color: AppTheme.border),
            for (final signal in snapshot.signals)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(signal, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.amber)),
              ),
          ],
        ],
      ),
    );
  }
}

class _ObligationsCard extends StatelessWidget {
  const _ObligationsCard({required this.snapshot});

  final FinanceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: 'Cash Flow Breakdown',
      icon: Icons.pie_chart_rounded,
      child: Column(
        children: [
          MetricRow(label: 'Life Obligations', value: '${snapshot.monthlyLifeObligations}', valueColor: AppTheme.amber),
          MetricRow(label: 'Growth Obligations', value: '${snapshot.monthlyGrowthObligations}', valueColor: AppTheme.primary),
          MetricRow(label: 'Debt Payments', value: '${snapshot.monthlyDebtPayment}', valueColor: AppTheme.red),
          const Divider(height: 24, color: AppTheme.border),
          MetricRow(label: 'Liquid Deposits', value: '${snapshot.flexibleDeposits}'),
          MetricRow(label: 'Locked Deposits', value: '${snapshot.lockedDeposits}'),
        ],
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({required this.debt});

  final ActiveDebt debt;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: debt.title,
      icon: debt.isEmergency ? Icons.warning_rounded : Icons.credit_card_rounded,
      iconColor: debt.isEmergency ? AppTheme.red : AppTheme.amber,
      action: debt.isEmergency ? StatusChip(label: 'Priority', color: AppTheme.red) : null,
      child: Column(
        children: [
          MetricRow(label: 'Remaining Balance', value: '${debt.remainingBalance}', valueColor: AppTheme.red),
          MetricRow(label: 'Monthly Payment', value: '${debt.monthlyPayment}'),
          MetricRow(label: 'Type', value: debt.isEmergency ? 'Emergency' : 'Standard Loan'),
          MetricRow(label: 'Remaining Term', value: debt.isEmergency ? 'Until Cleared' : '${debt.remainingMonths} mo'),
        ],
      ),
    );
  }
}

class _PaydownCard extends StatelessWidget {
  const _PaydownCard({required this.cash, required this.onPay});

  final int cash;
  final ValueChanged<int> onPay;

  @override
  Widget build(BuildContext context) {
    final amounts = [25, 50, 100];
    return AppSectionCard(
      title: 'Make Payment',
      subtitle: 'Targets emergency debt first, then highest-pressure loan.',
      icon: Icons.payments_rounded,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final amount in amounts)
            OutlinedButton(
              onPressed: cash >= amount ? () => onPay(amount) : null,
              child: Text('Pay $amount'),
            ),
        ],
      ),
    );
  }
}

class _LoanProductCard extends StatelessWidget {
  const _LoanProductCard({required this.loan, required this.onTake});

  final LoanProduct loan;
  final VoidCallback onTake;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: loan.title,
      subtitle: loan.description,
      icon: Icons.account_balance_rounded,
      child: Column(
        children: [
          MetricRow(label: 'Principal Received', value: '+${loan.principal}', valueColor: AppTheme.green),
          MetricRow(label: 'Repayment Terms', value: '${loan.monthlyPayment}/mo for ${loan.durationMonths} mo'),
          MetricRow(label: 'Total Repayment', value: '${loan.totalRepayment}', valueColor: AppTheme.red),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onTake, child: const Text('Take Loan')),
        ],
      ),
    );
  }
}

class _DepositCard extends StatelessWidget {
  const _DepositCard({required this.deposit, required this.onWithdraw});

  final ActiveDeposit deposit;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: deposit.title,
      icon: Icons.attach_money_rounded,
      iconColor: AppTheme.primary,
      action: StatusChip(label: deposit.isFlexible ? 'Liquid' : 'Locked', color: AppTheme.primary),
      child: Column(
        children: [
          MetricRow(label: 'Current Amount', value: '${deposit.amount}', valueColor: AppTheme.green),
          MetricRow(label: 'Monthly Return', value: '${deposit.monthlyReturnPercent}%', valueColor: AppTheme.green),
          MetricRow(label: 'Status', value: deposit.isFlexible ? 'Flexible Withdrawal' : '${deposit.remainingMonths} mo locked'),
          if (onWithdraw != null) ...[
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onWithdraw, child: const Text('Withdraw')),
          ],
        ],
      ),
    );
  }
}

class _DepositProductCard extends StatelessWidget {
  const _DepositProductCard({
    required this.product,
    required this.amounts,
    required this.cash,
    required this.onOpen,
  });

  final DepositProduct product;
  final List<int> amounts;
  final int cash;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: product.title,
      subtitle: product.description,
      icon: Icons.trending_up_rounded,
      iconColor: AppTheme.green,
      child: Column(
        children: [
          MetricRow(label: 'Return Rate', value: '${product.monthlyReturnPercent}% monthly', valueColor: AppTheme.green),
          MetricRow(label: 'Lock Period', value: product.isFlexible ? 'Withdraw Anytime' : '${product.lockMonths} mo'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final amount in amounts)
                OutlinedButton(
                  onPressed: cash >= amount ? () => onOpen(amount) : null,
                  child: Text('Deposit $amount'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
