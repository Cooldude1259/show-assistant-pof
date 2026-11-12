import 'package:flutter/widgets.dart';

enum StaffRole { stageManager, crew }

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

  /// Audience cues are the lighting and sound departments' job.
  bool get canSeeAudienceCues =>
      department == Department.lighting || department == Department.sound;

  /// Lighting edits audience light cues, sound edits audience sound cues.
  bool canEditAudienceCue(AudienceCueKind kind) =>
      (kind == AudienceCueKind.light && department == Department.lighting) ||
      (kind == AudienceCueKind.sound && department == Department.sound);

  /// Which audience cue kind this person can create, if any.
  AudienceCueKind? get audienceCueKind => switch (department) {
        Department.lighting => AudienceCueKind.light,
        Department.sound => AudienceCueKind.sound,
        _ => null,
      };

  /// Props lists are owned by the stage crew lead (and the SM).
  bool get canEditProps =>
      role == StaffRole.stageManager || (department == Department.stage && isLead);
}

enum CueState { idle, standby, go }

/// Something a crew member has to do or know at a point in the script:
/// a GO the stage manager calls, a curtain, a stage-level sound effect, or
/// just a heads-up note. Belongs to one department. Anyone can edit them.
class StaffCue {
  StaffCue({
    required this.id,
    required this.sceneId,
    required this.afterLine,
    required this.department,
    required this.title,
    this.number,
    this.note = '',
    this.callable = false,
  });

  final String id;
  String sceneId;

  /// Sits after this line of the scene. -1 = top of the scene.
  int afterLine;
  Department department;

  /// Only called cues get a number (LX 3). Notes/tasks don't.
  int? number;
  String title;
  String note;

  /// Called by the stage manager with STANDBY / GO.
  bool callable;

  String get label => number == null ? department.code : '${department.code} $number';
}

enum AudienceCueKind { light, sound }

enum LightEffect {
  solid('Solid colour'),
  pulse('Pulse'),
  flicker('Flicker'),
  fade('Fade to black'),
  blackout('Blackout');

  const LightEffect(this.label);
  final String label;
}

/// Something that happens on the audience's own phones. Run by the show
/// server; designed by lighting (light) and sound (sound).
class AudienceCue {
  AudienceCue({
    required this.id,
    required this.sceneId,
    required this.afterLine,
    required this.kind,
    required this.number,
    required this.name,
    this.color = const Color(0xFFFFFFFF),
    this.effect = LightEffect.solid,
    this.durationMs = 2000,
  });

  final String id;
  String sceneId;
  int afterLine;
  AudienceCueKind kind;
  int number;

  /// For sound cues this is what the demo shows on screen ("Thunder Sound").
  String name;
  Color color;
  LightEffect effect;
  int durationMs;

  Department get department =>
      kind == AudienceCueKind.light ? Department.lighting : Department.sound;

  String get label => 'AUD ${department.code} $number';
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

enum LineType { dialogue, direction }

class ScriptLine {
  const ScriptLine.dialogue(this.character, this.text) : type = LineType.dialogue;

  const ScriptLine.direction(this.text)
      : type = LineType.direction,
        character = null;

  final LineType type;
  final String? character;
  final String text;
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

/// What the audience is allowed to see. Deliberately no scene list.
class AudienceShow {
  const AudienceShow({
    required this.title,
    required this.tagline,
    required this.bio,
    required this.venue,
    required this.dateLine,
    required this.status,
    required this.statusLine,
    required this.notices,
    required this.cast,
    required this.venueInfo,
  });

  final String title;
  final String tagline;
  final String bio;
  final String venue;
  final String dateLine;
  final AudienceStatus status;
  final String statusLine;
  final List<String> notices;
  final List<CastMember> cast;
  final List<VenueInfo> venueInfo;
}
