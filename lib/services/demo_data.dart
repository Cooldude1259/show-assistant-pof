import 'package:flutter/material.dart';

import '../models.dart';

/// Placeholder show. The script is an original short piece written for this
/// demo so there's something realistic to lay out.
const demoShowTitle = 'Saltwater Lane';

const demoScenes = <Scene>[
  Scene(id: 's1', act: 1, number: 1, title: 'The Bakery', lines: [
    ScriptLine.cue('lx1'),
    ScriptLine.cue('sq1'),
    ScriptLine.cue('lx2'),
    ScriptLine.cue('fly1'),
    ScriptLine.cue('lx3'),
    ScriptLine.direction(
        'Early morning. MAE dusts flour off the counter. A basket of bread sits by the till.'),
    ScriptLine.cue('sq2'),
    ScriptLine.direction('The shop bell rings. TOMAS enters, out of breath.'),
    ScriptLine.dialogue('TOMAS', "Is it true? The ferry's not coming back?"),
    ScriptLine.dialogue('MAE', "That's what the harbourmaster says. Not until the weather turns."),
    ScriptLine.dialogue('TOMAS', 'Then how is anyone getting off the island?'),
    ScriptLine.dialogue('MAE', 'Nobody is. So you may as well buy a loaf.'),
    ScriptLine.direction('PERRY shuffles in, holding a sealed letter.'),
    ScriptLine.dialogue('PERRY', "This washed up on the rocks. It's got your name on it, Mae."),
    ScriptLine.direction('MAE takes the letter. She does not open it.'),
    ScriptLine.cue('lx4'),
  ]),
  Scene(id: 's2', act: 1, number: 2, title: 'The Pier at Night', lines: [
    ScriptLine.cue('stage1'),
    ScriptLine.cue('lx5'),
    ScriptLine.cue('sq3'),
    ScriptLine.direction(
        'MAE sits on the bench, the letter unopened in her lap. A lantern flickers beside her.'),
    ScriptLine.dialogue('MAE', 'Twelve years without a word, and now this.'),
    ScriptLine.direction('TOMAS enters with a fishing net over his shoulder.'),
    ScriptLine.dialogue('TOMAS', "You haven't opened it."),
    ScriptLine.dialogue('MAE', "If I open it, it's real."),
    ScriptLine.cue('lx6'),
    ScriptLine.dialogue('TOMAS', "Then let it be real. You've waited long enough."),
    ScriptLine.direction('MAE breaks the seal.'),
    ScriptLine.cue('sq4'),
    ScriptLine.cue('lx7'),
  ]),
  Scene(id: 's3', act: 1, number: 3, title: 'The Market', lines: [
    ScriptLine.cue('fly2'),
    ScriptLine.cue('stage2'),
    ScriptLine.cue('lx8'),
    ScriptLine.cue('sq5'),
    ScriptLine.direction('The market is busy. PERRY argues with a stallholder over a fish.'),
    ScriptLine.dialogue('PERRY', "Three coins for a fish this small? It's barely a minnow."),
    ScriptLine.dialogue('MAE', "Perry. The letter. It's from my brother. He says he's coming home."),
    ScriptLine.dialogue('PERRY', "On what? There isn't a boat for a hundred miles."),
    ScriptLine.dialogue('MAE', "He says he'll find one."),
    ScriptLine.cue('lx9'),
    ScriptLine.direction('INTERVAL'),
  ]),
  Scene(id: 's4', act: 2, number: 1, title: 'The Storm', lines: [
    ScriptLine.cue('sq6'),
    ScriptLine.cue('lx10'),
    ScriptLine.cue('fly3'),
    ScriptLine.direction(
        'Rain lashes the pier. MAE and TOMAS share an umbrella, watching the horizon.'),
    ScriptLine.dialogue('TOMAS', 'There. Do you see it? A light.'),
    ScriptLine.dialogue('MAE', "It's a boat. It's actually a boat."),
    ScriptLine.cue('sq7'),
    ScriptLine.cue('lx11'),
  ]),
];

/// In script order.
const demoCues = <Cue>[
  Cue(id: 'lx1', sceneId: 's1', department: Department.lighting, number: 1, description: 'House to half'),
  Cue(id: 'sq1', sceneId: 's1', department: Department.sound, number: 1, description: 'Pre-show music out'),
  Cue(id: 'lx2', sceneId: 's1', department: Department.lighting, number: 2, description: 'House out'),
  Cue(id: 'fly1', sceneId: 's1', department: Department.fly, number: 1, description: 'Main curtain out'),
  Cue(id: 'lx3', sceneId: 's1', department: Department.lighting, number: 3, description: 'Bakery, morning'),
  Cue(id: 'sq2', sceneId: 's1', department: Department.sound, number: 2, description: 'Shop bell'),
  Cue(id: 'lx4', sceneId: 's1', department: Department.lighting, number: 4, description: 'Fade to black'),
  Cue(id: 'stage1', sceneId: 's2', department: Department.stage, number: 1, description: 'Counter off, bench on'),
  Cue(id: 'lx5', sceneId: 's2', department: Department.lighting, number: 5, description: 'Night wash'),
  Cue(id: 'sq3', sceneId: 's2', department: Department.sound, number: 3, description: 'Waves ambience in'),
  Cue(id: 'lx6', sceneId: 's2', department: Department.lighting, number: 6, description: 'Moonlight special on bench'),
  Cue(id: 'sq4', sceneId: 's2', department: Department.sound, number: 4, description: 'Waves ambience out'),
  Cue(id: 'lx7', sceneId: 's2', department: Department.lighting, number: 7, description: 'Blackout'),
  Cue(id: 'fly2', sceneId: 's3', department: Department.fly, number: 2, description: 'Market backdrop in'),
  Cue(id: 'stage2', sceneId: 's3', department: Department.stage, number: 2, description: 'Bench off, market cart on'),
  Cue(id: 'lx8', sceneId: 's3', department: Department.lighting, number: 8, description: 'Market, daylight'),
  Cue(id: 'sq5', sceneId: 's3', department: Department.sound, number: 5, description: 'Town clock chimes'),
  Cue(id: 'lx9', sceneId: 's3', department: Department.lighting, number: 9, description: 'Slow fade, end of Act 1'),
  Cue(id: 'sq6', sceneId: 's4', department: Department.sound, number: 6, description: 'Thunder roll'),
  Cue(id: 'lx10', sceneId: 's4', department: Department.lighting, number: 10, description: 'Storm, lightning flicker'),
  Cue(id: 'fly3', sceneId: 's4', department: Department.fly, number: 3, description: 'Market backdrop out'),
  Cue(id: 'sq7', sceneId: 's4', department: Department.sound, number: 7, description: 'Ship horn'),
  Cue(id: 'lx11', sceneId: 's4', department: Department.lighting, number: 11, description: 'Blackout, end of show'),
];

/// Starting notes, as if the operators had already written some.
const demoCueNotes = <String, String>{
  'lx3': 'Check the window gobo is focused before house opens.',
  'lx6': 'Special is ch 42. Take it to 80% if Mae is off her mark.',
  'sq3': 'Loops. Fade in over 5 seconds.',
  'fly1': 'Wait for the house to be fully out.',
};

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
      venue: 'School Theatre',
      dateLine: 'Tonight · 7:30 pm',
      status: AudienceStatus.preShow,
      statusLine: 'Doors are open. The show starts at 7:30 pm.',
      notices: [
        'Please switch your phone to silent. This app dims itself during the show.',
        'The performance runs about 90 minutes, with one 20-minute interval.',
        'Contains loud thunder effects and brief flashing light.',
      ],
      scenes: demoScenes,
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
