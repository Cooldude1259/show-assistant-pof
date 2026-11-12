enum StaffRole { stageManager, crew }

/// Crew departments. The app only talks to the *people* running these —
/// it never outputs to lighting/sound systems themselves.
enum Department {
  lighting('LX', 'Lighting'),
  sound('SQ', 'Sound'),
  fly('FLY', 'Fly'),
  stage('STAGE', 'Stage crew');

  const Department(this.code, this.label);
  final String code;
  final String label;
}

class StaffUser {
  const StaffUser({
    required this.username,
    required this.name,
    required this.role,
    this.department,
  });

  final String username;
  final String name;
  final StaffRole role;

  /// Null for the stage manager.
  final Department? department;

  String get roleLabel =>
      role == StaffRole.stageManager ? 'Stage Manager' : (department?.label ?? 'Crew');
}

enum CueState { idle, standby, go }

class Cue {
  const Cue({
    required this.id,
    required this.department,
    required this.number,
    required this.description,
  });

  final String id;
  final Department department;
  final int number;
  final String description;

  String get label => '${department.code} $number';
}
