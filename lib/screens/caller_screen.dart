import 'package:flutter/material.dart';

import '../models.dart';
import '../services/show_service.dart';
import '../theme.dart';
import '../widgets/cue_light.dart';

/// Stage manager view: set the live scene, pick a cue, STANDBY, GO.
class CallerScreen extends StatefulWidget {
  const CallerScreen({super.key, required this.service});

  final ShowService service;

  @override
  State<CallerScreen> createState() => _CallerScreenState();
}

class _CallerScreenState extends State<CallerScreen> {
  late String _selectedId = widget.service.callableCues.first.id;

  ShowService get s => widget.service;

  void _go() {
    final active = s.activeCue;
    s.go();
    // Move the selection on to the cue after the one just called.
    if (active != null) {
      final cues = s.callableCues;
      final index = cues.indexWhere((c) => c.id == active.id);
      if (index >= 0 && index < cues.length - 1) {
        setState(() => _selectedId = cues[index + 1].id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final callable = s.callableCues;
        final selectedCue = s.staffCueById(_selectedId) ?? callable.first;
        final selectedIsInStandby =
            s.state == CueState.standby && s.activeCue?.id == selectedCue.id;
        final scene = s.scenes[s.sceneIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text('Stage Manager · ${s.showName}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign out',
                onPressed: s.logout,
              ),
            ],
          ),
          body: Column(
            children: [
              _StatusPanel(service: s),
              const Divider(height: 1),
              // Live scene control: crew screens follow this.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: s.sceneIndex > 0 ? () => s.setScene(s.sceneIndex - 1) : null,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('LIVE SCENE · ${scene.label.toUpperCase()}',
                              style: const TextStyle(
                                  color: Backstage.go,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  fontSize: 12)),
                          Text(scene.title,
                              style:
                                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: s.sceneIndex < s.scenes.length - 1
                          ? () => s.setScene(s.sceneIndex + 1)
                          : null,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  children: [
                    for (final sc in s.scenes) ...[
                      Container(
                        color: Backstage.surfaceHigh,
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: Text(
                          '${sc.label} · ${sc.title}'.toUpperCase(),
                          style: TextStyle(
                            color: sc.id == scene.id ? Backstage.go : Backstage.accent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      for (final cue in callable.where((c) => c.sceneId == sc.id))
                        _cueTile(cue),
                    ],
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _BigButton(
                      label: 'STANDBY\n${selectedCue.label}',
                      color: Backstage.standby,
                      onPressed: selectedIsInStandby ? null : () => s.standby(selectedCue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BigButton(
                      label: s.activeCue != null && s.state == CueState.standby
                          ? 'GO\n${s.activeCue!.label}'
                          : 'GO',
                      color: Backstage.go,
                      onPressed: s.state == CueState.standby ? _go : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _cueTile(StaffCue cue) {
    final isActive = s.activeCue?.id == cue.id;
    final isSelected = cue.id == _selectedId;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Backstage.surfaceHigh : null,
        border: Border(
          left: BorderSide(
            color: isSelected ? Backstage.accent : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: ListTile(
        leading: CueLight(state: isActive ? s.state : CueState.idle),
        title: Text(cue.label, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(cue.title, style: const TextStyle(color: Backstage.textMuted)),
        trailing: Text(cue.department.label, style: const TextStyle(color: Backstage.textMuted)),
        onTap: () => setState(() => _selectedId = cue.id),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.service});

  final ShowService service;

  @override
  Widget build(BuildContext context) {
    final cue = service.activeCue;

    final String title;
    final String detail;
    if (cue == null) {
      title = 'No cue live';
      detail = 'Select a cue and press STANDBY';
    } else if (service.state == CueState.standby) {
      title = 'Standby ${cue.label}';
      detail = service.acknowledged
          ? '${cue.department.label} standing by ✓'
          : 'Waiting for ${cue.department.label}…';
    } else {
      title = 'GO ${cue.label}';
      detail = cue.title;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          CueLight(state: cue == null ? CueState.idle : service.state, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                Text(detail, style: const TextStyle(color: Backstage.textMuted, fontSize: 15)),
              ],
            ),
          ),
          if (cue != null) TextButton(onPressed: service.reset, child: const Text('Clear')),
        ],
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({required this.label, required this.color, required this.onPressed});

  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Backstage.black,
        disabledBackgroundColor: Backstage.surfaceHigh,
        disabledForegroundColor: Backstage.textMuted,
        minimumSize: const Size.fromHeight(76),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Backstage.border),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
    );
  }
}
