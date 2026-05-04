import '../../../game/models/game_state.dart';
import '../../conditions/services/condition_service.dart';
import '../../wellbeing/services/wellbeing_service.dart';
import '../data/education_catalog.dart';
import '../models/active_education.dart';
import '../models/education_program.dart';

class EducationService {
  const EducationService();

  static const studyEnergyCost = 20;
  static const studyProgressAmount = 20;

  List<EducationProgram> get programs => educationCatalog;

  bool canStart(GameState state, EducationProgram program) {
    final alreadyCompleted = state.completedEducations.any(
      (record) => record.programId == program.id,
    );
    return state.activeEducation == null && !alreadyCompleted;
  }

  GameState startProgram(GameState state, EducationProgram program) {
    if (!canStart(state, program)) return state;

    return state.copyWith(
      activeEducation: ActiveEducation(
        program: program,
        completedMonths: 0,
        studyProgressThisMonth: 0,
      ),
      clearLastMonthResult: true,
    );
  }

  GameState cancelProgram(GameState state) {
    if (state.activeEducation == null) return state;
    return state.copyWith(
      clearActiveEducation: true,
      clearLastMonthResult: true,
    );
  }

  GameState study(GameState state) {
    final active = state.activeEducation;
    if (active == null) return state;
    if (state.player.stats.energy < studyEnergyCost) return state;

    final updatedStats = state.player.stats.apply(
      energy: -studyEnergyCost,
      stress: 1,
    );
    final nextStudy = active.studyProgressThisMonth +
        studyProgressAmount +
        const ConditionService().studyProgressBonus(state) +
        const WellbeingService().studyModifier(state);

    return state.copyWith(
      player: state.player.copyWith(stats: updatedStats),
      activeEducation: active.copyWith(studyProgressThisMonth: nextStudy),
      clearLastMonthResult: true,
    );
  }
}
