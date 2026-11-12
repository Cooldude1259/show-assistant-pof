import 'package:flutter/material.dart';

import '../models.dart';
import '../services/show_service.dart';
import '../widgets/cue_light.dart';

/// Crew view: the whole screen is a cue light for your department.
class CrewScreen extends StatefulWidget {
  const CrewScreen({super.key, required this.service});

  final ShowService service;

  @override
  State<CrewScreen> createState() => _CrewScreenState();
}

class _CrewScreenState extends State<CrewScreen> {
  CueState _lastState = CueState.idle;
  String? _lastCueId;
  bool _demoCaller = true;
  int _demoIndex = 0;

  ShowService get s => widget.service;

  @override
  void initState() {
    super.initState();
    s.addListener(_onServiceChange);
  }

  @override
  void dispose() {
    s.removeListener(_onServiceChange);
    super.dispose();
  }

  /// Buzz the phone when *my* cue changes state. Done here rather than in
  /// build() so it fires once per change, not once per rebuild.
  void _onServiceChange() {
    final dept = s.user?.department;
    final cue = s.activeCue;
    if (dept != null && cue != null && cue.department == dept) {
      final changed = s.state != _lastState || cue.id != _lastCueId;
      if (changed && s.state == CueState.standby) standbyBuzz();
      if (changed && s.state == CueState.go) goBuzz();
    }
    _lastState = s.state;
    _lastCueId = cue?.id;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final dept = s.user?.department;
        if (dept == null) return const SizedBox.shrink();

        final cue = s.activeCue;
        final mine = cue != null && cue.department == dept;
        final state = mine ? s.state : CueState.idle;
        final fg = state == CueState.idle ? Colors.white : Colors.black;
        final background = state == CueState.idle ? const Color(0xFF121212) : cueColor(state);

        return Scaffold(
          appBar: AppBar(
            title: Text('${dept.label} · ${s.showName}'),
            actions: [
              IconButton(
                icon: Icon(_demoCaller ? Icons.science : Icons.science_outlined),
                tooltip: 'Demo caller',
                onPressed: () => setState(() => _demoCaller = !_demoCaller),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign out',
                onPressed: s.logout,
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: mine && s.state == CueState.standby ? s.acknowledge : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: double.infinity,
                    color: background,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            switch (state) {
                              CueState.idle => 'CLEAR',
                              CueState.standby => 'STANDBY',
                              CueState.go => 'GO',
                            },
                            style: TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 6,
                              color: fg,
                            ),
                          ),
                          if (mine) ...[
                            const SizedBox(height: 8),
                            Text(cue!.label,
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold, color: fg)),
                            Text(cue!.description, style: TextStyle(fontSize: 18, color: fg)),
                          ] else
                            const Text('Waiting for your next cue',
                                style: TextStyle(color: Colors.white54)),
                          if (mine && s.state == CueState.standby) ...[
                            const SizedBox(height: 32),
                            Text(
                              s.acknowledged ? 'Acknowledged ✓' : 'Tap anywhere to acknowledge',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600, color: fg),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (cue != null && !mine) _OtherDeptBanner(cue: cue, state: s.state),
              if (_demoCaller) _demoBar(dept),
            ],
          ),
        );
      },
    );
  }

  /// Lets one phone fake the stage manager, since there's no server yet.
  Widget _demoBar(Department dept) {
    final myCues = s.cues.where((c) => c.department == dept).toList();
    if (myCues.isEmpty) return const SizedBox.shrink();
    final next = myCues[_demoIndex % myCues.length];

    return Material(
      color: Colors.black,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => s.standby(next),
                  child: Text('Demo: standby ${next.label}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: s.state == CueState.standby
                      ? () {
                          s.go();
                          setState(() => _demoIndex++);
                        }
                      : null,
                  child: const Text('Demo: GO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OtherDeptBanner extends StatelessWidget {
  const _OtherDeptBanner({required this.cue, required this.state});

  final Cue cue;
  final CueState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white10,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CueLight(state: state, size: 14),
          const SizedBox(width: 10),
          Text('${cue.label} ${state == CueState.go ? 'GO' : 'standby'} · ${cue.department.label}'),
        ],
      ),
    );
  }
}
