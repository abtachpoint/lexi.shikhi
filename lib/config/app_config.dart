class AppConfig {
  static const String appName = 'LexiShikhi';
  static const String packageName = 'com.lexishikhi.learnenglish';

  static const int newUserBonus = 20;
  static const int dailyReward = 2;
  static const int rewardedAdCoins = 5;
  static const int rewardedAdDailyLimit = 5;

  static const String admobAppId =
      'ca-app-pub-1379059201302335~6857743269';
  static const String admobRewardedAdUnitId =
      'ca-app-pub-1379059201302335/7979253240';

  // Google test rewarded ad. The Codemagic APK uses this automatically so
  // you can test safely. The AAB uses the real AdMob unit above.
  static const String googleTestRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const bool useTestAds =
      bool.fromEnvironment('USE_TEST_ADS', defaultValue: false);

  static String get rewardedAdUnitId =>
      useTestAds ? googleTestRewardedAdUnitId : admobRewardedAdUnitId;
}
