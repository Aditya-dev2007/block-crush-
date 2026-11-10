# BLOCK RUSH — Android Export Instructions

## Prerequisites
- Godot 4.7 Standard installed
- Android SDK (API 35+ recommended for 2026 Google Play requirements)
- Android NDK r23c or later
- Java JDK 17
- A signing keystore (do NOT commit this to source control)

## Step 1 — Configure Godot Android SDK Paths
1. Open Godot → Editor → Editor Settings
2. Navigate to: **Export → Android**
3. Set:
   - **Android SDK Path**: path to your Android SDK
   - **Debug Keystore**: leave default or create one

## Step 2 — Install Godot Android Export Templates
1. In Godot: **Editor → Manage Export Templates**
2. Download and install templates for Godot 4.7

## Step 3 — Create Export Preset
1. **Project → Export**
2. Click **Add** → Select **Android**
3. Configure:
   - **Package / Unique Name**: `com.yourname.blockrush`
   - **App Name**: `Block Rush`
   - **Version Code**: `1` (increment for each upload)
   - **Version Name**: `1.0.0`
   - **Min SDK**: `24` (Android 7.0)
   - **Target SDK**: `35` (or current Play Store requirement)
   - **Orientation**: Portrait
   - **Internet permission**: OFF (offline game)

## Step 4 — Signing for Release
1. Create a keystore (once, keep it safe):
   ```
   keytool -genkey -v -keystore block_rush_release.jks -alias block_rush -keyalg RSA -keysize 2048 -validity 10000
   ```
2. In Export preset → **Keystore** tab:
   - **Release Keystore**: path to `.jks`
   - **Release User**: your alias
   - **Release Password**: your keystore password

## Step 5 — Export AAB
1. In Export dialog → select your Android preset
2. Click **Export Project**
3. Choose format: **Android App Bundle (.aab)**
4. Save as `block_rush_release.aab`

> [!CAUTION]
> Never commit your `.jks` keystore or passwords to source control.
> Add `*.jks` and `export_credentials.cfg` to `.gitignore`.

## Step 6 — Upload to Google Play
1. Create an app in Google Play Console
2. Navigate to **Internal Testing** track
3. Upload the `.aab`
4. Complete: Content rating, Privacy policy URL, Data safety
5. Test on real devices via internal track before promoting to production

## Current Google Play Requirements (verify at time of release)
- Target API: 35 (Android 15) as of 2025 — verify current requirement
- 64-bit support: Required
- Privacy policy: Required for all apps
- Data safety form: Required

