# LexiShikhi final one-time setup

Do these in order. The app source is already wired for Firebase, Rewarded AdMob and the future Play coin products.

## 1. Firebase — add the Codemagic upload SHA-1 BEFORE building
Firebase Console → Project settings → Your apps → LexiShikhi Android → Add fingerprint

Add the SHA-1 from the separate `LexiShikhi_Keystore_Info.txt` file supplied with the upload keystore.

Google Authentication and Email/Password Authentication should stay enabled. Firestore should keep the rules in `firestore.rules`.

You do NOT need to create a Firestore collection manually. The signed-in app creates `users/{uid}` when it syncs.

## 2. Codemagic signing
Upload the separate `LexiShikhi_Upload_Keystore.jks` to Codemagic Android code signing.
Use the signing identity name exactly:

`lexishikhi_upload`

Use the alias/passwords from `LexiShikhi_Keystore_Info.txt`.

## 3. GitHub
Replace the old LexiShikhi project files with this project. Do NOT upload the keystore or its info/password file.

## 4. Codemagic — one build
Run workflow: `LexiShikhi Final APK + AAB`

- APK is built with Google's official test Rewarded Ad unit (`USE_TEST_ADS=true`) for sideload testing.
- AAB is built with the real LexiShikhi Rewarded Ad unit (`USE_TEST_ADS=false`) for Google Play.

## 5. Upload the AAB to Play Console Internal testing
The AAB already includes Google Play Billing support. After Play accepts that build, One-time products can be created.

## 6. Create the six Play one-time products — exact IDs
- `coins_50` — 50 coins
- `coins_110` — 110 coins
- `coins_240` — 240 coins
- `coins_390` — 390 coins
- `coins_560` — 560 coins
- `coins_2000` — Mega Pack, total 2000 coins including 400 bonus

Set the base prices you want in Play Console. The app reads the localized price from Google Play, so changing prices later does not require an app rebuild.

## 7. Firebase — add Play App Signing SHA-1 after first AAB upload
Play Console → App integrity → App signing key certificate → copy SHA-1.
Add that SHA-1 to the SAME Firebase Android app.

This server-side fingerprint is needed for Google Sign-In on Play-signed installs. The code/package does not need to change just for this fingerprint.

## 8. AdMob privacy setup
In AdMob → Privacy & messaging, configure the applicable user message/consent setup for the audiences/regions you distribute to. The app already uses the Google UMP flow and exposes `Settings → Ad Privacy Options` when required.

## 9. GitHub Pages / Play Console
Host the `docs` folder with GitHub Pages and use:
- `privacy-policy.html` as the public Privacy Policy
- `delete-account.html` as the public account-deletion information page

Complete Play Console Data safety and target-audience/ads declarations according to the final app configuration.

## No rebuild needed for these later Console-only changes
Once the connected v1.2.0 AAB has been uploaded, these changes do not require changing app code:
- creating/activating the six pre-wired coin products
- changing their Play Console prices
- adding the Play App Signing SHA-1 to Firebase
- AdMob account/app review status

A rebuild is needed only if app code/config itself changes (for example changing package ID, AdMob IDs, product IDs, or adding a new SDK/feature).
