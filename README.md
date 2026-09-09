# LexiShikhi v1.2.0 — Firebase + AdMob + IAP-ready final source

Package: `com.lexishikhi.learnenglish`
Version: `1.2.0+3`
Target / compile SDK: 36
Min SDK: 24
Gradle: 8.14
Android Gradle Plugin: 8.11.1
Kotlin: 2.2.20
Java: 17

## Included in this source
- Bangla + English interface, Light/Dark mode, local study data and 500+ study/practice records.
- Writing, Grammar, Vocabulary, Translation, Saved, Profile and Practice screens.
- Practice split into 8 permanent-unlock packs covering all 130 practice items.
- Firebase Core + Google/Email Authentication integration.
- Cloud Firestore user sync for coins, unlocked topics/packs, saved items and practice progress.
- In-app account deletion with re-authentication.
- AdMob Rewarded only: no banner/interstitial/app-open flow.
- Google UMP consent/privacy flow before requesting ads when required.
- Rewarded ad = 5 coins, max 5/day, controlled by app state.
- Google Play Billing consumable coin packs with localized live prices (no hardcoded dollar prices).
- Product IDs already fixed in code so products can be created after the first Play AAB upload without another code change.
- Firebase `google-services.json` and Google services Gradle plugin connected.
- API 36 Android build config and Codemagic APK+AAB workflow.
- Public GitHub Pages files: `docs/privacy-policy.html` and `docs/delete-account.html`.

## One-time setup before the final Codemagic build
Read `FINAL_SETUP_STEPS.md`.

Important: the upload keystore is intentionally NOT inside this project or ZIP. Never upload a `.jks` file or keystore password to GitHub.
