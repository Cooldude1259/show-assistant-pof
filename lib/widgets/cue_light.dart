import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';

Color cueColor(CueState state) => switch (state) {
      CueState.idle => const Color(0xFF2A2A2A),
      CueState.standby => Colors.amber,
      CueState.go => Colors.greenAccent.shade400,
    };

/// Small round indicator used in lists.
class CueLight extends StatelessWidget {
  const CueLight({super.key, required this.state, this.size = 18});

  final CueState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = cueColor(state);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white24),
        boxShadow: state == CueState.idle
            ? null
            : [BoxShadow(color: color.withOpacity(0.6), blurRadius: size)],
      ),
    );
  }
}

Future<void> standbyBuzz() => HapticFeedback.heavyImpact();

Future<void> goBuzz() async {
  for (var i = 0; i < 3; i++) {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }
}
