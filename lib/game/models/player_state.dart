import '../../core/constants/game_balance.dart';
import 'core_stats.dart';
import 'reliability_level.dart';

class PlayerState {
  const PlayerState({
    required this.cash,
    required this.monthlyBaseExpense,
    required this.occupation,
    required this.reliabilityScore,
    required this.stats,
  });

  final int cash;
  final int monthlyBaseExpense;
  final String occupation;
  final int reliabilityScore;
  final CoreStats stats;

  ReliabilityLevel get reliability => ReliabilityLevel.fromScore(
        reliabilityScore,
      );

  factory PlayerState.initial() {
    return PlayerState(
      cash: GameBalance.startingCash,
      monthlyBaseExpense: GameBalance.baseMonthlyExpense,
      occupation: 'Unemployed',
      reliabilityScore: 58,
      stats: CoreStats.initial(),
    );
  }

  PlayerState copyWith({
    int? cash,
    int? monthlyBaseExpense,
    String? occupation,
    int? reliabilityScore,
    CoreStats? stats,
  }) {
    return PlayerState(
      cash: cash ?? this.cash,
      monthlyBaseExpense: monthlyBaseExpense ?? this.monthlyBaseExpense,
      occupation: occupation ?? this.occupation,
      reliabilityScore: reliabilityScore ?? this.reliabilityScore,
      stats: stats ?? this.stats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cash': cash,
      'monthlyBaseExpense': monthlyBaseExpense,
      'occupation': occupation,
      'reliabilityScore': reliabilityScore,
      'stats': stats.toJson(),
    };
  }

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    final legacyOccupation = json['occupation'] as String?;

    return PlayerState(
      cash: json['cash'] as int? ?? GameBalance.startingCash,
      monthlyBaseExpense:
          json['monthlyBaseExpense'] as int? ?? GameBalance.baseMonthlyExpense,
      occupation: legacyOccupation == null || legacyOccupation.isEmpty
          ? 'Unemployed'
          : legacyOccupation,
      reliabilityScore: json['reliabilityScore'] as int? ?? 58,
      stats: CoreStats.fromJson(
        Map<String, dynamic>.from(json['stats'] as Map? ?? {}),
      ),
    );
  }
}
