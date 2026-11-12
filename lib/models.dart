import 'package:flutter/widgets.dart';

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
    this.isLead = false,
  });

  final String username;
  final String name;
  final StaffRole role;

  /// Null for the stage manager.
  final Department? department;

  /// Department head, e.g. the stagehand director.
  final bool isLead;

  String get roleLabel {
    if (role == StaffRole.stageManager) return 'Stage Manager';
    final dept = department?.label ?? 'Crew';
    return isLead ? '$dept lead' : dept;
  }

  /// Props lists are owned by the stage crew lead (and the SM).
  bool get canEditProps =>
      role == StaffRole.stageManager || (department == Department.stage && isLead);

  /// Cue notes are written by the department that runs those cues.
  bool canEditCueNotes(Department dept) =>
      role == StaffRole.stageManager || department == dept;
}

enum CueState { idle, standby, go }

class Cue {
  const Cue({
    required this.id,
    required this.sceneId,
    required this.department,
    required this.number,
    required this.description,
  });

  final String id;
  final String sceneId;
  final Department department;
  final int number;
  final String description;

  String get label => '${department.code} $number';
}

class Scene {
  const Scene({
    required this.id,
    required this.act,
    required this.number,
    required this.title,
    required this.lines,
  });

  final String id;
  final int act;
  final int number;
  final String title;
  final List<ScriptLine> lines;

  String get label => 'Act $act, Scene $number';
}

enum LineType { dialogue, direction, cue }

class ScriptLine {
  const ScriptLine.dialogue(this.character, this.text)
      : type = LineType.dialogue,
        cueId = null;

  const ScriptLine.direction(this.text)
      : type = LineType.direction,
        character = null,
        cueId = null;

  /// A cue marker sitting at this point in the script.
  const ScriptLine.cue(this.cueId)
      : type = LineType.cue,
        character = null,
        text = '';

  final LineType type;
  final String? character;
  final String text;
  final String? cueId;
}

enum PropSide {
  stageLeft('SL', 'Stage left'),
  stageRight('SR', 'Stage right');

  const PropSide(this.code, this.label);
  final String code;
  final String label;
}

/// A prop on the props table. It goes on at [onSceneId] and is expected back
/// at the end of [offSceneId] (null = stays out until the end of the show).
class Prop {
  Prop({
    required this.id,
    required this.name,
    required this.onSceneId,
    this.offSceneId,
    this.side = PropSide.stageLeft,
    this.note = '',
    this.isSet = false,
    this.returned = false,
  });

  final String id;
  String name;
  String onSceneId;
  String? offSceneId;
  PropSide side;
  String note;
  bool isSet;
  bool returned;
}

// ---- Audience side ----

enum AudienceStatus { preShow, inProgress, interval, ended }

class CastMember {
  const CastMember(this.character, this.performer);
  final String character;
  final String performer;
}

class VenueInfo {
  const VenueInfo(this.icon, this.title, this.detail);
  final IconData icon;
  final String title;
  final String detail;
}

class AudienceShow {
  const AudienceShow({
    required this.title,
    required this.tagline,
    required this.venue,
    required this.dateLine,
    required this.status,
    required this.statusLine,
    required this.notices,
    required this.scenes,
    required this.cast,
    required this.venueInfo,
  });

  final String title;
  final String tagline;
  final String venue;
  final String dateLine;
  final AudienceStatus status;
  final String statusLine;
  final List<String> notices;
  final List<Scene> scenes;
  final List<CastMember> cast;
  final List<VenueInfo> venueInfo;
}
