# Build Plan and Acceptance Tests

## Layer 0 — Project setup
- Create a Godot 4.7 Standard project.
- Set portrait orientation and Android project settings.
- Create folders: `scenes/`, `scripts/`, `assets/audio/`, `assets/fonts/`, `assets/themes/`, `tests/`.
- Add a placeholder main scene and confirm it runs.
**Pass:** project opens and runs without errors.

## Layer 1 — Data model
Implement pure game data first:
- `BoardState`: 8×8 occupancy.
- `PieceDefinition`: stable ID and list of local cell coordinates.
- `TrayState`: exactly 3 piece definitions.
- `RunState`: score, best score, combo chain, status.
- `GameRules`: legal placement, placement, line detection, clear, scoring, game-over.
**Tests:** corners, edges, overlap, out-of-bounds, full row, full column, simultaneous row/column intersection, empty board, no legal move.
**Pass:** logic can be tested without UI.

## Layer 2 — Core loop
Implement:
1. Deal three pieces.
2. Select/drag one piece.
3. Preview legal/invalid placement.
4. Commit legal placement.
5. Clear lines and calculate score.
6. Refill tray when empty.
7. Check game over.
8. Restart.
**Pass:** complete runs work with placeholder visuals.

## Layer 3 — UI skeleton
Build Home, Gameplay, Pause, Game Over and Settings.
Connect UI to game state; no decorative styling yet.
**Pass:** every button works and all states are reachable.

## Layer 4 — Visual styling
Apply the visual direction in SPEC.md.
Use reusable components for cells, blocks, buttons, labels and overlays.
Test on narrow and tall phone aspect ratios.
**Pass:** readable, consistent, no clipped UI.

## Layer 5 — Feel and polish
Add placement/clear animations, particles, sound, optional haptics, reduced-motion behavior and input locking during animations.
**Pass:** no double placements, no stuck input, no sound after mute.

## Layer 6 — Persistence and QA
Save settings, best score and current run. Test app background/restore, corrupt save, repeated restart, long sessions and device back button.
**Pass:** no data loss or crash in test matrix.

## Layer 7 — Release preparation
Only after core game is stable:
- Add privacy policy and accurate Data safety disclosures.
- Integrate ads through a maintained Godot Android plugin or native integration; test test-ad IDs only during development.
- Add Play Billing only if selling digital goods.
- Create signed Android App Bundle (AAB).
- Verify current target API requirement, content rating, app access, store listing and testing requirements in Play Console.
- Test on real devices and internal/closed track before production.
**Pass:** release checklist completed; no policy or crash blockers.

## Manual QA checklist
- [ ] Fresh install opens to Home.
- [ ] Start game works offline.
- [ ] Dragging a piece shows a valid/invalid preview.
- [ ] Invalid move changes nothing.
- [ ] Valid move updates board and score once.
- [ ] Full row clears.
- [ ] Full column clears.
- [ ] Simultaneous row and column clear counts intersections once.
- [ ] Tray refills after all three pieces are used.
- [ ] Game ends only when no tray piece can fit.
- [ ] Pause freezes game.
- [ ] Resume returns to same state.
- [ ] Restart resets current run and retains best score.
- [ ] Sound toggle works immediately.
- [ ] Background/foreground preserves run.
- [ ] Corrupt save does not crash.
- [ ] No UI is clipped on tested phone sizes.
- [ ] No ad appears during active gameplay.
