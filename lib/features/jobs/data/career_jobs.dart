import '../models/job.dart';

final careerJobs = <Job>[
  ..._track(
    track: 'Service',
    tags: ['service', 'communication', 'operations'],
    roles: const [
      ['Service Assistant', 'Operations Support Assistant'],
      ['Service Specialist', 'Operations Assistant'],
      ['Service Supervisor', 'Operations Coordinator'],
      ['Service Manager', 'Operations Manager'],
    ],
  ),
  ..._track(
    track: 'Office',
    tags: ['office', 'admin', 'data', 'tools'],
    roles: const [
      ['Office Support Clerk', 'Data Entry Clerk'],
      ['Office Assistant', 'Operations Assistant'],
      ['Office Coordinator', 'Operations Officer'],
      ['Office Manager', 'Operations Manager'],
    ],
  ),
  ..._track(
    track: 'Technical',
    tags: ['operations', 'production'],
    roles: const [
      ['Production Support Worker', 'Technical Support Worker'],
      ['Production Operator', 'Technical Operator'],
      ['Production Supervisor', 'Technical Supervisor'],
      ['Production Manager', 'Technical Unit Manager'],
    ],
  ),
  ..._track(
    track: 'Sales',
    tags: ['sales', 'communication'],
    roles: const [
      ['Store Sales Assistant', 'Sales Support Clerk'],
      ['Customer Representative', 'Sales Representative'],
      ['Corporate Sales Officer', 'Sales Coordinator'],
      ['Sales Manager', 'Client Relations Manager'],
    ],
  ),
  ..._track(
    track: 'Digital',
    tags: ['digital', 'content', 'tools'],
    roles: const [
      ['Content Support Assistant', 'Digital Operations Assistant'],
      ['Content Specialist', 'Digital Marketing Specialist'],
      ['Performance Marketing Officer', 'Digital Content Coordinator'],
      ['Digital Marketing Manager', 'Content & Brand Manager'],
    ],
  ),
];

List<Job> _track({
  required String track,
  required List<String> tags,
  required List<List<String>> roles,
}) {
  final jobs = <Job>[];
  for (var level = 1; level <= roles.length; level += 1) {
    final salary = _salaryFor(track, level);
    final energy = _energyFor(track, level);
    for (var index = 0; index < roles[level - 1].length; index += 1) {
      final title = roles[level - 1][index];
      jobs.add(
        Job(
          id: '${track.toLowerCase()}_l${level}_$index',
          title: title,
          category: track,
          monthlySalary: salary + index * 4,
          monthlyEnergyLoad: energy + index * 2,
          stressImpact: (level + index + 1).clamp(1, 7).toInt(),
          intelligenceWeight: _intelligenceWeight(track),
          reliabilityWeight: 0.28 + level * 0.02,
          stressWeight: 0.20,
          readinessWeight: 0.18,
          accessibility: (72 - level * 11 - index * 2).clamp(24, 80).toInt(),
          description: _description(track, level),
          isStarter: false,
          track: track,
          level: level,
          jobSecurity: (70 - level * 4 + index).clamp(45, 75).toInt(),
          careerValue: level * 2,
          educationTags: tags,
        ),
      );
    }
  }
  return jobs;
}

int _salaryFor(String track, int level) {
  final base = switch (track) {
    'Digital' => 152,
    'Sales' => 148,
    'Technical' => 146,
    'Office' => 142,
    _ => 138,
  };
  return base + (level - 1) * 48;
}

int _energyFor(String track, int level) {
  final base = switch (track) {
    'Technical' => 36,
    'Sales' => 34,
    'Digital' => 32,
    _ => 30,
  };
  return base + (level - 1) * 6;
}

double _intelligenceWeight(String track) {
  return switch (track) {
    'Digital' => 0.38,
    'Office' => 0.30,
    'Technical' => 0.26,
    'Sales' => 0.18,
    _ => 0.16,
  };
}

String _description(String track, int level) {
  final scope = switch (level) {
    1 => 'entry career role',
    2 => 'growing specialist role',
    3 => 'coordination role',
    _ => 'management role',
  };
  return 'A $scope in the $track track with clearer long-term progression.';
}
