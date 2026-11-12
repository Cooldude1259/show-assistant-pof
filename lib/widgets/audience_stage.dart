import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models.dart';

/// What an audience phone shows during the show: the whole screen is a
/// light, and sound cues appear as a label (no audio assets in the demo).
///
/// Call [AudienceStageState.play] (via a GlobalKey) to run a cue, or pass
/// [initialCue] to run one as soon as it appears (used for previews).
class AudienceStage extends StatefulWidget {
  const AudienceStage({super.key, this.initialCue, this.child});

  final AudienceCue? initialCue;

  /// Drawn on top of the light (e.g. the exit button).
  final Widget? child;

  @override
  State<AudienceStage> createState() => AudienceStageState();
}

class AudienceStageState extends State<AudienceStage> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  final _random = Random();

  Color _color = Colors.black;
  Color _pulseColor = Colors.black;
  bool _pulsing = false;
  Duration _transition = const Duration(milliseconds: 600);
  Timer? _flickerTimer;
  Timer? _flickerEnd;

  String _soundName = '';
  bool _soundVisible = false;
  Timer? _soundTimer;

  @override
  void initState() {
    super.initState();
    final cue = widget.initialCue;
    if (cue != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) play(cue);
      });
    }
  }

  void play(AudienceCue cue) {
    if (cue.kind == AudienceCueKind.sound) {
      _soundTimer?.cancel();
      setState(() {
        _soundName = cue.name;
        _soundVisible = true;
      });
      _soundTimer = Timer(Duration(milliseconds: max(cue.durationMs, 1500)), () {
        if (mounted) setState(() => _soundVisible = false);
      });
      return;
    }

    _stopLightEffects();
    switch (cue.effect) {
      case LightEffect.solid:
        setState(() {
          _transition = const Duration(milliseconds: 600);
          _color = cue.color;
        });
      case LightEffect.pulse:
        setState(() {
          _color = cue.color;
          _pulseColor = cue.color;
          _pulsing = true;
        });
        _pulse.repeat(reverse: true);
      case LightEffect.flicker:
        setState(() => _transition = Duration.zero);
        _flickerTimer = Timer.periodic(const Duration(milliseconds: 70), (_) {
          if (!mounted) return;
          setState(() => _color = _random.nextDouble() < 0.4 ? cue.color : Colors.black);
        });
        _flickerEnd = Timer(Duration(milliseconds: cue.durationMs), () {
          _flickerTimer?.cancel();
          if (mounted) {
            setState(() {
              _transition = const Duration(milliseconds: 300);
              _color = Colors.black;
            });
          }
        });
      case LightEffect.fade:
        setState(() {
          _transition = Duration(milliseconds: cue.durationMs);
          _color = Colors.black;
        });
      case LightEffect.blackout:
        setState(() {
          _transition = const Duration(milliseconds: 120);
          _color = Colors.black;
        });
    }
  }

  void _stopLightEffects() {
    _flickerTimer?.cancel();
    _flickerEnd?.cancel();
    if (_pulsing) {
      _pulse.stop();
      _pulsing = false;
    }
  }

  @override
  void dispose() {
    _stopLightEffects();
    _soundTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget light = _pulsing
        ? AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) => ColoredBox(
              color: Color.lerp(Colors.black, _pulseColor, 0.15 + 0.85 * _pulse.value)!,
              child: const SizedBox.expand(),
            ),
          )
        : AnimatedContainer(duration: _transition, color: _color);

    return Stack(
      fit: StackFit.expand,
      children: [
        light,
        if (widget.child != null) widget.child!,
        Align(
          alignment: const Alignment(0, 0.6),
          child: AnimatedOpacity(
            opacity: _soundVisible ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.volume_up, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(_soundName,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
