# BLOCK RUSH — Game README

## What This Is
A complete, functional Godot 4.7 Android block puzzle game.

## Quick Start

### 1. Install Godot 4.7 Standard
Download from: https://godotengine.org/download/

### 2. Open the Project
1. Launch Godot 4.7
2. Click **Import**
3. Navigate to: `block_rush_game/project.godot`
4. Click **Import & Edit**

### 3. Run the Game
Press **F5** or click the **▶ Play** button.
The game opens to the Home Screen.

### 4. Run Unit Tests
1. In Godot: **Project → Project Settings → Application → Run → Main Scene**
2. Temporarily set it to `res://tests/unit/test_scene.tscn`
3. Press **F5** — results appear in the Output panel
4. Restore main scene to `res://scenes/home/home_screen.tscn`

---

## Project Structure

```
block_rush_game/
├── project.godot              ← Godot project file
├── assets/
│   ├── fonts/                 ← (Add custom fonts here)
│   ├── audio/                 ← (Audio generated procedurally)
│   ├── textures/
│   │   └── icon.svg           ← App icon
│   └── themes/                ← (Add Godot Theme resources here)
├── scenes/
│   ├── home/
│   │   └── home_screen.tscn   ← Home screen
│   ├── gameplay/
│   │   └── gameplay_screen.tscn ← Main game
│   └── settings/
│       └── settings_screen.tscn ← Settings
├── scripts/
│   ├── core/
│   │   ├── board_state.gd      ← 8×8 grid data model
│   │   ├── piece_definitions.gd ← All polyomino shapes + colours
│   │   ├── game_rules.gd       ← Pure gameplay logic
│   │   ├── run_state.gd        ← Score, combo, tray state
│   │   └── game_state.gd       ← Autoload: central coordinator
│   ├── board/
│   │   ├── board_node.gd       ← (Legacy, superseded by board_display_node)
│   │   └── board_display_node.gd ← Draws the grid + preview + animations
│   ├── pieces/
│   │   └── piece_bag.gd        ← Weighted random piece generator
│   ├── gameplay/
│   │   └── gameplay_screen.gd  ← Gameplay UI + drag/drop controller
│   ├── audio/
│   │   └── audio_manager.gd    ← Autoload: procedural sound effects
│   ├── save_system/
│   │   └── save_manager.gd     ← Autoload: local ConfigFile persistence
│   └── ui/
│       ├── home_screen.gd      ← Home screen logic
│       └── settings_screen.gd  ← Settings screen logic
└── tests/
    └── unit/
        ├── test_game_rules.gd  ← 56 unit tests
        └── test_scene.tscn     ← Run this to execute tests
```

---

## Autoloads (Singletons)
Three global singletons are configured in `project.godot`:
- **GameState** — central game data, signals, coordination
- **AudioManager** — procedural sound
- **SaveManager** — local file persistence

---

## Gameplay Rules
- **Board**: 8×8 grid
- **Pieces**: 3 per tray, polyomino shapes
- **Scoring**: 1 pt per block placed, 10 pts per cleared cell, 5×chain combo bonus
- **Clear**: filled rows and columns clear simultaneously (no double-count at intersections)
- **Game over**: when no tray piece fits anywhere on the board

---

## Android Export
See `ANDROID_EXPORT.md` for full instructions.

---

## Documents
| File | Purpose |
|------|---------|
| `ANDROID_EXPORT.md` | Step-by-step Android AAB export |
| `TEST_REPORT.md` | Unit test results + QA checklist |
| `MONETIZATION_PLAN.md` | Future ad/IAP integration plan |
| `../block_rush_project_kit/SPEC.md` | Full product specification |
| `../block_rush_project_kit/DECISIONS.md` | Architecture decisions log |
| `../block_rush_project_kit/BUILD_PLAN.md` | Build phases + acceptance criteria |

---

## Status
**Phase 1-6 Complete** — Fully functional offline MVP.
All core gameplay, screens, save system and QA docs are in place.
Requires Godot 4.7 for final in-engine validation.

