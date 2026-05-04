import '../models/condition_effect.dart';
import '../models/ongoing_condition.dart';

class ConditionCatalog {
  const ConditionCatalog._();

  static OngoingCondition create(String id, {int? months}) {
    final template = _conditions[id]!;
    return template.copyWith(
      remainingMonths: months ?? template.remainingMonths,
    );
  }

  static bool contains(String id) => _conditions.containsKey(id);
}

const _conditions = <String, OngoingCondition>{
  'burnout_risk': OngoingCondition(
    id: 'burnout_risk',
    title: 'Burnout Risk',
    description: 'Stress is carrying over and weakening recovery.',
    effectHint: '+stress, weaker energy, worse work stability',
    remainingMonths: 3,
    effect: ConditionEffect(
      happiness: -1,
      stress: 3,
      energyRecovery: -8,
      jobPerformance: -8,
      companyHealth: -3,
    ),
    tone: ConditionTone.negative,
    source: 'High stress',
  ),
  'money_anxiety': OngoingCondition(
    id: 'money_anxiety',
    title: 'Money Anxiety',
    description: 'Debt and low cushion are making each month feel tighter.',
    effectHint: '+stress, -happiness',
    remainingMonths: 3,
    effect: ConditionEffect(happiness: -2, stress: 2),
    tone: ConditionTone.negative,
    source: 'Finance pressure',
  ),
  'good_routine': OngoingCondition(
    id: 'good_routine',
    title: 'Good Routine',
    description: 'A manageable rhythm is supporting daily life.',
    effectHint: '-stress, +health, better energy',
    remainingMonths: 2,
    effect: ConditionEffect(
      health: 1,
      happiness: 1,
      stress: -2,
      energyRecovery: 4,
    ),
    tone: ConditionTone.positive,
    source: 'Stable month',
  ),
  'focused_learning': OngoingCondition(
    id: 'focused_learning',
    title: 'Focused Learning',
    description: 'Study habits are carrying momentum into the next month.',
    effectHint: '+study progress, slight +intelligence',
    remainingMonths: 2,
    effect: ConditionEffect(
      intelligence: 1,
      stress: 1,
      studyProgressBonus: 5,
    ),
    tone: ConditionTone.positive,
    source: 'Education focus',
  ),
  'stable_housing_boost': OngoingCondition(
    id: 'stable_housing_boost',
    title: 'Stable Living',
    description: 'Your housing situation is helping recovery feel steadier.',
    effectHint: '+happiness, -stress, better energy',
    remainingMonths: 2,
    effect: ConditionEffect(
      happiness: 1,
      stress: -1,
      energyRecovery: 2,
    ),
    tone: ConditionTone.positive,
    source: 'Housing stability',
  ),
  'poor_sleep_cycle': OngoingCondition(
    id: 'poor_sleep_cycle',
    title: 'Poor Sleep Cycle',
    description: 'Bad rest is making the next month harder to manage.',
    effectHint: '+stress, -health, weaker energy',
    remainingMonths: 2,
    effect: ConditionEffect(
      health: -1,
      stress: 2,
      energyRecovery: -7,
      jobPerformance: -3,
    ),
    tone: ConditionTone.negative,
    source: 'Weak recovery',
  ),
  'career_momentum': OngoingCondition(
    id: 'career_momentum',
    title: 'Career Momentum',
    description: 'Work stability is improving confidence and performance.',
    effectHint: '+performance, +reliability',
    remainingMonths: 2,
    effect: ConditionEffect(
      happiness: 1,
      reliability: 1,
      jobPerformance: 6,
    ),
    tone: ConditionTone.positive,
    source: 'Strong job performance',
  ),
  'business_strain': OngoingCondition(
    id: 'business_strain',
    title: 'Business Strain',
    description: 'The company is pulling extra pressure into personal life.',
    effectHint: '+stress, weaker company health/momentum',
    remainingMonths: 2,
    effect: ConditionEffect(
      stress: 3,
      companyHealth: -4,
      companyMomentum: -4,
    ),
    tone: ConditionTone.negative,
    source: 'Company pressure',
  ),
  'recovery_phase': OngoingCondition(
    id: 'recovery_phase',
    title: 'Recovery Phase',
    description: 'Lower pressure is letting health and stress recover.',
    effectHint: '+health, -stress, better energy',
    remainingMonths: 2,
    effect: ConditionEffect(
      health: 2,
      stress: -3,
      energyRecovery: 3,
    ),
    tone: ConditionTone.positive,
    source: 'Recovery-oriented month',
  ),
  'social_uplift': OngoingCondition(
    id: 'social_uplift',
    title: 'Social Uplift',
    description: 'A better mood is making life feel more manageable.',
    effectHint: '+happiness, +reliability, -stress',
    remainingMonths: 2,
    effect: ConditionEffect(
      happiness: 2,
      stress: -1,
      reliability: 1,
    ),
    tone: ConditionTone.positive,
    source: 'Positive mood',
  ),
};
