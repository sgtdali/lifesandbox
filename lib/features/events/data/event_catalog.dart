import '../models/event_choice.dart';
import '../models/event_effect.dart';
import '../models/life_event.dart';

const eventCatalog = [
  LifeEvent(
    id: 'minor_cold',
    title: 'Feeling Run Down',
    description:
        'You wake up with a sore throat and low energy. It is not serious, but your body is asking for a slower month.',
    category: 'Health',
    weight: 10,
    condition: EventCondition.always,
    choices: [
      EventChoice(
        id: 'rest',
        label: 'Take it easy',
        resultText: 'You slow down and recover before it gets worse.',
        effect: EventEffect(health: 2, stress: -2, happiness: -1),
      ),
      EventChoice(
        id: 'push',
        label: 'Push through',
        resultText: 'You keep moving, but the fatigue lingers.',
        effect: EventEffect(health: -4, stress: 3),
      ),
    ],
  ),
  LifeEvent(
    id: 'unexpected_bill',
    title: 'Unexpected Bill',
    description:
        'A small forgotten bill arrives. It is annoying, but manageable.',
    category: 'Finance',
    weight: 11,
    condition: EventCondition.always,
    choices: [
      EventChoice(
        id: 'pay',
        label: 'Pay it',
        resultText: 'You clear the bill and move on.',
        effect: EventEffect(cash: -45, stress: 2),
      ),
    ],
  ),
  LifeEvent(
    id: 'good_conversation',
    title: 'Good Conversation',
    description:
        'A calm conversation with someone you trust gives you perspective.',
    category: 'Social',
    weight: 9,
    condition: EventCondition.always,
    choices: [
      EventChoice(
        id: 'appreciate',
        label: 'Appreciate it',
        resultText: 'You feel steadier afterward.',
        effect: EventEffect(happiness: 4, stress: -3),
      ),
    ],
  ),
  LifeEvent(
    id: 'discount_month',
    title: 'Useful Discount',
    description:
        'You catch a practical discount on routine monthly needs.',
    category: 'Finance',
    weight: 8,
    condition: EventCondition.always,
    choices: [
      EventChoice(
        id: 'save',
        label: 'Take the savings',
        resultText: 'A small win, but still a win.',
        effect: EventEffect(cash: 12, happiness: 1),
      ),
    ],
  ),
  LifeEvent(
    id: 'bad_sleep',
    title: 'Bad Sleep Streak',
    description:
        'A few restless nights make the month feel heavier than usual.',
    category: 'Stress',
    weight: 10,
    condition: EventCondition.always,
    choices: [
      EventChoice(
        id: 'reset',
        label: 'Reset routine',
        resultText: 'You make a few small changes and regain control.',
        effect: EventEffect(stress: -1, happiness: 1),
      ),
      EventChoice(
        id: 'ignore',
        label: 'Ignore it',
        resultText: 'The poor sleep catches up with you.',
        effect: EventEffect(health: -2, stress: 4),
      ),
    ],
  ),
  LifeEvent(
    id: 'confidence_boost',
    title: 'Confidence Boost',
    description:
        'Something clicks this month. You feel a little more capable than before.',
    category: 'Personal',
    weight: 7,
    condition: EventCondition.always,
    choices: [
      EventChoice(
        id: 'carry',
        label: 'Carry it forward',
        resultText: 'The momentum helps your attitude.',
        effect: EventEffect(happiness: 3, reliability: 1),
      ),
    ],
  ),
  LifeEvent(
    id: 'extra_shift_pressure',
    title: 'Extra Shift Pressure',
    description:
        'Your workplace asks for extra help. It would be tiring, but the money would help.',
    category: 'Job',
    weight: 10,
    condition: EventCondition.employed,
    choices: [
      EventChoice(
        id: 'accept',
        label: 'Accept extra work',
        resultText: 'You earn a little more, but it takes a toll.',
        effect: EventEffect(cash: 24, stress: 4, health: -1),
      ),
      EventChoice(
        id: 'decline',
        label: 'Decline politely',
        resultText: 'You protect your balance and keep things professional.',
        effect: EventEffect(stress: -2, reliability: -1),
      ),
    ],
  ),
  LifeEvent(
    id: 'work_praise',
    title: 'Workplace Praise',
    description:
        'Someone at work notices that you handled your responsibilities well.',
    category: 'Job',
    weight: 8,
    condition: EventCondition.employed,
    choices: [
      EventChoice(
        id: 'thanks',
        label: 'Build on it',
        resultText: 'You feel a bit more trusted.',
        effect: EventEffect(happiness: 2, reliability: 3),
      ),
    ],
  ),
  LifeEvent(
    id: 'job_irritation',
    title: 'Workplace Friction',
    description:
        'A small misunderstanding at work makes the week more stressful.',
    category: 'Job',
    weight: 7,
    condition: EventCondition.employed,
    choices: [
      EventChoice(
        id: 'smooth',
        label: 'Smooth it over',
        resultText: 'You handle it carefully.',
        effect: EventEffect(stress: 2, reliability: 1),
      ),
      EventChoice(
        id: 'vent',
        label: 'Vent about it',
        resultText: 'It feels good briefly, but does not help your image.',
        effect: EventEffect(stress: -1, reliability: -2),
      ),
    ],
  ),
  LifeEvent(
    id: 'restless_unemployed',
    title: 'Restless Afternoon',
    description:
        'Without a job structure, the days feel a little loose and uncertain.',
    category: 'Unemployment',
    weight: 12,
    condition: EventCondition.unemployed,
    choices: [
      EventChoice(
        id: 'organize',
        label: 'Organize your week',
        resultText: 'A simple plan makes things feel less vague.',
        effect: EventEffect(stress: -2, reliability: 2),
      ),
      EventChoice(
        id: 'drift',
        label: 'Let it pass',
        resultText: 'The uncertainty hangs around.',
        effect: EventEffect(happiness: -2, stress: 3),
      ),
    ],
  ),
  LifeEvent(
    id: 'small_opportunity',
    title: 'Small Paid Favor',
    description:
        'Someone offers a simple one-off task. It is not a real job, but it pays.',
    category: 'Opportunity',
    weight: 8,
    condition: EventCondition.unemployed,
    choices: [
      EventChoice(
        id: 'do_it',
        label: 'Do the task',
        resultText: 'You complete it and get paid.',
        effect: EventEffect(cash: 15, stress: 3, reliability: 1),
      ),
      EventChoice(
        id: 'skip',
        label: 'Skip it',
        resultText: 'You keep the month lighter.',
        effect: EventEffect(stress: -1),
      ),
    ],
  ),
  LifeEvent(
    id: 'study_motivation',
    title: 'Study Motivation',
    description:
        'A small breakthrough makes your education program feel more worthwhile.',
    category: 'Education',
    weight: 12,
    condition: EventCondition.activeEducation,
    choices: [
      EventChoice(
        id: 'lean_in',
        label: 'Lean into it',
        resultText: 'The momentum sharpens your focus.',
        effect: EventEffect(intelligence: 2, happiness: 1),
      ),
    ],
  ),
  LifeEvent(
    id: 'course_friction',
    title: 'Course Friction',
    description:
        'This month, the material feels more frustrating than expected.',
    category: 'Education',
    weight: 9,
    condition: EventCondition.activeEducation,
    choices: [
      EventChoice(
        id: 'practice',
        label: 'Practice patiently',
        resultText: 'It is slow, but you stay with it.',
        effect: EventEffect(stress: 2, intelligence: 1),
      ),
      EventChoice(
        id: 'step_back',
        label: 'Step back',
        resultText: 'You avoid burnout, but lose some momentum.',
        effect: EventEffect(stress: -2, happiness: -1),
      ),
    ],
  ),
  LifeEvent(
    id: 'housing_noise',
    title: 'Noisy Living Space',
    description:
        'Your housing situation makes it harder than usual to fully relax.',
    category: 'Housing',
    weight: 13,
    condition: EventCondition.lowQualityHousing,
    choices: [
      EventChoice(
        id: 'cope',
        label: 'Cope with it',
        resultText: 'You get through the month, but it is draining.',
        effect: EventEffect(stress: 4, happiness: -2),
      ),
      EventChoice(
        id: 'set_boundary',
        label: 'Set boundaries',
        resultText: 'It takes effort, but the situation improves a little.',
        effect: EventEffect(stress: 1, reliability: 1),
      ),
    ],
  ),
  LifeEvent(
    id: 'stress_warning',
    title: 'Stress Warning Signs',
    description:
        'Your stress is showing up in small ways. This is a good moment to adjust.',
    category: 'Health',
    weight: 14,
    condition: EventCondition.highStress,
    choices: [
      EventChoice(
        id: 'slow_down',
        label: 'Slow down',
        resultText: 'You give yourself room to stabilize.',
        effect: EventEffect(stress: -6, happiness: 1),
      ),
      EventChoice(
        id: 'keep_pushing',
        label: 'Keep pushing',
        resultText: 'You hold pace, but your body complains.',
        effect: EventEffect(health: -3, stress: 3, reliability: 1),
      ),
    ],
  ),
  LifeEvent(
    id: 'lucky_find',
    title: 'Lucky Find',
    description:
        'You sell something you no longer need and free up a little cash.',
    category: 'Finance',
    weight: 6,
    condition: EventCondition.always,
    choices: [
      EventChoice(
        id: 'sell',
        label: 'Take the cash',
        resultText: 'A small boost lands at the right time.',
        effect: EventEffect(cash: 18, happiness: 1),
      ),
    ],
  ),
  LifeEvent(
    id: 'burnout_edge',
    title: 'Close to the Edge',
    description:
        'The month starts with that brittle feeling where even small tasks seem loud.',
    category: 'Wellbeing',
    weight: 18,
    condition: EventCondition.wellbeingPressure,
    tone: EventTone.negative,
    contextConditionIds: ['burnout_risk', 'poor_sleep_cycle'],
    triggerHint: 'Triggered by current wellbeing pressure.',
    choices: [
      EventChoice(
        id: 'protect',
        label: 'Protect your pace',
        resultText: 'You lower the pressure before it snowballs.',
        effect: EventEffect(
          stress: -5,
          happiness: 1,
          addConditionIds: ['recovery_phase'],
          removeConditionIds: ['poor_sleep_cycle'],
        ),
      ),
      EventChoice(
        id: 'force',
        label: 'Force the pace',
        resultText: 'You get through it, but the strain follows you.',
        effect: EventEffect(
          health: -3,
          stress: 4,
          addConditionIds: ['burnout_risk'],
          followUpEventId: 'burnout_followup',
          followUpDelayMonths: 1,
        ),
      ),
    ],
  ),
  LifeEvent(
    id: 'burnout_followup',
    title: 'The Strain Catches Up',
    description:
        'Last month’s pressure did not fully disappear. Your body asks for a correction.',
    category: 'Wellbeing',
    weight: 1,
    condition: EventCondition.scheduledFollowUp,
    tone: EventTone.negative,
    followUpOnly: true,
    triggerHint: 'A follow-up from an earlier high-pressure choice.',
    choices: [
      EventChoice(
        id: 'recover',
        label: 'Recover deliberately',
        resultText: 'You take the signal seriously and regain some control.',
        effect: EventEffect(
          health: 2,
          stress: -4,
          addConditionIds: ['recovery_phase'],
          removeConditionIds: ['burnout_risk'],
        ),
      ),
      EventChoice(
        id: 'ignore',
        label: 'Ignore it again',
        resultText: 'The warning gets harder to ignore.',
        effect: EventEffect(health: -4, happiness: -2, stress: 5),
      ),
    ],
  ),
  LifeEvent(
    id: 'debt_call',
    title: 'Debt Pressure Reminder',
    description:
        'A reminder about money due lands exactly when you were trying not to think about it.',
    category: 'Finance',
    weight: 17,
    condition: EventCondition.debtPressure,
    tone: EventTone.negative,
    contextConditionIds: ['money_anxiety'],
    triggerHint: 'Triggered by debt pressure or emergency debt.',
    choices: [
      EventChoice(
        id: 'make_plan',
        label: 'Make a payment plan',
        resultText: 'The problem remains, but it feels less shapeless.',
        effect: EventEffect(stress: -2, reliability: 1),
      ),
      EventChoice(
        id: 'delay',
        label: 'Delay thinking about it',
        resultText: 'Avoiding it helps briefly, then loops back.',
        effect: EventEffect(
          happiness: -2,
          stress: 3,
          addConditionIds: ['money_anxiety'],
          followUpEventId: 'finance_followup',
          followUpDelayMonths: 1,
        ),
      ),
    ],
  ),
  LifeEvent(
    id: 'finance_followup',
    title: 'Money Problem Returns',
    description:
        'The financial issue you postponed is back, smaller than a crisis but too real to ignore.',
    category: 'Finance',
    weight: 1,
    condition: EventCondition.scheduledFollowUp,
    tone: EventTone.mixed,
    followUpOnly: true,
    triggerHint: 'A follow-up from a delayed finance decision.',
    choices: [
      EventChoice(
        id: 'clear_piece',
        label: 'Clear what you can',
        resultText: 'You pay a small amount and feel the pressure ease.',
        effect: EventEffect(cash: -20, stress: -4, removeConditionIds: ['money_anxiety']),
      ),
      EventChoice(
        id: 'carry',
        label: 'Carry it forward',
        resultText: 'You preserve cash, but the anxiety stays active.',
        effect: EventEffect(stress: 2, addConditionIds: ['money_anxiety']),
      ),
    ],
  ),
  LifeEvent(
    id: 'career_opening_signal',
    title: 'Career Opening Signal',
    description:
        'Someone mentions an opening that seems close to your current track and experience.',
    category: 'Career',
    weight: 13,
    condition: EventCondition.careerMomentum,
    tone: EventTone.positive,
    contextConditionIds: ['career_momentum'],
    triggerHint: 'Triggered by strong work performance or career momentum.',
    choices: [
      EventChoice(
        id: 'follow_up',
        label: 'Follow up professionally',
        resultText: 'You build useful confidence for the next career move.',
        effect: EventEffect(
          happiness: 2,
          reliability: 2,
          addConditionIds: ['career_momentum'],
        ),
      ),
      EventChoice(
        id: 'let_pass',
        label: 'Let it pass',
        resultText: 'You avoid extra pressure this month.',
        effect: EventEffect(stress: -1),
      ),
    ],
  ),
  LifeEvent(
    id: 'study_flow',
    title: 'Study Flow',
    description:
        'Your current material lines up with your mood. The session feels unusually productive.',
    category: 'Education',
    weight: 12,
    condition: EventCondition.activeEducation,
    tone: EventTone.positive,
    contextConditionIds: ['focused_learning', 'good_routine'],
    triggerHint: 'More likely when education and routine are aligned.',
    choices: [
      EventChoice(
        id: 'use_it',
        label: 'Use the focus',
        resultText: 'The momentum carries into your learning habits.',
        effect: EventEffect(
          intelligence: 2,
          happiness: 1,
          addConditionIds: ['focused_learning'],
        ),
      ),
    ],
  ),
  LifeEvent(
    id: 'housing_relief',
    title: 'A Calmer Home Week',
    description:
        'Your living situation gives you a rare stretch of quiet, making the month feel lighter.',
    category: 'Housing',
    weight: 10,
    condition: EventCondition.positiveWellbeing,
    tone: EventTone.positive,
    contextConditionIds: ['stable_housing_boost', 'good_routine'],
    triggerHint: 'More likely when living stability is supporting wellbeing.',
    choices: [
      EventChoice(
        id: 'settle',
        label: 'Settle into it',
        resultText: 'The calm helps your routine stick.',
        effect: EventEffect(
          happiness: 2,
          stress: -2,
          addConditionIds: ['stable_housing_boost'],
        ),
      ),
    ],
  ),
  LifeEvent(
    id: 'company_client_thread',
    title: 'Promising Client Thread',
    description:
        'A small lead appears for your company. It is not guaranteed, but it could become something.',
    category: 'Company',
    weight: 12,
    condition: EventCondition.activeCompany,
    tone: EventTone.positive,
    triggerHint: 'Triggered by owning an active company.',
    choices: [
      EventChoice(
        id: 'pursue',
        label: 'Pursue the lead',
        resultText: 'You create a chance for a concrete follow-up.',
        effect: EventEffect(
          stress: 2,
          happiness: 1,
          followUpEventId: 'company_client_followup',
          followUpDelayMonths: 1,
        ),
      ),
      EventChoice(
        id: 'wait',
        label: 'Wait for now',
        resultText: 'You keep the month calmer, but the lead cools.',
        effect: EventEffect(stress: -1),
      ),
    ],
  ),
  LifeEvent(
    id: 'company_client_followup',
    title: 'Client Thread Follow-Up',
    description:
        'The lead from last month replies. It is small, but real enough to matter.',
    category: 'Company',
    weight: 1,
    condition: EventCondition.scheduledFollowUp,
    tone: EventTone.positive,
    followUpOnly: true,
    triggerHint: 'A follow-up from a business opportunity.',
    choices: [
      EventChoice(
        id: 'close_small',
        label: 'Close the small deal',
        resultText: 'The work pays modestly and gives the company confidence.',
        effect: EventEffect(cash: 45, stress: 2, addConditionIds: ['career_momentum']),
      ),
      EventChoice(
        id: 'pass',
        label: 'Pass politely',
        resultText: 'You avoid overcommitting.',
        effect: EventEffect(stress: -2),
      ),
    ],
  ),
  LifeEvent(
    id: 'business_strain_spike',
    title: 'Business Strain Spike',
    description:
        'The company feels fragile this month, and the uncertainty leaks into the rest of life.',
    category: 'Company',
    weight: 15,
    condition: EventCondition.fragileCompany,
    tone: EventTone.negative,
    contextConditionIds: ['business_strain'],
    triggerHint: 'Triggered by fragile company health or recent losses.',
    choices: [
      EventChoice(
        id: 'stabilize',
        label: 'Stabilize operations',
        resultText: 'You accept a slower month to reduce chaos.',
        effect: EventEffect(stress: -2, addConditionIds: ['recovery_phase']),
      ),
      EventChoice(
        id: 'chase',
        label: 'Chase revenue hard',
        resultText: 'You push for upside, but it adds strain.',
        effect: EventEffect(cash: 20, stress: 4, addConditionIds: ['business_strain']),
      ),
    ],
  ),
  LifeEvent(
    id: 'routine_reinforced',
    title: 'Routine Reinforced',
    description:
        'The habits you have been building start to make ordinary days feel easier.',
    category: 'Positive Momentum',
    weight: 11,
    condition: EventCondition.activeCondition,
    tone: EventTone.positive,
    contextConditionIds: ['good_routine', 'recovery_phase', 'social_uplift'],
    triggerHint: 'Triggered by positive ongoing conditions.',
    choices: [
      EventChoice(
        id: 'keep',
        label: 'Keep it steady',
        resultText: 'The routine becomes easier to maintain.',
        effect: EventEffect(
          health: 1,
          happiness: 2,
          stress: -2,
          addConditionIds: ['good_routine'],
        ),
      ),
    ],
  ),
];
