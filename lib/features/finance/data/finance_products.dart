import '../models/deposit_product.dart';
import '../models/loan_product.dart';

const loanProducts = [
  LoanProduct(
    id: 'small_personal_loan',
    title: 'Small Personal Loan',
    principal: 180,
    durationMonths: 6,
    monthlyPayment: 34,
    description: 'A modest cushion with manageable monthly pressure.',
  ),
  LoanProduct(
    id: 'large_personal_loan',
    title: 'Large Personal Loan',
    principal: 420,
    durationMonths: 10,
    monthlyPayment: 50,
    description: 'A bigger safety buffer with a longer repayment tail.',
  ),
];

const depositProducts = [
  DepositProduct(
    id: 'flexible_deposit',
    title: 'Flexible Deposit',
    description: 'Low growth, but you can withdraw whenever needed.',
    monthlyReturnPercent: 1,
    lockMonths: 0,
    isFlexible: true,
  ),
  DepositProduct(
    id: 'term_deposit',
    title: 'Term Deposit',
    description: 'Locks cash for four months for a better return.',
    monthlyReturnPercent: 3,
    lockMonths: 4,
    isFlexible: false,
  ),
];

const depositQuickAmounts = [25, 50, 100];
