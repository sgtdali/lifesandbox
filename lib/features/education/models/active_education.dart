import 'education_program.dart';

class ActiveEducation {
  const ActiveEducation({
    required this.program,
    required this.completedMonths,
    required this.studyProgressThisMonth,
  });

  final EducationProgram program;
  final int completedMonths;
  final int studyProgressThisMonth;

  bool get studyRequirementMet {
    return studyProgressThisMonth >= program.monthlyStudyRequired;
  }

  ActiveEducation copyWith({
    EducationProgram? program,
    int? completedMonths,
    int? studyProgressThisMonth,
  }) {
    return ActiveEducation(
      program: program ?? this.program,
      completedMonths: completedMonths ?? this.completedMonths,
      studyProgressThisMonth:
          studyProgressThisMonth ?? this.studyProgressThisMonth,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'program': program.toJson(),
      'completedMonths': completedMonths,
      'studyProgressThisMonth': studyProgressThisMonth,
    };
  }

  factory ActiveEducation.fromJson(Map<String, dynamic> json) {
    return ActiveEducation(
      program: EducationProgram.fromJson(
        Map<String, dynamic>.from(json['program'] as Map? ?? {}),
      ),
      completedMonths: json['completedMonths'] as int? ?? 0,
      studyProgressThisMonth: json['studyProgressThisMonth'] as int? ?? 0,
    );
  }
}
