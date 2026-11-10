Read README.md, SPEC.md, DECISIONS.md, BUILD_PLAN.md and the session rules.

TASK: Implement Layer 2 only — playable core loop using placeholder visuals.

Connect deal → select piece → validate placement → commit → clear lines → score/combo → refill tray → game-over check → restart.

Requirements:
- Drag/drop input with clear legal/invalid preview.
- Invalid moves must never mutate board, score or tray.
- Lock input while resolving a placement/clear.
- Prevent double submission from rapid taps.
- Keep game rules in the data/model layer, not duplicated in UI handlers.
- No ads, networking, daily challenges or purchases.

Show files planned before editing. After implementation, show diff summary, tests performed, bugs/edge cases and what remains untested. Do not proceed to UI styling.
