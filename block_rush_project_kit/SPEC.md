# BLOCK RUSH — Product Specification

## 1. Product goal
Create an original, polished, Android-first block-placement puzzle inspired by the broad genre of grid-based block puzzles. Do not copy another game's name, art, sounds, layout, code, branding or distinctive presentation. The game must have its own visual identity and progression.

## 2. Platform and technical stack
- Platform: Android phones, portrait orientation.
- Engine: Godot 4.7 Standard.
- Language: GDScript.
- UI: Godot Control nodes and 2D drawing/nodes.
- Persistence: local ConfigFile or JSON for MVP.
- Offline-first: core game must work without internet.
- Initial display: responsive layout for common phone aspect ratios; safe areas respected.
- No account required for MVP.

## 3. Core game rules
- Board: 8 columns × 8 rows.
- Each cell is either empty or occupied.
- Player receives a tray of exactly 3 pieces.
- Pieces are predefined polyomino shapes selected from a balanced shape pool.
- Player drags a piece from the tray to the board. A placement is legal only when every occupied piece cell maps to an in-bounds empty board cell.
- Invalid placement: piece returns to tray; board and score do not change.
- Valid placement: occupy the mapped cells, award 1 point per placed block, then clear every completely filled row and every completely filled column.
- If a row and column intersect, count each cleared cell only once for clear bonus.
- Clear bonus: 10 points per unique cleared cell; add a combo bonus of 5 × current consecutive-clear chain count. A chain increments when a placement clears at least one line; it resets to zero after a placement that clears none.
- After a valid placement, if all 3 tray pieces have been used, deal 3 new pieces.
- Game ends when none of the currently available tray pieces has any legal placement.
- No timer in classic mode.
- Restart starts a new run after confirmation if a run is active.
- Pause freezes gameplay and opens pause overlay.
- Score and best score are visible during play. Best score persists locally.

## 4. MVP screens
1. Splash/loading (brief, no ad).
2. Home: Play, Daily Puzzle (locked/coming soon in MVP), Settings, Best Score.
3. Gameplay: score, best score, 8×8 board, three-piece tray, pause.
4. Pause overlay: Resume, Restart, Home, Sound toggle.
5. Game-over overlay: final score, best score indicator, Play Again, Home.
6. Settings: sound, music, haptics, privacy link placeholder (no fabricated URL).

## 5. Visual direction
- Distinctive identity: "bright arcade studio" — deep midnight-blue background, warm off-white text, electric coral, cyan, lime and violet block colors.
- Rounded but restrained geometry; consistent spacing; large readable score.
- Blocks have subtle depth, highlights and soft shadows, but must remain legible.
- Avoid visual clutter and avoid copying Block Blast screenshots/assets.
- Use a consistent 8pt spacing scale.
- Support reduced motion / sound-off settings where practical.
- UI should fit small Android screens and be thumb-friendly.

## 6. Feedback and audio
- Placement: short, soft click/pop.
- Line clear: layered chime with a restrained low-end thump.
- Combo: rising pitch only for meaningful combo levels; do not make every action louder.
- Game over: gentle descending cue, never punitive.
- Add small scale/particle feedback for placement and clearing.
- Include mute controls and avoid sudden loud sounds.
- Haptics are optional and must be user-controllable.

## 7. Fair engagement / retention
- Give clear goals and visible progress.
- Daily puzzle may be added after MVP; it must remain optional.
- No expiring energy, forced streaks, guilt messages, deceptive scarcity, autoplay ads, fake close buttons, loot boxes or pay-to-win mechanics.
- Do not make the player watch an ad to access the basic game.
- Rewarded ads must be explicitly opt-in, accurately describe the reward, and never interrupt active gameplay.
- Session reminders, if ever added, should be optional and respectful.

## 8. Monetization plan (not part of MVP)
- Rewarded ad: optional continue after game over, limited to one per run; the player can decline and still replay.
- Interstitial: defer initially. If later used, show only at a natural break after results, never during gameplay or immediately after every action. Apply frequency caps and review current Google Play policy.
- Paid option: one-time remove-ads purchase.
- Cosmetic themes: optional, clearly priced, no gameplay advantage.
- Never promise earnings. Revenue depends on retention, audience, geography, ad fill, eCPM, conversion and store visibility.

## 9. Edge cases
- Piece dragged outside board: return to tray.
- Piece overlaps occupied cells: reject placement.
- Piece partly outside board: reject placement.
- Rapid repeated touch: ignore input while resolving animations.
- App backgrounded mid-run: persist board, tray, score and combo safely; restore on return.
- Audio disabled: all sound calls are silent; gameplay unaffected.
- Screen resize/orientation change: keep portrait layout and preserve state.
- Empty/invalid save data: recover to a new game without crash.
- Game-over check must test every remaining piece against every board anchor.
- Simultaneous row/column clear must not double-award intersecting cells.
- Random piece generation must not create a tray with no legal moves unnecessarily often; for MVP, this can occur naturally and ends the run, but test and tune shape distribution.

## 10. Analytics and success metrics (later, privacy-conscious)
Measure only what is needed and disclose appropriately:
- Tutorial/first-run completion.
- Game starts and completed runs.
- D1 and D7 retention.
- Average and median session length.
- Average score and replay rate.
- Rewarded-ad opt-in rate and completion.
Do not collect sensitive personal data. Do not optimize solely for time spent; pair engagement metrics with crash rate, ratings and player feedback.

## 11. MVP acceptance criteria
- A new player can start a run without login or network.
- All legal placements work; all illegal placements are rejected.
- Rows and columns clear correctly, including simultaneous clears.
- Score and combo math match the rules above.
- Game-over detection is correct.
- Restart resets the run but preserves best score/settings.
- Save/restore works after app restart.
- No critical errors in Godot debugger.
- Tested on at least one real Android device before release.
