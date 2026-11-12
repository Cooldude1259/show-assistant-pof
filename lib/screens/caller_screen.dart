import 'package:flutter/material.dart';

import '../models.dart';
import '../services/show_service.dart';
import '../widgets/cue_light.dart';

/// Stage manager view: pick a cue, put it in standby, call GO.
class CallerScreen extends StatefulWidget {
  const CallerScreen({super.key, required this.service});

  final ShowService service;

  @override
  State<CallerScreen> createState() => _CallerScreenState();
}

class _CallerScreenState extends State<CallerScreen> {
  int _selected = 0;

  ShowService get s => widget.service;

  void _go() {
    final active = s.activeCue;
    s.go();
    // Move the selection on to the cue after the one just called.
    if (active != null) {
      final index = s.cues.indexOf(active);
      if (index >= 0 && index < s.cues.length - 1) {
        setState(() => _selected = index + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final cues = s.cues;
        final selectedCue = cues[_selected];
        final selectedIsInStandby =
            s.state == CueState.standby && s.activeCue?.id == selectedCue.id;

        return Scaffold(
          appBar: AppBar(
            title: Text(s.showName),
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
              Expanded(
                child: ListView.builder(
                  itemCount: cues.length,
                  itemBuilder: (context, i) {
                    final cue = cues[i];
                    final isActive = s.activeCue?.id == cue.id;
                    return ListTile(
                      selected: i == _selected,
                      selectedTileColor: Colors.white10,
                      leading: CueLight(state: isActive ? s.state : CueState.idle),
                      title: Text(cue.label,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(cue.description),
                      trailing: Text(cue.department.label,
                          style: const TextStyle(color: Colors.white54)),
                      onTap: () => setState(() => _selected = i),
                    );
                  },
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
                      color: Colors.amber,
                      onPressed: selectedIsInStandby ? null : () => s.standby(selectedCue),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BigButton(
                      label: s.activeCue != null && s.state == CueState.standby
                          ? 'GO\n${s.activeCue!.label}'
                          : 'GO',
                      color: Colors.greenAccent.shade400,
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
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.service});

  final ShowService service;

  @override
  Widget build(BuildContext context) {
    final cue = service.activeCue;
    final theme = Theme.of(context);

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
      detail = cue.description;
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
                Text(title, style: theme.textTheme.titleLarge),
                Text(detail, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          if (cue != null)
            TextButton(onPressed: service.reset, child: const Text('Clear')),
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
        foregroundColor: Colors.black,
        disabledBackgroundColor: Colors.white12,
        disabledForegroundColor: Colors.white38,
        minimumSize: const Size.fromHeight(76),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
      ),
    );
  }
}
