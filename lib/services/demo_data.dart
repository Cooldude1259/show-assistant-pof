import 'package:flutter/material.dart';

import '../models.dart';

/// Placeholder show. The script is an original short piece written for this
/// demo so there's something realistic to lay out.
const demoShowTitle = 'Saltwater Lane';

const demoScenes = <Scene>[
  Scene(id: 's1', act: 1, number: 1, title: 'The Bakery', lines: [
    ScriptLine.direction(
        'Early morning. MAE dusts flour off the counter. A basket of bread sits by the till.'), // 0
    ScriptLine.direction('The shop bell rings. TOMAS enters, out of breath.'), // 1
    ScriptLine.dialogue('TOMAS', "Is it true? The ferry's not coming back?"), // 2
    ScriptLine.dialogue('MAE', "That's what the harbourmaster says. Not until the weather turns."), // 3
    ScriptLine.dialogue('TOMAS', 'Then how is anyone getting off the island?'), // 4
    ScriptLine.dialogue('MAE', 'Nobody is. So you may as well buy a loaf.'), // 5
    ScriptLine.direction('PERRY shuffles in, holding a sealed letter.'), // 6
    ScriptLine.dialogue('PERRY', "This washed up on the rocks. It's got your name on it, Mae."), // 7
    ScriptLine.direction('MAE takes the letter. She does not open it.'), // 8
  ]),
  Scene(id: 's2', act: 1, number: 2, title: 'The Pier at Night', lines: [
    ScriptLine.direction(
        'MAE sits on the bench, the letter unopened in her lap. A lantern flickers beside her.'), // 0
    ScriptLine.dialogue('MAE', 'Twelve years without a word, and now this.'), // 1
    ScriptLine.direction('TOMAS enters with a fishing net over his shoulder.'), // 2
    ScriptLine.dialogue('TOMAS', "You haven't opened it."), // 3
    ScriptLine.dialogue('MAE', "If I open it, it's real."), // 4
    ScriptLine.dialogue('TOMAS', "Then let it be real. You've waited long enough."), // 5
    ScriptLine.direction('MAE breaks the seal.'), // 6
  ]),
  Scene(id: 's3', act: 1, number: 3, title: 'The Market', lines: [
    ScriptLine.direction('The market is busy. PERRY argues with a stallholder over a fish.'), // 0
    ScriptLine.dialogue('PERRY', "Three coins for a fish this small? It's barely a minnow."), // 1
    ScriptLine.dialogue('MAE', "Perry. The letter. It's from my brother. He says he's coming home."), // 2
    ScriptLine.dialogue('PERRY', "On what? There isn't a boat for a hundred miles."), // 3
    ScriptLine.dialogue('MAE', "He says he'll find one."), // 4
    ScriptLine.direction('INTERVAL'), // 5
  ]),
  Scene(id: 's4', act: 2, number: 1, title: 'The Storm', lines: [
    ScriptLine.direction(
        'Rain lashes the pier. MAE and TOMAS share an umbrella, watching the horizon.'), // 0
    ScriptLine.dialogue('TOMAS', 'There. Do you see it? A light.'), // 1
    ScriptLine.dialogue('MAE', "It's a boat. It's actually a boat."), // 2
  ]),
];

StaffCue _called(String id, String scene, int after, Department dept, int number, String title,
        [String note = '']) =>
    StaffCue(
        id: id,
        sceneId: scene,
        afterLine: after,
        department: dept,
        number: number,
        title: title,
        note: note,
        callable: true);

StaffCue _task(String id, String scene, int after, Department dept, String title,
        [String note = '']) =>
    StaffCue(id: id, sceneId: scene, afterLine: after, department: dept, title: title, note: note);

List<StaffCue> buildDemoStaffCues() => [
      // Scene 1
      _called('lx1', 's1', -1, Department.lighting, 1, 'House to half'),
      _called('sq1', 's1', -1, Department.sound, 1, 'Pre-show music out'),
      _called('lx2', 's1', -1, Department.lighting, 2, 'House out'),
      _called('fly1', 's1', -1, Department.fly, 1, 'Main curtain out',
          'Wait for the house to be fully out.'),
      _called('lx3', 's1', -1, Department.lighting, 3, 'Bakery, morning state',
          'Check the window gobo is focused before house opens.'),
      _task('sq-n1', 's1', -1, Department.sound, 'Heads up: shop bell',
          'The bell is loud in the stage speaker. Ride the fader down.'),
      _called('sq2', 's1', 0, Department.sound, 2, 'Shop bell (stage speaker)'),
      _task('st-t1', 's1', 5, Department.stage, 'Letter ready for Perry',
          'Hand it to Perry in the SL wing before his entrance.'),
      _called('lx4', 's1', 8, Department.lighting, 4, 'Fade to black'),
      // Scene 2
      _called('st1', 's2', -1, Department.stage, 1, 'Scene change: counter off, bench on'),
      _called('lx5', 's2', -1, Department.lighting, 5, 'Night wash'),
      _called('sq3', 's2', -1, Department.sound, 3, 'Waves ambience in', 'Loops. Fade in over 5s.'),
      _task('st-t2', 's2', 1, Department.stage, 'Net to Tomas, SR wing'),
      _called('lx6', 's2', 4, Department.lighting, 6, 'Moonlight special on bench',
          'Ch 42. Take it to 80% if Mae is off her mark.'),
      _called('sq4', 's2', 6, Department.sound, 4, 'Waves ambience out'),
      _called('lx7', 's2', 6, Department.lighting, 7, 'Blackout'),
      // Scene 3
      _called('fly2', 's3', -1, Department.fly, 2, 'Market backdrop in'),
      _called('st2', 's3', -1, Department.stage, 2, 'Bench off, market cart on'),
      _called('lx8', 's3', -1, Department.lighting, 8, 'Market, daylight'),
      _called('sq5', 's3', 0, Department.sound, 5, 'Town clock chimes'),
      _called('lx9', 's3', 4, Department.lighting, 9, 'Slow fade, end of Act 1'),
      _task('st-t3', 's3', 5, Department.stage, 'Interval reset',
          'Cart off, umbrella to SR table, sweep the pier.'),
      // Scene 4
      _task('lx-n1', 's4', -1, Department.lighting, 'Heads up: thunder',
          'Thunder is very loud on cans. Turn your headset down.'),
      _called('sq6', 's4', -1, Department.sound, 6, 'Thunder roll'),
      _called('lx10', 's4', -1, Department.lighting, 10, 'Storm, lightning flicker'),
      _called('fly3', 's4', -1, Department.fly, 3, 'Market backdrop out'),
      _called('sq7', 's4', 1, Department.sound, 7, 'Ship horn'),
      _called('lx11', 's4', 2, Department.lighting, 11, 'Blackout, end of show'),
    ];

AudienceCue _light(String id, String scene, int after, int number, String name, Color color,
        LightEffect effect,
        [int durationMs = 2000]) =>
    AudienceCue(
      id: id,
      sceneId: scene,
      afterLine: after,
      kind: AudienceCueKind.light,
      number: number,
      name: name,
      color: color,
      effect: effect,
      durationMs: durationMs,
    );

AudienceCue _sound(String id, String scene, int after, int number, String name,
        [int durationMs = 2500]) =>
    AudienceCue(
      id: id,
      sceneId: scene,
      afterLine: after,
      kind: AudienceCueKind.sound,
      number: number,
      name: name,
      durationMs: durationMs,
    );

List<AudienceCue> buildDemoAudienceCues() => [
      _light('al1', 's1', 0, 1, 'Sunrise glow', const Color(0xFFFF9E40), LightEffect.solid),
      _sound('as1', 's1', 0, 1, 'Shop Bell Sound'),
      _light('al2', 's1', 8, 2, 'Fade out', const Color(0xFF000000), LightEffect.fade, 2500),
      _light('al3', 's2', -1, 3, 'Moonlight', const Color(0xFF7FA8FF), LightEffect.solid),
      _sound('as2', 's2', -1, 2, 'Waves Sound', 3500),
      _light('al4', 's2', 6, 4, 'Fade out', const Color(0xFF000000), LightEffect.fade, 3000),
      _light('al5', 's3', -1, 5, 'Market bustle', const Color(0xFFFFD54F), LightEffect.pulse),
      _sound('as3', 's3', 0, 3, 'Town Clock Chimes'),
      _light('al6', 's3', 4, 6, 'End of Act 1', const Color(0xFF000000), LightEffect.blackout),
      _sound('as4', 's4', -1, 4, 'Thunder Sound', 3000),
      _light('al7', 's4', -1, 7, 'Lightning', const Color(0xFFFFFFFF), LightEffect.flicker, 2500),
      _light('al8', 's4', 0, 8, 'Storm', const Color(0xFF1A237E), LightEffect.pulse),
      _sound('as5', 's4', 1, 5, 'Ship Horn Sound', 3000),
      _light('al9', 's4', 2, 9, 'Blackout', const Color(0xFF000000), LightEffect.blackout),
    ];

List<Prop> buildDemoProps() => [
      Prop(id: 'p1', name: 'Bread basket', onSceneId: 's1', offSceneId: 's1',
          side: PropSide.stageLeft, note: 'Foam loaves, count 6'),
      Prop(id: 'p2', name: 'Counter bell', onSceneId: 's1', offSceneId: 's1',
          side: PropSide.stageRight),
      Prop(id: 'p3', name: 'Sealed letter', onSceneId: 's1', offSceneId: 's4',
          side: PropSide.stageLeft, note: "Perry's personal prop. Reseal after each show."),
      Prop(id: 'p4', name: 'Lantern', onSceneId: 's2', offSceneId: 's2',
          side: PropSide.stageRight, note: 'Switch on before handing over'),
      Prop(id: 'p5', name: 'Fishing net', onSceneId: 's2', offSceneId: 's3',
          side: PropSide.stageRight),
      Prop(id: 'p6', name: 'Market cart', onSceneId: 's3', offSceneId: 's3',
          side: PropSide.stageLeft, note: 'Two crew. Brakes on once set.'),
      Prop(id: 'p7', name: 'Umbrella', onSceneId: 's4', side: PropSide.stageRight),
    ];

AudienceShow buildDemoAudienceShow() => const AudienceShow(
      title: demoShowTitle,
      tagline: 'An island waits for a boat that may never come.',
      bio: 'When the last ferry stops running, the small island town of Saltwater Lane '
          'is cut off from the world. Mae, who runs the bakery, has spent twelve years '
          'waiting for news of her brother. Then a sealed letter washes up on the rocks.\n\n'
          'A new musical about hope, stubbornness and the people who wait for us, '
          'performed by our senior drama students.',
      venue: 'School Theatre',
      dateLine: 'Tonight · 7:30 pm',
      status: AudienceStatus.preShow,
      statusLine: 'Doors are open. The show starts at 7:30 pm.',
      notices: [
        'Please switch your phone to silent. Keep this app open: it becomes part of the show.',
        'Runs about 90 minutes, including one 20-minute interval.',
        'Contains loud thunder effects and flashing light, including on your phone screen.',
      ],
      cast: [
        CastMember('Mae', 'Student name'),
        CastMember('Tomas', 'Student name'),
        CastMember('Perry', 'Student name'),
        CastMember('Stallholder', 'Student name'),
      ],
      venueInfo: [
        VenueInfo(Icons.local_cafe_outlined, 'Interval', 'Drinks and snacks in the foyer'),
        VenueInfo(Icons.wc_outlined, 'Toilets', 'Through the foyer, on the left'),
        VenueInfo(Icons.accessible_outlined, 'Access', 'Wheelchair spaces in row A'),
        VenueInfo(Icons.exit_to_app, 'Exits', 'Follow the green signs at either side'),
      ],
    );
