# BLOCK RUSH — Monetization Integration Plan

> [!IMPORTANT]
> This is a **proposal only**. No production ad or billing SDK is integrated.
> Do not implement until the core game has positive retention data.

---

## Rewarded Ad (Priority 1)

### UX Design
- Trigger point: Game Over screen only
- Offer: "Watch an ad to continue once"
- Limit: 1 rewarded continue per run
- UI: Prominent opt-in button ("Continue for free") next to "Play Again"
- If declined: game ends normally, Play Again starts a fresh run
- Never show if no ad is loaded (hide the button)

### Implementation (Godot + AdMob)
- Use the **GodotAdMob** plugin (verify maintenance status at time of integration)
- Use test ad IDs during all development and testing
- Request IDFA consent (ATT on iOS; Consent SDK on Android)
- Apply frequency cap: 1 rewarded ad per game-over event max

### Revenue Estimate (not a promise)
Rewarded eCPM varies by geography (\$0.50 – \$15 USD).
Actual revenue depends on DAU, ad fill rate, opt-in rate, and geography.

---

## Remove Ads Purchase (Priority 2)

### UX Design
- One-time purchase: hides the rewarded-ad continue offer permanently
- Does NOT affect gameplay or scores
- Clearly labelled, e.g. "Remove Ads — \$1.99"

### Implementation
- Use Google Play Billing Library via GodotGooglePlayBilling plugin
- Verify current Godot plugin compatibility before integrating
- Purchase state persists on the user's Google account
- Restore purchases on reinstall

---

## Cosmetic Themes (Priority 3)

### Concept
- Alternative colour palettes (e.g. "Dark Matter", "Pastel Dream", "Neon Night")
- Changed block colours and background — no gameplay impact
- Priced: \$0.99 – \$1.99 per theme

### Implementation
- Theme data: colour dictionaries in GDScript
- Purchase gate via Google Play Billing
- No loot boxes, no random drops, no time-limited exclusives

---

## What We Will NOT Do
- No interstitials during active gameplay
- No forced ad views
- No fake close buttons or misleading reward descriptions
- No loot boxes or gambling mechanics
- No pay-to-win mechanics

---

## Privacy Policy Requirements
Before integrating any ad SDK:
1. Write a plain-language privacy policy
2. Host it at a real, permanent URL
3. Disclose data collected by AdMob (device ID, IP, ad interaction data)
4. Complete Google Play Data Safety form accurately
5. If targeting any users under 13: use child-directed ad settings or no ads

---

## Checklist Before Ad Integration
- [ ] Game has ≥ 500 genuine daily active users
- [ ] D1 retention ≥ 30%
- [ ] No crash-rate blockers
- [ ] Privacy policy URL is live
- [ ] Data Safety form completed
- [ ] Test ad IDs confirmed working in Godot
- [ ] Rewarded ad UX reviewed by a real user
- [ ] Legal review of AdMob publisher policies

