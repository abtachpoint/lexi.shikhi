# External setup status — v1.2.0

Already connected in source:
- Firebase Core
- Firebase Google + Email/Password Authentication code
- Cloud Firestore sync
- AdMob App ID and Rewarded Ad unit
- UMP ad privacy/consent flow
- Google Play Billing code and BILLING permission
- exact future Play product IDs

Still done outside the source project:
1. Add upload-keystore SHA-1 to Firebase.
2. Add `lexishikhi_upload` signing identity to Codemagic.
3. Build APK + AAB once.
4. Upload AAB to Play Internal testing.
5. Create/activate the six one-time products in Play Console.
6. Add Play App Signing SHA-1 to Firebase.
7. Configure AdMob Privacy & messaging and Play Console declarations.

See `FINAL_SETUP_STEPS.md` for exact order.
