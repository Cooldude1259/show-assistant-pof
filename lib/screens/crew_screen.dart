import 'dart:math';

import 'package:flutter/material.dart';

import '../models.dart';
import '../services/show_service.dart';
import '../theme.dart';
import '../widgets/cue_light.dart';
import '../widgets/department_notes.dart';
import '../widgets/script_view.dart';

/// Crew view: cue light strip on top, then the script with your department's
/// notes beside it (side by side on wide screens, tabs on a phone).
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
  int _tab = 0;

  /// Scene being viewed. Null = follow the live scene.
  int? _viewIndex;

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
        final user = s.user;
        final dept = user?.department;
        if (user == null || dept == null) return const SizedBox.shrink();

        final liveIndex = s.sceneIndex;
        final viewIndex = max(0, min(_viewIndex ?? liveIndex, s.scenes.length - 1));
        final scene = s.scenes[viewIndex];
        final nextScene = s.sceneAt(viewIndex + 1);

        final script = ScriptView(service: s, scene: scene, myDepartment: dept);
        final notes = DepartmentNotes(
          service: s,
          user: user,
          department: dept,
          scene: scene,
          nextScene: nextScene,
        );

        return Scaffold(
          appBar: AppBar(
            title: Text('${user.roleLabel} · ${s.showName}'),
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
              _CueStrip(service: s, department: dept),
              _SceneBar(
                scene: scene,
                isLive: viewIndex == liveIndex,
                onPrevious: viewIndex > 0 ? () => setState(() => _viewIndex = viewIndex - 1) : null,
                onNext: viewIndex < s.scenes.length - 1
                    ? () => setState(() => _viewIndex = viewIndex + 1)
                    : null,
                onBackToLive: () => setState(() => _viewIndex = null),
              ),
              const Divider(height: 1),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth >= 700) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 3, child: script),
                          const VerticalDivider(width: 1),
                          Expanded(flex: 2, child: notes),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                          child: SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<int>(
                              showSelectedIcon: false,
                              style: SegmentedButton.styleFrom(
                                selectedBackgroundColor: Backstage.accent,
                                selectedForegroundColor: Backstage.black,
                                foregroundColor: Backstage.text,
                                side: const BorderSide(color: Backstage.border),
                              ),
                              segments: [
                                const ButtonSegment(
                                  value: 0,
                                  label: Text('Script'),
                                  icon: Icon(Icons.description_outlined),
                                ),
                                ButtonSegment(
                                  value: 1,
                                  label: Text(dept == Department.stage ? 'Props' : 'My cues'),
                                  icon: Icon(dept == Department.stage
                                      ? Icons.inventory_2_outlined
                                      : Icons.edit_note),
                                ),
                              ],
                              selected: {_tab},
                              onSelectionChanged: (selection) =>
                                  setState(() => _tab = selection.first),
                            ),
                          ),
                        ),
                        Expanded(child: _tab == 0 ? script : notes),
                      ],
                    );
                  },
                ),
              ),
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
      color: Backstage.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => s.standby(next),
                  child: Text('Standby ${next.label}', overflow: TextOverflow.ellipsis),
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
                  child: const Text('GO'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => s.setScene((s.sceneIndex + 1) % s.scenes.length),
                  child: const Text('Next scene'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Top strip. Quiet when nothing is live; grows and fills with colour when
/// your department's cue is in standby or called.
class _CueStrip extends StatelessWidget {
  const _CueStrip({required this.service, required this.department});

  final ShowService service;
  final Department department;

  @override
  Widget build(BuildContext context) {
    final cue = service.activeCue;
    final mine = cue != null && cue.department == department;
    final state = mine ? service.state : CueState.idle;
    final active = state != CueState.idle;
    final fg = active ? Backstage.black : Backstage.text;

    final String detail;
    if (cue != null && mine) {
      detail = '${cue.label} · ${cue.description}';
    } else if (cue != null) {
      detail = 'Other dept: ${cue.label} ${cueWord(service.state).toLowerCase()}';
    } else {
      detail = 'No cues live';
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: mine && service.state == CueState.standby ? service.acknowledge : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: active ? 132 : 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: active ? cueColor(state) : Backstage.surface,
        child: Row(
          children: [
            if (!active) ...[
              CueLight(state: cue == null ? CueState.idle : service.state, size: 22),
              const SizedBox(width: 12),
            ],
            Text(
              cueWord(state),
              style: TextStyle(
                fontSize: active ? 44 : 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: fg,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? fg : Backstage.textMuted,
                      fontSize: active ? 18 : 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (mine && service.state == CueState.standby)
                    Text(
                      service.acknowledged ? 'Acknowledged ✓' : 'Tap here to acknowledge',
                      style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SceneBar extends StatelessWidget {
  const _SceneBar({
    required this.scene,
    required this.isLive,
    required this.onPrevious,
    required this.onNext,
    required this.onBackToLive,
  });

  final Scene scene;
  final bool isLive;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onBackToLive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrevious),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isLive ? 'LIVE' : 'LOOKING AHEAD'} · ${scene.label}'.toUpperCase(),
                  style: TextStyle(
                    color: isLive ? Backstage.go : Backstage.accent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
                Text(scene.title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          if (!isLive) TextButton(onPressed: onBackToLive, child: const Text('Back to live')),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}
