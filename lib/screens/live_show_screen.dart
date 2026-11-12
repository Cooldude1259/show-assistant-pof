import 'package:flutter/material.dart';

import '../models.dart';
import '../services/show_service.dart';
import '../theme.dart';
import '../widgets/audience_stage.dart';

/// What an audience phone looks like during the show. The whole screen is
/// driven by audience cues from the show server (here: the mock service).
///
/// Nothing here mentions scenes or what's coming next, so it can't spoil
/// the show.
class LiveShowScreen extends StatefulWidget {
  const LiveShowScreen({super.key, required this.service, required this.showTitle});

  final ShowService service;
  final String showTitle;

  @override
  State<LiveShowScreen> createState() => _LiveShowScreenState();
}

class _LiveShowScreenState extends State<LiveShowScreen> {
  final _stage = GlobalKey<AudienceStageState>();
  late int _seenCount = widget.service.audienceFireCount;
  bool _started = false;
  bool _playing = false;

  ShowService get s => widget.service;

  @override
  void initState() {
    super.initState();
    s.addListener(_onServiceChange);
  }

  @override
  void dispose() {
    _playing = false;
    s.removeListener(_onServiceChange);
    super.dispose();
  }

  void _onServiceChange() {
    if (s.audienceFireCount == _seenCount) return;
    _seenCount = s.audienceFireCount;
    final cue = s.lastAudienceCue;
    if (cue == null) return;
    if (!_started) setState(() => _started = true);
    _stage.currentState?.play(cue);
  }

  /// Demo only: step through every audience cue as if the show were running.
  /// In the real thing the server fires these when lighting/sound GO them.
  Future<void> _playDemo() async {
    if (_playing) return;
    setState(() => _playing = true);
    final cues = s.audienceCues;
    for (final cue in cues) {
      if (!mounted || !_playing) return;
      s.fireAudienceCue(cue);
      final hold = cue.kind == AudienceCueKind.sound ? 1200 : cue.durationMs + 1500;
      await Future<void>.delayed(Duration(milliseconds: hold));
    }
    if (mounted) setState(() => _playing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AudienceStage(
        key: _stage,
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  tooltip: 'Leave show mode',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              // Shown before the first cue arrives.
              AnimatedOpacity(
                opacity: _started ? 0 : 1,
                duration: const Duration(milliseconds: 800),
                child: IgnorePointer(
                  ignoring: _started,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.showTitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontFamily: Playbill.serif,
                                  fontSize: 34,
                                  color: Playbill.cream)),
                          const SizedBox(height: 12),
                          const Text(
                            'The show is starting. Keep your phone face up on your lap, '
                            'volume off. It will light up with the show.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Playbill.muted, fontSize: 16, height: 1.4),
                          ),
                          const SizedBox(height: 28),
                          OutlinedButton.icon(
                            onPressed: _playing ? null : _playDemo,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Playbill.gold,
                              side: const BorderSide(color: Playbill.gold),
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Demo: run the show'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
