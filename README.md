# 🧱 BLOCK RUSH (block-crush-)

[![Android APK Build & Release](https://github.com/Aditya-dev2007/block-crush-/actions/workflows/export-apk.yml/badge.svg)](https://github.com/Aditya-dev2007/block-crush-/actions/workflows/export-apk.yml)
[![Latest Release](https://img.shields.io/github/v/release/Aditya-dev2007/block-crush-?color=brightgreen&label=Release)](https://github.com/Aditya-dev2007/block-crush-/releases)

A modern, highly addictive 8×8 block puzzle game built with **Godot 4**. Features dynamic combo chains, rich harmonic sound synthesis, daily seeded challenges with streak tracking, and tactile responsive controls.

---

## 📱 How to Download & Play on Android

### Option 1: Direct Download (Easiest & Recommended)
1. **Open on Phone**: Open **[Latest GitHub Releases](https://github.com/Aditya-dev2007/block-crush-/releases)** in your Android browser.
2. **Download**: Tap **`BLOCK_RUSH.apk`** under the latest release assets.
3. **Install**:
   - Open your notification tray or **Files / Downloads** folder and tap `BLOCK_RUSH.apk`.
   - If prompted *"For your security, your phone is not allowed to install unknown apps from this source"*, tap **Settings** → enable **"Allow from this source"** → tap Back.
   - Tap **Install**, then **Open** to play!

---

### Option 2: Export Locally using Godot Editor
If you prefer building the APK yourself on your computer:
1. Open Godot 4 (4.4 or 4.7) and open the project at `block_rush_game/project.godot`.
2. Go to **Editor → Manage Export Templates** and ensure Godot export templates are downloaded.
3. Ensure **OpenJDK 17** and **Android SDK** are configured under **Editor → Editor Settings → Export → Android**.
4. Go to **Project → Export**, select the **Android** preset, and click **Export Project...**.
5. Save the APK file and transfer it to your phone.

---

## 🎮 Game Features

- **Classic Endless Mode**:
  - 8×8 grid block placement.
  - Multi-line clearing (simultaneous rows and columns).
  - Streak and combo multipliers for chained clears.
  - Game over detection when no tray pieces fit on the board.

- **Daily Challenge Mode**:
  - Deterministic daily puzzle seeded by current calendar date (`YYYY-MM-DD`).
  - Target score threshold.
  - Win condition and daily streak preservation.

- **Audio & Visual FX**:
  - Real-time procedural pentatonic sound synthesis (zero audio latency, zero external asset dependencies).
  - Micro-shake screen impact effects.
  - Floating bouncy score indicators for combos and clears.
  - 3D beveled block aesthetics with vibrant gem palette.

- **Persistence**:
  - Automatic saving of high score, statistics, and daily streak progress.

---

## 💻 Tech Stack
- **Engine**: Godot Engine 4 (Compatibility renderer for universal Android hardware support)
- **Language**: GDScript 2.0
- **CI/CD**: GitHub Actions automated headless Android APK build & GitHub Releases deployment
