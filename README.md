# Show Assistant (proof of concept)

UI-only crew app. No backend: `MockShowService` fakes sign-in and cues in memory.

- **Bundle ID:** `com.cooldude12.showassistant` (set in `codemagic.yaml`)
- **Demo sign-in:** show code `DEMO`, PIN `1234`, username `sm` (stage manager) or `lx` / `sq` / `fly` / `stage` (crew)

## Structure

```
lib/
  main.dart                  picks the screen from who is signed in
  models.dart                StaffUser, Department, Cue, CueState
  services/show_service.dart ShowService (interface) + MockShowService
  screens/login_screen.dart  crew sign-in, demo account chips, audience link
  screens/caller_screen.dart stage manager: cue list, STANDBY / GO
  screens/crew_screen.dart   full-screen cue light + haptics, demo caller bar
  screens/audience_screen.dart placeholder
  widgets/cue_light.dart     light indicator, haptic patterns
```

Swapping in a real server later = write a new `ShowService` subclass and pass it to `ShowAssistantApp` in `main.dart`.

## Build and install

1. Push to GitHub, add the repo in Codemagic, run the `ios-unsigned` workflow.
2. Download `ShowAssistant.ipa`, copy it to the Pi.
3. `./plumesign sign --package ShowAssistant.ipa --apple-id --register-and-install`
