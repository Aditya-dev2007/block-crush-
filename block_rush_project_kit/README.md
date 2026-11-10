# BLOCK RUSH — Antigravity Project Kit

A staged build kit for an original Android-first block puzzle game. This is a product specification and prompt pack, not a finished game.

## Recommended workflow
1. Install Godot 4.7 Standard and create an empty project.
2. Open the project folder in Antigravity.
3. Paste `prompts/00_session_rules.md` first.
4. Run one layer prompt at a time, in numeric order.
5. After every layer, run the acceptance checklist in `BUILD_PLAN.md`.
6. Do not proceed while a critical test fails.
7. Keep `SPEC.md` and `DECISIONS.md` updated after each accepted change.

## Fixed stack
- Engine: Godot 4.7 Standard (GDScript, not C#)
- Target: Android phones, portrait orientation
- Rendering: Godot 2D / Control nodes
- Persistence: local ConfigFile or JSON initially
- Online services, ads and billing: deferred until the core game is stable

## Project identity
Working title: BLOCK RUSH (name is provisional; check trademark and Play Store availability).
Genre: casual block-placement puzzle.
Design principle: satisfying, fair, skill-forward play. Do not use manipulative dark patterns.

## First milestone
A fully playable offline game with an 8×8 board, three-piece tray, drag/drop placement, row/column clearing, score, game-over detection, restart and local high score.
