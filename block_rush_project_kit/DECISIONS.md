# Decisions Log

| Decision | Current choice | Reason | Revisit when |
|---|---|---|---|
| Engine | Godot 4.7 Standard | Purpose-built 2D engine; GDScript keeps scope small | A measured technical blocker appears |
| Platform | Android first | Focus release/testing effort | Android MVP is stable |
| Orientation | Portrait | One-handed casual play | User research indicates otherwise |
| Board | 8×8 | Familiar, readable starting point | Playtests show poor difficulty/fit |
| Core mode | Endless classic | Fastest path to a testable MVP | Core loop has retention evidence |
| Backend | None in MVP | Offline play and lower complexity | Leaderboards/cloud features are approved |
| Monetization | Deferred until fun is validated | Avoid designing around ads before product value | MVP retention and feedback are positive |
| Engagement | Skill, mastery, fresh challenges | Respectful retention | Playtests show a clear problem |
| Ads | Opt-in rewarded ad only as first experiment | Player controls whether to watch | Policy and UX review passes |

## Rejected for now
- Real-money rewards, gambling mechanics and loot boxes: unnecessary risk and poor fit.
- Forced daily streaks and punitive timers: create pressure rather than genuine value.
- Interstitial after every game action: harms UX and risks policy violations.
- Multiplayer at launch: increases engineering, moderation and backend scope.
- Copying Block Blast art, sound, branding or exact UI: no original identity and avoidable IP risk.
