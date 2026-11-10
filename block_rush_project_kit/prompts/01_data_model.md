Read the project context files and follow prompts/00_session_rules.md.

TASK: Implement Layer 1 only — data model and game rules. Do not build screens, styling, audio, ads or networking.

Implement modular GDScript for:
- 8×8 board occupancy.
- Piece definitions as local grid coordinates.
- A tray of exactly 3 pieces.
- Run state: score, best score, combo chain and run status.
- Legal placement validation.
- Placement commit.
- Full row and column detection.
- Unique clear-cell calculation when rows and columns intersect.
- Score calculation exactly as SPEC.md defines.
- Game-over detection by checking every current tray piece at every possible board anchor.

Keep game logic independent from UI. Add a small test scene or test script if practical. Include deterministic test fixtures for edge cases.

Before coding: list files to create/change and the data structures.
After coding: show diff summary, test results, untested cases and any assumptions.
Do not proceed to Layer 2.
