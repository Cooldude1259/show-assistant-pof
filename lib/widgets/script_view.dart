import 'package:flutter/material.dart';

import '../models.dart';
import '../services/show_service.dart';
import '../theme.dart';
import 'cue_light.dart';

/// The script for one scene, with cue markers inline. Your own department's
/// cues are highlighted; the live cue lights up amber/green.
class ScriptView extends StatelessWidget {
  const ScriptView({
    super.key,
    required this.service,
    required this.scene,
    this.myDepartment,
  });

  final ShowService service;
  final Scene scene;
  final Department? myDepartment;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(
          scene.label.toUpperCase(),
          style: const TextStyle(
            color: Backstage.accent,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(scene.title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        for (final line in scene.lines) _buildLine(line),
      ],
    );
  }

  Widget _buildLine(ScriptLine line) {
    switch (line.type) {
      case LineType.dialogue:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                line.character ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, letterSpacing: 1.2, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(line.text, style: const TextStyle(fontSize: 18, height: 1.35)),
            ],
          ),
        );
      case LineType.direction:
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(
            line.text,
            style: const TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Backstage.textMuted,
              height: 1.35,
            ),
          ),
        );
      case LineType.cue:
        final cue = service.cueById(line.cueId ?? '');
        if (cue == null) return const SizedBox.shrink();
        return _CueMarker(
          cue: cue,
          isMine: cue.department == myDepartment,
          liveState: service.activeCue?.id == cue.id ? service.state : null,
        );
    }
  }
}

class _CueMarker extends StatelessWidget {
  const _CueMarker({required this.cue, required this.isMine, required this.liveState});

  final Cue cue;
  final bool isMine;
  final CueState? liveState;

  @override
  Widget build(BuildContext context) {
    final live = liveState != null && liveState != CueState.idle;
    final Color background;
    final Color foreground;
    final Color border;
    if (live) {
      background = cueColor(liveState!);
      foreground = Colors.black;
      border = Colors.white;
    } else if (isMine) {
      background = Backstage.accent;
      foreground = Colors.black;
      border = Backstage.accent;
    } else {
      background = Colors.transparent;
      foreground = Backstage.textMuted;
      border = Backstage.border;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: border, width: 2),
          ),
          child: Text(
            live ? '${cue.label} · ${cueWord(liveState!)} · ${cue.description}'
                : '${cue.label} · ${cue.description}',
            style: TextStyle(color: foreground, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
