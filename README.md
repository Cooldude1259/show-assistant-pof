# Show Assistant (proof of concept)

UI-only app. No backend: `MockShowService` fakes everything in memory.

- **Bundle ID:** `com.cooldude12.showassistant`, set in the committed `ios/` folder (Codemagic builds straight from it and fails if it changes)
- **Audience:** opens on the join screen, code `DEMO`. "Preview show mode" shows what a phone does during the show.
- **Staff:** "Crew & staff sign in" at the bottom, show code `DEMO`, PIN `1234`

| Username | Role | Sees in the script |
|---|---|---|
| `sm` | Stage manager | Calls STANDBY / GO, sets the live scene |
| `lx` | Lighting | Lighting staff cues + all audience cues (edits light ones) |
| `sq` | Sound | Sound staff cues + all audience cues (edits sound ones) |
| `fly` | Fly | Fly staff cues |
| `stage` | Stagehand | Stage staff cues + props block per scene |
| `stagelead` | Stagehand director | Same, plus can edit the props list |

## Two kinds of cue

- **Staff cues** (`StaffCue`): what a department has to do or know at a point in the script. Either *called* (numbered, the SM calls STANDBY / GO) or a plain note/task. Each belongs to one department and only that department sees it. Anyone can add or edit them.
- **Audience cues** (`AudienceCue`): what happens on audience phones. Light cues (colour + effect: solid, pulse, flicker, fade, blackout) and sound cues (the demo shows the sound's name on screen instead of playing audio). Only lighting and sound see them; lighting edits light, sound edits sound.

Cues are anchored to a script position (`sceneId` + `afterLine`), so the script itself never changes.

## Crew screen

Script-first. Wherever you have cues, there's a cue group between lines with an expand button: collapsed it's one line of chips, expanded it shows notes, edit, and (for audience cues) a preview. Long-press any line, or tap +, to add a cue. The demo caller bar (flask icon) fakes the SM on one phone.

## Structure

```
lib/
  main.dart                      picks the screen from who is signed in
  theme.dart                     Backstage (crew) + Playbill (audience) themes
  models.dart                    users, staff/audience cues, script, props, audience info
  services/show_service.dart     ShowService (interface) + MockShowService
  services/demo_data.dart        placeholder show, script, cues, props
  screens/join_screen.dart       audience join (landing)
  screens/audience_screen.dart   digital programme
  screens/live_show_screen.dart  audience phone during the show
  screens/login_screen.dart      staff sign-in
  screens/caller_screen.dart     stage manager
  screens/crew_screen.dart       cue strip, scene bar, script
  widgets/script_view.dart       script with expandable cue groups
  widgets/cue_editors.dart       add/edit staff + audience cues, preview
  widgets/audience_stage.dart    light effects + sound labels
  widgets/props_section.dart     props block for stage crew
  widgets/venue_map.dart         placeholder seating map
```

Swapping in a real server later = write a new `ShowService` subclass and pass it to `ShowAssistantApp` in `main.dart`.

## Build and install

1. Run the `ios-unsigned` workflow in Codemagic.
2. Copy `ShowAssistant.ipa` to the Pi.
3. `./plumesign sign --package ShowAssistant.ipa --apple-id --register-and-install`
