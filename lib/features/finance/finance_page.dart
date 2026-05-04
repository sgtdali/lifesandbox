import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../game/state/game_scope.dart';
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
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Finance', style: textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Manage loans, emergency debt, and simple deposits.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          _OverviewCard(
            snapshot: snapshot,
          ),
          const SizedBox(height: 12),
          _ObligationsCard(snapshot: snapshot),
          const SizedBox(height: 22),
          Text('Active debts', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          if (debts.isEmpty)
            const _EmptyCard(text: 'No active debt.')
          else
            for (final debt in debts) ...[
              _DebtCard(debt: debt),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 14),
          if (debts.isNotEmpty) ...[
            Text('Pay down debt', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            _PaydownCard(
              cash: state.player.cash,
              onPay: (amount) async {
                final paid = await controller.payDownDebt(amount);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      paid
                          ? 'Debt reduced.'
                          : 'Not enough cash or no active debt.',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
          ],
          Text('Loan products', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          for (final loan in controller.loanProducts) ...[
            _LoanProductCard(
              loan: loan,
              onTake: () async {
                await controller.takeLoan(loan);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${loan.title} received.')),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),
          Text('Active deposits', style: textTheme.titleLarge),
          const SizedBox(height: 12),
          if (deposits.isEmpty)
            const _EmptyCard(text: 'No active deposits.')
          else
            for (final deposit in deposits) ...[
              _DepositCard(
                deposit: deposit,
                onWithdraw: deposit.isFlexible
                    ? () async {
                        final withdrawn =
                            await controller.withdrawDeposit(deposit);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              withdrawn
                                  ? '${deposit.title} withdrawn.'
                                  : 'This deposit cannot be withdrawn yet.',
                            ),
                          ),
                        );
                      }
                    : null,
              ),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 14),
          Text('Deposit products', style: textTheme.titleLarge),
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
                  SnackBar(
                    content: Text(
                      opened
                          ? '${product.title} opened.'
                          : 'Not enough cash for that deposit.',
                    ),
                  ),
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
  const _OverviewCard({
    required this.snapshot,
  });

  final FinanceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.surfaceRaised,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _FinanceRow(label: 'State', value: snapshot.label),
            _FinanceRow(label: 'Cash', value: '${snapshot.cash}'),
            _FinanceRow(label: 'Total debt', value: '${snapshot.totalDebt}'),
            _FinanceRow(
              label: 'Emergency debt',
              value: '${snapshot.emergencyDebt}',
            ),
            _FinanceRow(
              label: 'Monthly obligations',
              value: '${snapshot.totalMonthlyObligations}',
            ),
            _FinanceRow(
              label: 'Cushion',
              value: '${snapshot.cushionMonths.toStringAsFixed(1)} mo',
            ),
            _FinanceRow(label: 'Deposits', value: '${snapshot.totalDeposits}'),
            const SizedBox(height: 8),
            for (final signal in snapshot.signals)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(signal, style: Theme.of(context).textTheme.bodyMedium),
              ),
          ],
        ),
      ),
    );
  }
}

class _ObligationsCard extends StatelessWidget {
  const _ObligationsCard({required this.snapshot});

  final FinanceSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _FinanceRow(
              label: 'Life obligations',
              value: '${snapshot.monthlyLifeObligations}',
            ),
            _FinanceRow(
              label: 'Growth obligations',
              value: '${snapshot.monthlyGrowthObligations}',
            ),
            _FinanceRow(
              label: 'Debt payments',
              value: '${snapshot.monthlyDebtPayment}',
            ),
            _FinanceRow(
              label: 'Liquid deposits',
              value: '${snapshot.flexibleDeposits}',
            ),
            _FinanceRow(
              label: 'Locked deposits',
              value: '${snapshot.lockedDeposits}',
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtCard extends StatelessWidget {
  const _DebtCard({required this.debt});

  final ActiveDebt debt;

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
              children: [
                Expanded(child: Text(debt.title, style: textTheme.titleMedium)),
                if (debt.isEmergency)
                  const Icon(Icons.warning_rounded, color: AppTheme.red),
              ],
            ),
            const SizedBox(height: 10),
            _FinanceRow(label: 'Remaining', value: '${debt.remainingBalance}'),
            _FinanceRow(label: 'Monthly payment', value: '${debt.monthlyPayment}'),
            _FinanceRow(
              label: 'Type',
              value: debt.isEmergency ? 'Emergency priority' : 'Loan',
            ),
            _FinanceRow(
              label: 'Remaining months',
              value: debt.isEmergency ? 'Until cleared' : '${debt.remainingMonths}',
            ),
          ],
        ),
      ),
    );
  }
}

class _PaydownCard extends StatelessWidget {
  const _PaydownCard({
    required this.cash,
    required this.onPay,
  });

  final int cash;
  final ValueChanged<int> onPay;

  @override
  Widget build(BuildContext context) {
    final amounts = [25, 50, 100];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payments target emergency debt first, then the highest-pressure loan.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
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
          ],
        ),
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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(loan.title, style: textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(loan.description, style: textTheme.bodyMedium),
            const SizedBox(height: 10),
            _FinanceRow(label: 'Cash now', value: '+${loan.principal}'),
            _FinanceRow(
              label: 'Repayment',
              value: '${loan.monthlyPayment}/mo for ${loan.durationMonths} mo',
            ),
            _FinanceRow(label: 'Total repayment', value: '${loan.totalRepayment}'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onTake, child: const Text('Take Loan')),
          ],
        ),
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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(deposit.title, style: textTheme.titleMedium),
            const SizedBox(height: 10),
            _FinanceRow(label: 'Amount', value: '${deposit.amount}'),
            _FinanceRow(
              label: 'Liquidity',
              value: deposit.isFlexible ? 'Liquid' : 'Locked',
            ),
            _FinanceRow(
              label: 'Monthly return',
              value: '${deposit.monthlyReturnPercent}%',
            ),
            _FinanceRow(
              label: 'Status',
              value: deposit.isFlexible
                  ? 'Flexible'
                  : '${deposit.remainingMonths} mo locked',
            ),
            if (onWithdraw != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onWithdraw,
                child: const Text('Withdraw'),
              ),
            ],
          ],
        ),
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
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.title, style: textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(product.description, style: textTheme.bodyMedium),
            const SizedBox(height: 10),
            _FinanceRow(
              label: 'Return',
              value: '${product.monthlyReturnPercent}% monthly',
            ),
            _FinanceRow(
              label: 'Lock',
              value: product.isFlexible
                  ? 'Withdraw anytime'
                  : '${product.lockMonths} mo',
            ),
            const SizedBox(height: 12),
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
      ),
    );
  }
}

class _FinanceRow extends StatelessWidget {
  const _FinanceRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(child: Text(label, style: textTheme.bodyMedium)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: textTheme.labelLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }
}
