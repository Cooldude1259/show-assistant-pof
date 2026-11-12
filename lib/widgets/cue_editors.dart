import 'package:flutter/material.dart';

import '../models.dart';
import '../services/show_service.dart';
import '../theme.dart';
import 'audience_stage.dart';

/// Long-press menu on a script line: what kind of cue to add there.
Future<void> showAddCueSheet(
  BuildContext context, {
  required ShowService service,
  required StaffUser user,
  required String sceneId,
  required int afterLine,
}) async {
  final audienceKind = user.audienceCueKind;
  final dept = user.department ?? Department.stage;

  final choice = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Backstage.surfaceHigh,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text('Add a cue after this line',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
          ListTile(
            leading: const Icon(Icons.flag_outlined, color: Backstage.accent),
            title: Text('Staff cue · ${dept.label}'),
            subtitle: const Text('Something to do or know at this point',
                style: TextStyle(color: Backstage.textMuted)),
            onTap: () => Navigator.of(context).pop('staff'),
          ),
          if (audienceKind != null)
            ListTile(
              leading: Icon(
                audienceKind == AudienceCueKind.light ? Icons.lightbulb_outline : Icons.volume_up,
                color: Backstage.accent,
              ),
              title: Text(audienceKind == AudienceCueKind.light
                  ? 'Audience light cue'
                  : 'Audience sound cue'),
              subtitle: const Text('Runs on audience phones',
                  style: TextStyle(color: Backstage.textMuted)),
              onTap: () => Navigator.of(context).pop('audience'),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );

  if (!context.mounted || choice == null) return;
  if (choice == 'staff') {
    await showStaffCueEditor(context,
        service: service, sceneId: sceneId, afterLine: afterLine, defaultDepartment: dept);
  } else if (choice == 'audience' && audienceKind != null) {
    await showAudienceCueEditor(context,
        service: service, sceneId: sceneId, afterLine: afterLine, kind: audienceKind);
  }
}

// ---------------------------------------------------------------------------
// Staff cue editor
// ---------------------------------------------------------------------------

Future<void> showStaffCueEditor(
  BuildContext context, {
  required ShowService service,
  StaffCue? existing,
  String? sceneId,
  int? afterLine,
  Department defaultDepartment = Department.stage,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _StaffCueDialog(
      service: service,
      existing: existing,
      sceneId: existing?.sceneId ?? sceneId ?? service.scenes.first.id,
      afterLine: existing?.afterLine ?? afterLine ?? -1,
      defaultDepartment: defaultDepartment,
    ),
  );
}

class _StaffCueDialog extends StatefulWidget {
  const _StaffCueDialog({
    required this.service,
    required this.existing,
    required this.sceneId,
    required this.afterLine,
    required this.defaultDepartment,
  });

  final ShowService service;
  final StaffCue? existing;
  final String sceneId;
  final int afterLine;
  final Department defaultDepartment;

  @override
  State<_StaffCueDialog> createState() => _StaffCueDialogState();
}

class _StaffCueDialogState extends State<_StaffCueDialog> {
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _note = TextEditingController(text: widget.existing?.note ?? '');
  late Department _department = widget.existing?.department ?? widget.defaultDepartment;
  late bool _callable = widget.existing?.callable ?? false;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final existing = widget.existing;

    // Called cues get a number in their department; notes don't.
    int? number;
    if (_callable) {
      final oldNumber = existing?.number;
      final keepNumber = existing != null &&
          existing.callable &&
          existing.department == _department &&
          oldNumber != null;
      number = keepNumber ? oldNumber : widget.service.nextStaffNumber(_department);
    }

    widget.service.saveStaffCue(StaffCue(
      id: existing?.id ?? 'sc${DateTime.now().microsecondsSinceEpoch}',
      sceneId: widget.sceneId,
      afterLine: widget.afterLine,
      department: _department,
      number: number,
      title: title,
      note: _note.text.trim(),
      callable: _callable,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existing;
    return AlertDialog(
      backgroundColor: Backstage.surfaceHigh,
      title: Text(existing == null ? 'New staff cue' : 'Edit ${existing.label}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _title,
              autofocus: existing == null,
              decoration: const InputDecoration(labelText: 'What happens'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              minLines: 2,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 12),
            const Text('For', style: TextStyle(color: Backstage.textMuted, fontSize: 13)),
            DropdownButton<Department>(
              value: _department,
              isExpanded: true,
              items: [
                for (final dept in Department.values)
                  DropdownMenuItem(value: dept, child: Text(dept.label)),
              ],
              onChanged: (v) => setState(() => _department = v ?? _department),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _callable,
              onChanged: (v) => setState(() => _callable = v),
              title: const Text('Called by stage manager'),
              subtitle: const Text('Gets a cue number and a STANDBY / GO',
                  style: TextStyle(color: Backstage.textMuted)),
            ),
          ],
        ),
      ),
      actions: [
        if (existing != null)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Backstage.danger),
            onPressed: () {
              widget.service.removeStaffCue(existing.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Audience cue editor
// ---------------------------------------------------------------------------

/// Colours for audience phones. Unlike the crew UI these can be anything,
/// including blues: this is what the audience sees, not the crew.
const audiencePalette = <Color>[
  Color(0xFFFFFFFF),
  Color(0xFFFF9E40),
  Color(0xFFFFD54F),
  Color(0xFFFF5252),
  Color(0xFFE040FB),
  Color(0xFF7FA8FF),
  Color(0xFF1A237E),
  Color(0xFF00E676),
];

Future<void> showAudienceCueEditor(
  BuildContext context, {
  required ShowService service,
  AudienceCue? existing,
  String? sceneId,
  int? afterLine,
  AudienceCueKind kind = AudienceCueKind.light,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _AudienceCueDialog(
      service: service,
      existing: existing,
      sceneId: existing?.sceneId ?? sceneId ?? service.scenes.first.id,
      afterLine: existing?.afterLine ?? afterLine ?? -1,
      kind: existing?.kind ?? kind,
    ),
  );
}

class _AudienceCueDialog extends StatefulWidget {
  const _AudienceCueDialog({
    required this.service,
    required this.existing,
    required this.sceneId,
    required this.afterLine,
    required this.kind,
  });

  final ShowService service;
  final AudienceCue? existing;
  final String sceneId;
  final int afterLine;
  final AudienceCueKind kind;

  @override
  State<_AudienceCueDialog> createState() => _AudienceCueDialogState();
}

class _AudienceCueDialogState extends State<_AudienceCueDialog> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late Color _color = widget.existing?.color ?? audiencePalette.first;
  late LightEffect _effect = widget.existing?.effect ?? LightEffect.solid;
  late double _seconds = (widget.existing?.durationMs ?? 2000) / 1000;

  bool get _isLight => widget.kind == AudienceCueKind.light;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  AudienceCue _build() {
    final existing = widget.existing;
    return AudienceCue(
      id: existing?.id ?? 'ac${DateTime.now().microsecondsSinceEpoch}',
      sceneId: widget.sceneId,
      afterLine: widget.afterLine,
      kind: widget.kind,
      number: existing?.number ?? widget.service.nextAudienceNumber(widget.kind),
      name: _name.text.trim().isEmpty
          ? (_isLight ? _effect.label : 'Sound')
          : _name.text.trim(),
      color: _color,
      effect: _effect,
      durationMs: (_seconds * 1000).round(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existing;
    final usesColour = _effect != LightEffect.fade && _effect != LightEffect.blackout;

    return AlertDialog(
      backgroundColor: Backstage.surfaceHigh,
      title: Text(existing == null
          ? (_isLight ? 'New audience light cue' : 'New audience sound cue')
          : 'Edit ${existing.label}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: existing == null,
              decoration: InputDecoration(
                labelText: _isLight ? 'Name' : 'Sound shown on screen',
                hintText: _isLight ? 'e.g. Storm' : 'e.g. Thunder Sound',
              ),
            ),
            if (_isLight) ...[
              const SizedBox(height: 12),
              const Text('Effect', style: TextStyle(color: Backstage.textMuted, fontSize: 13)),
              DropdownButton<LightEffect>(
                value: _effect,
                isExpanded: true,
                items: [
                  for (final effect in LightEffect.values)
                    DropdownMenuItem(value: effect, child: Text(effect.label)),
                ],
                onChanged: (v) => setState(() => _effect = v ?? _effect),
              ),
              if (usesColour) ...[
                const SizedBox(height: 8),
                const Text('Colour', style: TextStyle(color: Backstage.textMuted, fontSize: 13)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final colour in audiencePalette)
                      GestureDetector(
                        onTap: () => setState(() => _color = colour),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colour,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _color == colour ? Backstage.accent : Backstage.border,
                              width: _color == colour ? 4 : 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
            const SizedBox(height: 12),
            Text('Duration: ${_seconds.toStringAsFixed(1)} s',
                style: const TextStyle(color: Backstage.textMuted, fontSize: 13)),
            Slider(
              value: _seconds,
              min: 0.5,
              max: 6,
              divisions: 11,
              onChanged: (v) => setState(() => _seconds = v),
            ),
          ],
        ),
      ),
      actions: [
        if (existing != null)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Backstage.danger),
            onPressed: () {
              widget.service.removeAudienceCue(existing.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => showAudiencePreview(context, _build()),
          child: const Text('Preview'),
        ),
        FilledButton(
          onPressed: () {
            widget.service.saveAudienceCue(_build());
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

/// Shows roughly what an audience phone will do for this cue.
Future<void> showAudiencePreview(BuildContext context, AudienceCue cue) {
  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.black,
      child: SizedBox(
        height: 320,
        child: AudienceStage(
          initialCue: cue,
          child: Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    ),
  );
}
