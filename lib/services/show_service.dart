import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models.dart';
import 'demo_data.dart';

class LoginException implements Exception {
  const LoginException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Everything the UI is allowed to know about the show.
///
/// The UI only ever talks to this interface. Later, a real implementation
/// (talking to the self-hosted show server) replaces [MockShowService]
/// without the screens changing.
abstract class ShowService extends ChangeNotifier {
  String get showName;
  StaffUser? get user;

  // ---- Script ----
  List<Scene> get scenes;

  /// The scene the stage manager says we're in. Crew follow this.
  int get sceneIndex;
  void setScene(int index);

  Scene? sceneAt(int index) => index >= 0 && index < scenes.length ? scenes[index] : null;

  Scene? sceneById(String id) {
    for (final scene in scenes) {
      if (scene.id == id) return scene;
    }
    return null;
  }

  int sceneIndexOf(String sceneId) => scenes.indexWhere((s) => s.id == sceneId);

  // ---- Staff cues (per department, anyone can edit) ----

  /// All staff cues, in script order.
  List<StaffCue> get staffCues;

  List<StaffCue> get callableCues => staffCues.where((c) => c.callable).toList();

  StaffCue? staffCueById(String id) {
    for (final cue in staffCues) {
      if (cue.id == id) return cue;
    }
    return null;
  }

  List<StaffCue> staffCuesAt(String sceneId, int afterLine) =>
      staffCues.where((c) => c.sceneId == sceneId && c.afterLine == afterLine).toList();

  int nextStaffNumber(Department department) {
    var highest = 0;
    for (final cue in staffCues) {
      if (cue.department == department && (cue.number ?? 0) > highest) highest = cue.number!;
    }
    return highest + 1;
  }

  /// Adds the cue, or replaces the one with the same id.
  void saveStaffCue(StaffCue cue);
  void removeStaffCue(String id);

  // ---- Audience cues (lighting + sound only) ----

  /// All audience cues, in script order.
  List<AudienceCue> get audienceCues;

  List<AudienceCue> audienceCuesAt(String sceneId, int afterLine) =>
      audienceCues.where((c) => c.sceneId == sceneId && c.afterLine == afterLine).toList();

  int nextAudienceNumber(AudienceCueKind kind) {
    var highest = 0;
    for (final cue in audienceCues) {
      if (cue.kind == kind && cue.number > highest) highest = cue.number;
    }
    return highest + 1;
  }

  void saveAudienceCue(AudienceCue cue);
  void removeAudienceCue(String id);

  /// Send a cue to every audience device. [audienceFireCount] goes up by one
  /// each time, so listeners can tell a re-fire of the same cue apart.
  void fireAudienceCue(AudienceCue cue);
  AudienceCue? get lastAudienceCue;
  int get audienceFireCount;

  // ---- Calling (stage manager STANDBY / GO on staff cues) ----

  /// The cue currently in standby or just called. Null when nothing is live.
  StaffCue? get activeCue;
  CueState get state;

  /// Whether the department for [activeCue] has acknowledged the standby.
  bool get acknowledged;

  void standby(StaffCue cue);
  void go();
  void acknowledge();
  void reset();

  // ---- Props ----
  List<Prop> get props;

  /// Adds the prop, or replaces the one with the same id.
  void saveProp(Prop prop);
  void removeProp(String id);
  void togglePropSet(String id);
  void togglePropReturned(String id);

  // ---- Auth ----
  Future<StaffUser> login({
    required String showCode,
    required String username,
    required String pin,
  });
  void logout();

  /// Audience only needs the show code.
  Future<AudienceShow> joinAsAudience(String showCode);
}

/// Fake backend: hard-coded accounts, script, cues and props, all in memory
/// on this one phone. Other departments "acknowledge" after a random delay.
class MockShowService extends ShowService {
  static const demoShowCode = 'DEMO';
  static const demoPin = '1234';

  static const demoAccounts = <StaffUser>[
    StaffUser(username: 'sm', name: 'Stage Manager', role: StaffRole.stageManager),
    StaffUser(
        username: 'lx', name: 'Lighting Op', role: StaffRole.crew, department: Department.lighting),
    StaffUser(username: 'sq', name: 'Sound Op', role: StaffRole.crew, department: Department.sound),
    StaffUser(username: 'fly', name: 'Fly Op', role: StaffRole.crew, department: Department.fly),
    StaffUser(
        username: 'stage', name: 'Stagehand', role: StaffRole.crew, department: Department.stage),
    StaffUser(
        username: 'stagelead',
        name: 'Stagehand Director',
        role: StaffRole.crew,
        department: Department.stage,
        isLead: true),
  ];

  final _random = Random();

  StaffUser? _user;
  int _sceneIndex = 0;
  StaffCue? _activeCue;
  CueState _state = CueState.idle;
  bool _acknowledged = false;
  Timer? _ackTimer;
  Timer? _clearTimer;

  final List<StaffCue> _staffCues = buildDemoStaffCues();
  final List<AudienceCue> _audienceCues = buildDemoAudienceCues();
  final List<Prop> _props = buildDemoProps();

  AudienceCue? _lastAudienceCue;
  int _audienceFireCount = 0;

  @override
  String get showName => demoShowTitle;

  @override
  StaffUser? get user => _user;

  @override
  List<Scene> get scenes => demoScenes;

  @override
  int get sceneIndex => _sceneIndex;

  @override
  List<StaffCue> get staffCues =>
      _scriptOrder(_staffCues, (c) => c.sceneId, (c) => c.afterLine);

  @override
  List<AudienceCue> get audienceCues =>
      _scriptOrder(_audienceCues, (c) => c.sceneId, (c) => c.afterLine);

  @override
  AudienceCue? get lastAudienceCue => _lastAudienceCue;

  @override
  int get audienceFireCount => _audienceFireCount;

  @override
  StaffCue? get activeCue => _activeCue;

  @override
  CueState get state => _state;

  @override
  bool get acknowledged => _acknowledged;

  @override
  List<Prop> get props => List.unmodifiable(_props);

  /// Sort by scene, then line, keeping insertion order for ties.
  List<T> _scriptOrder<T>(
      List<T> items, String Function(T) sceneOf, int Function(T) lineOf) {
    final indexed = [for (var i = 0; i < items.length; i++) (i, items[i])];
    indexed.sort((a, b) {
      final bySceneA = sceneIndexOf(sceneOf(a.$2));
      final bySceneB = sceneIndexOf(sceneOf(b.$2));
      if (bySceneA != bySceneB) return bySceneA - bySceneB;
      final byLine = lineOf(a.$2) - lineOf(b.$2);
      if (byLine != 0) return byLine;
      return a.$1 - b.$1;
    });
    return [for (final entry in indexed) entry.$2];
  }

  @override
  void setScene(int index) {
    if (index < 0 || index >= scenes.length || index == _sceneIndex) return;
    _sceneIndex = index;
    notifyListeners();
  }

  // ---- Auth ----

  @override
  Future<StaffUser> login({
    required String showCode,
    required String username,
    required String pin,
  }) async {
    // Pretend there's a network round trip.
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (showCode.trim().toUpperCase() != demoShowCode) {
      throw const LoginException('Unknown show code');
    }
    final name = username.trim().toLowerCase();
    StaffUser? match;
    for (final account in demoAccounts) {
      if (account.username == name) match = account;
    }
    if (match == null || pin != demoPin) {
      throw const LoginException('Wrong username or PIN');
    }
    _user = match;
    notifyListeners();
    return match;
  }

  @override
  void logout() {
    _cancelTimers();
    _activeCue = null;
    _state = CueState.idle;
    _acknowledged = false;
    _user = null;
    notifyListeners();
  }

  @override
  Future<AudienceShow> joinAsAudience(String showCode) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (showCode.trim().toUpperCase() != demoShowCode) {
      throw const LoginException('No show found with that code');
    }
    return buildDemoAudienceShow();
  }

  // ---- Cue editing ----

  @override
  void saveStaffCue(StaffCue cue) {
    final index = _staffCues.indexWhere((c) => c.id == cue.id);
    if (index >= 0) {
      _staffCues[index] = cue;
    } else {
      _staffCues.add(cue);
    }
    notifyListeners();
  }

  @override
  void removeStaffCue(String id) {
    _staffCues.removeWhere((c) => c.id == id);
    if (_activeCue?.id == id) {
      reset();
    } else {
      notifyListeners();
    }
  }

  @override
  void saveAudienceCue(AudienceCue cue) {
    final index = _audienceCues.indexWhere((c) => c.id == cue.id);
    if (index >= 0) {
      _audienceCues[index] = cue;
    } else {
      _audienceCues.add(cue);
    }
    notifyListeners();
  }

  @override
  void removeAudienceCue(String id) {
    _audienceCues.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  @override
  void fireAudienceCue(AudienceCue cue) {
    _lastAudienceCue = cue;
    _audienceFireCount++;
    notifyListeners();
  }

  // ---- Calling ----

  @override
  void standby(StaffCue cue) {
    _cancelTimers();
    _activeCue = cue;
    _state = CueState.standby;
    _acknowledged = false;
    notifyListeners();

    // If the signed-in person isn't the one who has to acknowledge this cue,
    // fake the other department doing it.
    if (!_isMine(cue)) {
      _ackTimer = Timer(Duration(milliseconds: 700 + _random.nextInt(1800)), () {
        if (_state == CueState.standby && _activeCue?.id == cue.id) {
          _acknowledged = true;
          notifyListeners();
        }
      });
    }
  }

  @override
  void go() {
    if (_state != CueState.standby) return;
    _ackTimer?.cancel();
    _state = CueState.go;
    notifyListeners();

    // GO stays lit briefly, then the light clears.
    final cueId = _activeCue?.id;
    _clearTimer = Timer(const Duration(seconds: 4), () {
      if (_activeCue?.id == cueId && _state == CueState.go) {
        _activeCue = null;
        _state = CueState.idle;
        _acknowledged = false;
        notifyListeners();
      }
    });
  }

  @override
  void acknowledge() {
    if (_state != CueState.standby || _acknowledged) return;
    _acknowledged = true;
    notifyListeners();
  }

  @override
  void reset() {
    _cancelTimers();
    _activeCue = null;
    _state = CueState.idle;
    _acknowledged = false;
    notifyListeners();
  }

  // ---- Props ----

  @override
  void saveProp(Prop prop) {
    final index = _props.indexWhere((p) => p.id == prop.id);
    if (index >= 0) {
      _props[index] = prop;
    } else {
      _props.add(prop);
    }
    notifyListeners();
  }

  @override
  void removeProp(String id) {
    _props.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  @override
  void togglePropSet(String id) {
    for (final prop in _props) {
      if (prop.id == id) prop.isSet = !prop.isSet;
    }
    notifyListeners();
  }

  @override
  void togglePropReturned(String id) {
    for (final prop in _props) {
      if (prop.id == id) prop.returned = !prop.returned;
    }
    notifyListeners();
  }

  bool _isMine(StaffCue cue) =>
      _user?.role == StaffRole.crew && _user?.department == cue.department;

  void _cancelTimers() {
    _ackTimer?.cancel();
    _clearTimer?.cancel();
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }
}
