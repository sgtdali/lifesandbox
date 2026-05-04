class GameBalance {
  const GameBalance._();

  static const startingMonth = 1;
  static const startingCash = 300; 
  static const baseMonthlyExpense = 82; 
  static const startingMaxEnergy = 100;

  // Finance Tuning
  static const emergencyDebtInterestMultiplier = 1.25; // Principal * 1.25
  static const emergencyDebtMinPayment = 24; 
  static const cashSafetyBuffer = 150; 

  // Job Tuning
  static const starterJobSalaryMultiplier = 0.92; 

  // Company Tuning
  static const earlyCompanyOperatingCostMultiplier = 1.15; 
  static const earlyCompanyRevenueMultiplier = 0.95; 
  static const companyStartupCostMultiplier = 1.05; 
}
