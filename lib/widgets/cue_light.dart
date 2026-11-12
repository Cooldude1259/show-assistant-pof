import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models.dart';
import '../theme.dart';

Color cueColor(CueState state) => switch (state) {
      CueState.idle => Backstage.surfaceHigh,
      CueState.standby => Backstage.standby,
      CueState.go => Backstage.go,
    };

String cueWord(CueState state) => switch (state) {
      CueState.idle => 'CLEAR',
      CueState.standby => 'STANDBY',
      CueState.go => 'GO',
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
        border: Border.all(
          color: state == CueState.idle ? Backstage.border : Colors.white,
          width: 2,
        ),
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
