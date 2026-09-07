# LexiShikhi Final Local Project

Package: `com.lexishikhi.learnenglish`
Version: `1.0.0+1`
Android compile/target SDK: 36

## Ready in this project
- Bangla + English interface
- First-launch language selection
- Google/Email login UI placeholder (real Firebase connection later)
- Home screen with coin balance in top-right
- Writing categories with searchable topic lists
- Grammar, Vocabulary and Translation
- Coin-based permanent unlock for normal study topics
- Saved/bookmark system
- Local persistent coins, unlocks, saves and practice stats
- Daily reward
- Functional MCQ and translation practice engine
- Wallet + coin history
- Rewarded Ad UI placeholder (no forced ads; real AdMob connection later)
- IAP pack UI with planned prices
- Settings, local Privacy Policy draft, Terms and About
- Complete Android project structure
- Codemagic workflow for APK + AAB

## Loaded content
Total study/practice records: 510

{
  "paragraphs.json": 50,
  "compositions.json": 30,
  "stories.json": 20,
  "completing_stories.json": 20,
  "dialogues.json": 15,
  "letters_applications.json": 15,
  "emails.json": 10,
  "reports.json": 10,
  "cv_job.json": 10,
  "grammar.json": 20,
  "vocabulary.json": 100,
  "translation.json": 80,
  "practice.json": 130
}

## External connections intentionally left for later
1. Firebase Authentication / Firestore
2. Google Sign-In and Email Sign-In
3. AdMob Rewarded Ads
4. Google Play Billing / IAP
5. Production release signing keystore
6. Final public Privacy Policy URL and Data Safety declaration

## Important before Play Store release
The Android release build currently uses debug signing only so Codemagic can create a test APK/AAB without your private keystore. Before Play Console production upload, connect your existing release keystore in Codemagic and update the signing configuration.

The included Privacy Policy text describes the current offline-first build. Update it after Firebase, AdMob and IAP are connected.
