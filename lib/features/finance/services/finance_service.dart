import '../../../game/models/game_state.dart';
import '../data/finance_products.dart';
import '../models/active_debt.dart';
import '../models/active_deposit.dart';
import '../models/deposit_product.dart';
import '../models/loan_product.dart';

class FinanceService {
  const FinanceService();

  List<LoanProduct> get loans => loanProducts;
  List<DepositProduct> get deposits => depositProducts;

  GameState takeLoan(GameState state, LoanProduct product) {
    final debt = ActiveDebt(
      id: '${product.id}_${state.month}_${state.activeDebts.length}',
      title: product.title,
      remainingBalance: product.totalRepayment,
      monthlyPayment: product.monthlyPayment,
      remainingMonths: product.durationMonths,
      isEmergency: false,
    );

    return state.copyWith(
      player: state.player.copyWith(cash: state.player.cash + product.principal),
      activeDebts: [...state.activeDebts, debt],
      clearLastMonthResult: true,
    );
  }

  GameState openDeposit({
    required GameState state,
    required DepositProduct product,
    required int amount,
  }) {
    if (amount <= 0 || state.player.cash < amount) return state;

    final deposit = ActiveDeposit(
      id: '${product.id}_${state.month}_${state.activeDeposits.length}',
      title: product.title,
      amount: amount,
      monthlyReturnPercent: product.monthlyReturnPercent,
      remainingMonths: product.lockMonths,
      isFlexible: product.isFlexible,
    );

    return state.copyWith(
      player: state.player.copyWith(cash: state.player.cash - amount),
      activeDeposits: [...state.activeDeposits, deposit],
      clearLastMonthResult: true,
    );
  }

  GameState withdrawDeposit(GameState state, ActiveDeposit deposit) {
    if (!deposit.isFlexible) return state;

    return state.copyWith(
      player: state.player.copyWith(cash: state.player.cash + deposit.amount),
      activeDeposits:
          state.activeDeposits.where((item) => item.id != deposit.id).toList(),
      clearLastMonthResult: true,
    );
  }

  GameState payDownDebt(GameState state, int amount) {
    if (amount <= 0 || state.player.cash < amount || state.activeDebts.isEmpty) {
      return state;
    }

    var remainingPayment = amount;
    final orderedDebts = [...state.activeDebts]..sort((a, b) {
        if (a.isEmergency != b.isEmergency) return a.isEmergency ? -1 : 1;
        return b.monthlyPayment.compareTo(a.monthlyPayment);
      });
    final updated = <ActiveDebt>[];

    for (final debt in orderedDebts) {
      if (remainingPayment <= 0) {
        updated.add(debt);
        continue;
      }
      final payment = remainingPayment.clamp(0, debt.remainingBalance).toInt();
      remainingPayment -= payment;
      final balance = debt.remainingBalance - payment;
      if (balance > 0) {
        updated.add(debt.copyWith(remainingBalance: balance));
      }
    }

    return state.copyWith(
      player: state.player.copyWith(
        cash: state.player.cash - (amount - remainingPayment),
      ),
      activeDebts: updated,
      clearLastMonthResult: true,
    );
  }

  FinanceMonthResult resolveMonth(GameState state) {
    var cash = state.player.cash;
    var debtPaid = 0;
    var emergencyDebtCreated = 0;
    var emergencyDebtPaid = 0;
    var depositInterestEarned = 0;
    var maturedDepositPayout = 0;

    final nextDebts = <ActiveDebt>[];
    for (final debt in state.activeDebts) {
      final payment = debt.monthlyPayment.clamp(0, debt.remainingBalance).toInt();
      cash -= payment;
      debtPaid += payment;
      if (debt.isEmergency) emergencyDebtPaid += payment;

      final remainingBalance = debt.remainingBalance - payment;
      final remainingMonths = debt.isEmergency
          ? debt.remainingMonths
          : (debt.remainingMonths - 1).clamp(0, 999).toInt();

      if (remainingBalance > 0) {
        nextDebts.add(
          debt.copyWith(
            remainingBalance: remainingBalance,
            remainingMonths: remainingMonths,
          ),
        );
      }
    }

    if (cash < 0) {
      final shortage = -cash;
      cash = 0;
      emergencyDebtCreated = shortage;
      nextDebts.add(_emergencyDebt(shortage, state.month, nextDebts.length));
    }

    final aggressivePaydown = _automaticEmergencyPaydown(cash, nextDebts);
    cash = aggressivePaydown.cash;
    debtPaid += aggressivePaydown.paid;
    emergencyDebtPaid += aggressivePaydown.paid;
    nextDebts
      ..clear()
      ..addAll(aggressivePaydown.debts);

    final nextDeposits = <ActiveDeposit>[];
    for (final deposit in state.activeDeposits) {
      final interest = ((deposit.amount * deposit.monthlyReturnPercent) / 100)
          .round()
          .clamp(0, 9999)
          .toInt();
      final nextAmount = deposit.amount + interest;
      depositInterestEarned += interest;

      if (deposit.isFlexible) {
        nextDeposits.add(deposit.copyWith(amount: nextAmount));
      } else {
        final remainingMonths = deposit.remainingMonths - 1;
        if (remainingMonths <= 0) {
          cash += nextAmount;
          maturedDepositPayout += nextAmount;
        } else {
          nextDeposits.add(
            deposit.copyWith(
              amount: nextAmount,
              remainingMonths: remainingMonths,
            ),
          );
        }
      }
    }

    return FinanceMonthResult(
      cash: cash,
      activeDebts: nextDebts,
      activeDeposits: nextDeposits,
      debtPaid: debtPaid,
      emergencyDebtCreated: emergencyDebtCreated,
      emergencyDebtPaid: emergencyDebtPaid,
      depositInterestEarned: depositInterestEarned,
      maturedDepositPayout: maturedDepositPayout,
    );
  }

  ActiveDebt _emergencyDebt(int shortage, int month, int index) {
    final payment = (shortage / 3).ceil().clamp(16, 58).toInt();

    return ActiveDebt(
      id: 'emergency_${month}_$index',
      title: 'Emergency Debt',
      remainingBalance: shortage + (shortage / 5).ceil(),
      monthlyPayment: payment,
      remainingMonths: 0,
      isEmergency: true,
    );
  }

  _EmergencyPaydownResult _automaticEmergencyPaydown(
    int cash,
    List<ActiveDebt> debts,
  ) {
    final emergency = debts.where((debt) => debt.isEmergency).toList();
    if (emergency.isEmpty || cash <= 120) {
      return _EmergencyPaydownResult(cash: cash, debts: debts, paid: 0);
    }

    var available = ((cash - 120) / 2).floor().clamp(0, 120).toInt();
    var paid = 0;
    final nextDebts = <ActiveDebt>[];
    for (final debt in debts) {
      if (!debt.isEmergency || available <= 0) {
        nextDebts.add(debt);
        continue;
      }
      final payment = available.clamp(0, debt.remainingBalance).toInt();
      available -= payment;
      paid += payment;
      final balance = debt.remainingBalance - payment;
      if (balance > 0) nextDebts.add(debt.copyWith(remainingBalance: balance));
    }

    return _EmergencyPaydownResult(
      cash: cash - paid,
      debts: nextDebts,
      paid: paid,
    );
  }
}

class _EmergencyPaydownResult {
  const _EmergencyPaydownResult({
    required this.cash,
    required this.debts,
    required this.paid,
  });

  final int cash;
  final List<ActiveDebt> debts;
  final int paid;
}

class FinanceMonthResult {
  const FinanceMonthResult({
    required this.cash,
    required this.activeDebts,
    required this.activeDeposits,
    required this.debtPaid,
    required this.emergencyDebtCreated,
    required this.emergencyDebtPaid,
    required this.depositInterestEarned,
    required this.maturedDepositPayout,
  });

  final int cash;
  final List<ActiveDebt> activeDebts;
  final List<ActiveDeposit> activeDeposits;
  final int debtPaid;
  final int emergencyDebtCreated;
  final int emergencyDebtPaid;
  final int depositInterestEarned;
  final int maturedDepositPayout;
}
