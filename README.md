# Show Assistant (proof of concept)

UI-only app. No backend: `MockShowService` fakes everything in memory.

- **Bundle ID:** `com.cooldude12.showassistant` (set in `codemagic.yaml`)
- **Audience:** opens on the join screen, code `DEMO`
- **Staff:** "Crew & staff sign in" at the bottom, show code `DEMO`, PIN `1234`

| Username | Role | Side panel |
|---|---|---|
| `sm` | Stage manager | Calls cues, sets the live scene |
| `lx` / `sq` / `fly` | Lighting / sound / fly | Own cues for this + next scene, editable notes |
| `stage` | Stagehand | Props: needed this scene, next scene, expected back (tick off) |
| `stagelead` | Stagehand director | Same, plus add / edit / delete props |

Crew screens have a demo caller bar (flask icon) so one phone can fake the stage manager.

## Design notes

- **Backstage theme** (`theme.dart`, `Backstage`): true black, white text, yellow / amber / green signals only. No blues, which wash out under blue work lights.
- **Audience theme** (`Playbill`): warm programme look with serif headings, deliberately different from the crew app.
- **Crew layout:** script and department panel side by side on wide screens (iPad / landscape), tabs on a phone.

## Structure

```
lib/
  main.dart                     picks the screen from who is signed in
  theme.dart                    Backstage + Playbill themes
  models.dart                   users, cues, scenes/script, props, audience info
  services/show_service.dart    ShowService (interface) + MockShowService
  services/demo_data.dart       placeholder show, script, cues, props
  screens/join_screen.dart      audience join (landing)
  screens/audience_screen.dart  digital programme
  screens/login_screen.dart     staff sign-in
  screens/caller_screen.dart    stage manager
  screens/crew_screen.dart      cue strip, scene bar, script + side panel
  widgets/script_view.dart      script with inline cue markers
  widgets/department_notes.dart cue notes / props panels and editors
  widgets/panel.dart, cue_light.dart  shared bits
```

Swapping in a real server later = write a new `ShowService` subclass and pass it to `ShowAssistantApp` in `main.dart`.

## Build and install

1. Run the `ios-unsigned` workflow in Codemagic.
2. Copy `ShowAssistant.ipa` to the Pi.
3. `./plumesign sign --package ShowAssistant.ipa --apple-id --register-and-install`
