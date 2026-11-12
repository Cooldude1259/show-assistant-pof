import 'package:flutter/material.dart';

import '../models.dart';
import '../services/show_service.dart';
import '../theme.dart';
import 'cue_editors.dart';
import 'cue_light.dart';
import 'props_section.dart';

/// The script for one scene. The crew screen is built around this.
///
/// Between lines, wherever this person has cues, there's a compact cue group
/// with an expand button. Collapsed, it's one line; expanded, it shows notes
/// and edit buttons. Long-press any line to add a cue after it.
///
/// Who sees what:
///  - staff cues: only your own department's
///  - audience cues: only lighting and sound
class ScriptView extends StatefulWidget {
  const ScriptView({
    super.key,
    required this.service,
    required this.user,
    required this.scene,
    this.nextScene,
  });

  final ShowService service;
  final StaffUser user;
  final Scene scene;
  final Scene? nextScene;

  @override
  State<ScriptView> createState() => _ScriptViewState();
}

class _ScriptViewState extends State<ScriptView> {
  /// Expanded cue groups, keyed by "sceneId:afterLine".
  final Set<String> _expanded = {};

  ShowService get s => widget.service;
  StaffUser get user => widget.user;

  @override
  Widget build(BuildContext context) {
    final scene = widget.scene;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
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
        Text(scene.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        const Text('Long-press a line to add a cue after it.',
            style: TextStyle(color: Backstage.textMuted, fontSize: 13)),
        const SizedBox(height: 16),
        if (user.department == Department.stage)
          PropsSection(service: s, user: user, scene: scene, nextScene: widget.nextScene),
        _cueGroup(-1),
        for (var i = 0; i < scene.lines.length; i++) ...[
          _line(i, scene.lines[i]),
          _cueGroup(i),
        ],
      ],
    );
  }

  Widget _line(int index, ScriptLine line) {
    final Widget content;
    switch (line.type) {
      case LineType.dialogue:
        content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(line.character ?? '',
                style: const TextStyle(
                    fontWeight: FontWeight.w800, letterSpacing: 1.2, fontSize: 14)),
            const SizedBox(height: 2),
            Text(line.text, style: const TextStyle(fontSize: 18, height: 1.35)),
          ],
        );
      case LineType.direction:
        content = Text(
          line.text,
          style: const TextStyle(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: Backstage.textMuted,
            height: 1.35,
          ),
        );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => showAddCueSheet(
        context,
        service: s,
        user: user,
        sceneId: widget.scene.id,
        afterLine: index,
      ),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: content),
    );
  }

  /// The cues this person can see at this point in the script.
  Widget _cueGroup(int afterLine) {
    final sceneId = widget.scene.id;
    final staff = s
        .staffCuesAt(sceneId, afterLine)
        .where((c) => user.role == StaffRole.stageManager || c.department == user.department)
        .toList();
    final audience =
        user.canSeeAudienceCues ? s.audienceCuesAt(sceneId, afterLine) : <AudienceCue>[];
    if (staff.isEmpty && audience.isEmpty) return const SizedBox.shrink();

    final key = '$sceneId:$afterLine';
    final expanded = _expanded.contains(key);
    final liveHere = staff.any((c) => c.id == s.activeCue?.id) && s.state != CueState.idle;
    final edge = liveHere
        ? cueColor(s.state)
        : (staff.isNotEmpty ? Backstage.accent : Backstage.textMuted);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Backstage.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: edge, width: 5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => setState(() => expanded ? _expanded.remove(key) : _expanded.add(key)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final cue in staff) _staffChip(cue),
                          for (final cue in audience) _audienceChip(cue),
                        ],
                      ),
                    ),
                    Icon(expanded ? Icons.expand_less : Icons.expand_more,
                        color: Backstage.accent, size: 30),
                  ],
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final cue in staff) _StaffCueDetail(service: s, cue: cue),
                    for (final cue in audience)
                      _AudienceCueDetail(
                        service: s,
                        cue: cue,
                        canEdit: user.canEditAudienceCue(cue.kind),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _staffChip(StaffCue cue) {
    final live = s.activeCue?.id == cue.id && s.state != CueState.idle;
    final background = live ? cueColor(s.state) : Backstage.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
        border: live ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cue.callable ? Icons.flag : Icons.sticky_note_2_outlined,
              size: 16, color: Backstage.black),
          const SizedBox(width: 4),
          Text(
            cue.callable ? '${cue.label} · ${cue.title}' : cue.title,
            style: const TextStyle(color: Backstage.black, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _audienceChip(AudienceCue cue) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Backstage.text, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cue.kind == AudienceCueKind.light ? Icons.lightbulb_outline : Icons.volume_up,
              size: 16, color: Backstage.text),
          const SizedBox(width: 4),
          Text('${cue.label} · ${cue.name}',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StaffCueDetail extends StatelessWidget {
  const _StaffCueDetail({required this.service, required this.cue});

  final ShowService service;
  final StaffCue cue;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Backstage.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cue.callable ? '${cue.label} · CALLED BY SM' : '${cue.department.label} note',
                  style: const TextStyle(
                      color: Backstage.accent,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 2),
                Text(cue.title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                if (cue.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(cue.note, style: const TextStyle(fontSize: 16)),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Backstage.accent),
            tooltip: 'Edit',
            onPressed: () => showStaffCueEditor(context, service: service, existing: cue),
          ),
        ],
      ),
    );
  }
}

class _AudienceCueDetail extends StatelessWidget {
  const _AudienceCueDetail({required this.service, required this.cue, required this.canEdit});

  final ShowService service;
  final AudienceCue cue;
  final bool canEdit;

  @override
  Widget build(BuildContext context) {
    final isLight = cue.kind == AudienceCueKind.light;
    final seconds = (cue.durationMs / 1000).toStringAsFixed(1);
    final showsColour =
        isLight && cue.effect != LightEffect.fade && cue.effect != LightEffect.blackout;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Backstage.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Backstage.border),
      ),
      child: Row(
        children: [
          if (showsColour) ...[
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: cue.color,
                shape: BoxShape.circle,
                border: Border.all(color: Backstage.text, width: 2),
              ),
            ),
            const SizedBox(width: 10),
          ] else ...[
            Icon(isLight ? Icons.lightbulb_outline : Icons.volume_up, size: 30),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${cue.label} · AUDIENCE DEVICES',
                    style: const TextStyle(
                        color: Backstage.textMuted,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1)),
                Text(cue.name,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                Text(isLight ? '${cue.effect.label} · ${seconds}s' : 'Sound · ${seconds}s',
                    style: const TextStyle(color: Backstage.textMuted)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow, color: Backstage.go),
            tooltip: 'Preview',
            onPressed: () => showAudiencePreview(context, cue),
          ),
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit, color: Backstage.accent),
              tooltip: 'Edit',
              onPressed: () => showAudienceCueEditor(context, service: service, existing: cue),
            ),
        ],
      ),
    );
  }
}
