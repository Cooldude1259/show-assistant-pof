import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

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

  // ---- Cues ----
  List<Cue> get cues;

  Cue? cueById(String id) {
    for (final cue in cues) {
      if (cue.id == id) return cue;
    }
    return null;
  }

  List<Cue> cuesFor(String sceneId, Department department) =>
      cues.where((c) => c.sceneId == sceneId && c.department == department).toList();

  /// The cue currently in standby or just called. Null when nothing is live.
  Cue? get activeCue;
  CueState get state;

  /// Whether the department for [activeCue] has acknowledged the standby.
  bool get acknowledged;

  void standby(Cue cue);
  void go();
  void acknowledge();
  void reset();

  /// Operator's own notes on a cue (e.g. lighting writing their cue details).
  String cueNote(String cueId);
  void setCueNote(String cueId, String note);

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
  Cue? _activeCue;
  CueState _state = CueState.idle;
  bool _acknowledged = false;
  Timer? _ackTimer;
  Timer? _clearTimer;

  final Map<String, String> _cueNotes = Map.of(demoCueNotes);
  final List<Prop> _props = buildDemoProps();

  @override
  String get showName => demoShowTitle;

  @override
  StaffUser? get user => _user;

  @override
  List<Scene> get scenes => demoScenes;

  @override
  List<Cue> get cues => demoCues;

  @override
  int get sceneIndex => _sceneIndex;

  @override
  Cue? get activeCue => _activeCue;

  @override
  CueState get state => _state;

  @override
  bool get acknowledged => _acknowledged;

  @override
  List<Prop> get props => List.unmodifiable(_props);

  @override
  void setScene(int index) {
    if (index < 0 || index >= scenes.length || index == _sceneIndex) return;
    _sceneIndex = index;
    notifyListeners();
  }

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

  @override
  void standby(Cue cue) {
    _cancelTimers();
    _activeCue = cue;
    _state = CueState.standby;
    _acknowledged = false;
    notifyListeners();

    // If the signed-in person isn't the one who has to acknowledge this cue,
    // fake the other department doing it.
    if (!_isMine(cue)) {
      _ackTimer = Timer(Duration(milliseconds: 700 + _random.nextInt(1800)), () {
        if (_state == CueState.standby && _activeCue == cue) {
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
    final cue = _activeCue;
    _clearTimer = Timer(const Duration(seconds: 4), () {
      if (_activeCue == cue && _state == CueState.go) {
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

  @override
  String cueNote(String cueId) => _cueNotes[cueId] ?? '';

  @override
  void setCueNote(String cueId, String note) {
    if (note.isEmpty) {
      _cueNotes.remove(cueId);
    } else {
      _cueNotes[cueId] = note;
    }
    notifyListeners();
  }

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

  bool _isMine(Cue cue) =>
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
