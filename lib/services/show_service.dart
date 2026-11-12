import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models.dart';

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
  List<Cue> get cues;

  /// The cue currently in standby or just called. Null when nothing is live.
  Cue? get activeCue;
  CueState get state;

  /// Whether the department for [activeCue] has acknowledged the standby.
  bool get acknowledged;

  Future<StaffUser> login({
    required String showCode,
    required String username,
    required String pin,
  });
  void logout();

  void standby(Cue cue);
  void go();
  void acknowledge();
  void reset();
}

/// Fake backend: hard-coded accounts and cues, everything happens in memory
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
        username: 'stage', name: 'Stage Crew', role: StaffRole.crew, department: Department.stage),
  ];

  final _random = Random();

  StaffUser? _user;
  Cue? _activeCue;
  CueState _state = CueState.idle;
  bool _acknowledged = false;
  Timer? _ackTimer;
  Timer? _clearTimer;

  @override
  String get showName => 'Demo Show';

  @override
  StaffUser? get user => _user;

  @override
  Cue? get activeCue => _activeCue;

  @override
  CueState get state => _state;

  @override
  bool get acknowledged => _acknowledged;

  @override
  final List<Cue> cues = const [
    Cue(id: 'lx1', department: Department.lighting, number: 1, description: 'House to half'),
    Cue(id: 'sq1', department: Department.sound, number: 1, description: 'Pre-show music fade out'),
    Cue(id: 'lx2', department: Department.lighting, number: 2, description: 'House out'),
    Cue(id: 'fly1', department: Department.fly, number: 1, description: 'Fly out main curtain'),
    Cue(id: 'sq2', department: Department.sound, number: 2, description: 'Opening number'),
    Cue(id: 'lx3', department: Department.lighting, number: 3, description: 'Lights up, scene 1'),
    Cue(id: 'stage1', department: Department.stage, number: 1, description: 'Bench on, stage left'),
    Cue(id: 'lx4', department: Department.lighting, number: 4, description: 'Spot on lead, centre'),
    Cue(id: 'sq3', department: Department.sound, number: 3, description: 'Door bell effect'),
    Cue(id: 'stage2', department: Department.stage, number: 2, description: 'Bench off, scene change'),
    Cue(id: 'fly2', department: Department.fly, number: 2, description: 'Fly in street backdrop'),
    Cue(id: 'lx5', department: Department.lighting, number: 5, description: 'Blackout, end of act'),
  ];

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
