import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config/app_config.dart';
import '../services/purchase_service.dart';
import '../services/rewarded_ad_service.dart';
import 'account_screen.dart';
import 'text_info_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appState.t('সেটিংস', 'Settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.language_rounded),
                  title: Text(
                    appState.t(
                      'Interface Language: বাংলা',
                      'Interface Language: English',
                    ),
                  ),
                  subtitle: Text(
                    appState.t('English করতে switch করুন', 'Switch to Bangla'),
                  ),
                  value: !appState.isBangla,
                  onChanged: (_) => appState.toggleLanguage(),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: Text(appState.t('Dark Mode', 'Dark Mode')),
                  value: appState.isDarkMode,
                  onChanged: appState.setDarkMode,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: Text(appState.t('Notification', 'Notifications')),
                  subtitle: Text(
                    appState.t(
                      'অ্যাপ notification preference',
                      'App notification preference',
                    ),
                  ),
                  value: appState.notificationsEnabled,
                  onChanged: appState.setNotifications,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.login_rounded),
                  title: Text(
                    appState.t('Google / Email Login', 'Google / Email Login'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountScreen(appState: appState),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore_rounded),
                  title: Text(
                    appState.t('Restore Purchases', 'Restore Purchases'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _restorePurchases(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(appState.t('Privacy Policy', 'Privacy Policy')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TextInfoScreen(
                        title: appState.t('Privacy Policy', 'Privacy Policy'),
                        body: _privacyText(),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.ads_click_rounded),
                  title: Text(
                    appState.t('Ad Privacy Options', 'Ad Privacy Options'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openAdPrivacyOptions(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(
                    appState.t('Terms & Conditions', 'Terms & Conditions'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TextInfoScreen(
                        title: appState.t(
                          'Terms & Conditions',
                          'Terms & Conditions',
                        ),
                        body: _termsText(),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(
                    appState.t('About LexiShikhi', 'About LexiShikhi'),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TextInfoScreen(
                        title: appState.t(
                          'LexiShikhi সম্পর্কে',
                          'About LexiShikhi',
                        ),
                        body: _aboutText(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAdPrivacyOptions(BuildContext context) async {
    final service = RewardedAdService.instance;
    final shown = await service.showPrivacyOptions();
    if (!context.mounted) return;
    if (!shown) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.t(
              'এই মুহূর্তে আলাদা ad privacy form প্রয়োজন নেই।',
              'No additional ad privacy form is required right now.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _restorePurchases(BuildContext context) async {
    final service = PurchaseService.instance;
    if (!service.storeAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.t(
              'Google Play purchase service এখন পাওয়া যাচ্ছে না।',
              'Google Play purchase service is not available right now.',
            ),
          ),
        ),
      );
      return;
    }
    await service.restorePurchases();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.t(
              'Google Play restore request পাঠানো হয়েছে।',
              'Google Play restore request sent.',
            ),
          ),
        ),
      );
    }
  }

  String _privacyText() => appState.t(
        '''LexiShikhi Privacy Policy

LexiShikhi একটি English learning app। এই Privacy Policy ব্যাখ্যা করে app ব্যবহার করার সময় কোন তথ্য সংরক্ষণ বা process হতে পারে এবং কীভাবে তা ব্যবহার করা হয়।

1. Local app data
LexiShikhi আপনার device-এ coin balance, unlocked topics, saved topics, practice progress, language preference, dark mode এবং অন্যান্য app preference সংরক্ষণ করতে পারে।

2. Account and Firebase
Google বা Email login ব্যবহার করলে Firebase Authentication account sign-in পরিচালনা করতে পারে। Account sync চালু থাকলে user ID, email/display name এবং learning progress-এর মতো app data Firebase services-এ সংরক্ষণ হতে পারে, যাতে supported device-এ account data sync করা যায়।

3. Rewarded advertisements
LexiShikhi কোনো forced ad দেখানোর উদ্দেশ্যে তৈরি নয়। Rewarded ad শুধু user নিজে Watch Ad option বেছে নিলে দেখানো হবে। Google AdMob ad delivery, fraud prevention, measurement এবং applicable consent settings-এর জন্য device/ad-related information process করতে পারে।

4. In-app purchases
Coin pack purchase Google Play Billing-এর মাধ্যমে process হবে। দাম Google Play user-এর country/currency অনুযায়ী দেখাবে। LexiShikhi আপনার full payment card details গ্রহণ বা সংরক্ষণ করে না। Google Play purchase status ও product information app-এ পাঠাতে পারে, যাতে purchased coins deliver করা যায়।

5. How information is used
তথ্য app feature চালানো, progress সংরক্ষণ, purchase deliver করা, account sync, abuse prevention এবং app experience উন্নত করার জন্য ব্যবহার হতে পারে।

6. Data sharing
LexiShikhi প্রয়োজন ছাড়া personal data বিক্রি করে না। Firebase, Google Play এবং AdMob-এর মতো service provider তাদের service পরিচালনার জন্য প্রয়োজনীয় তথ্য process করতে পারে এবং তাদের নিজস্ব privacy terms প্রযোজ্য হতে পারে।

7. Data control
Local app data clear/uninstall করলে device থেকে মুছে যেতে পারে। Signed-in user Settings → Google / Email Login → Delete account থেকে Firebase account এবং synced LexiShikhi learning data delete করতে পারে। Ad privacy choice পরিবর্তনের option প্রয়োজন হলে Settings → Ad Privacy Options ব্যবহার করা যাবে। App access করা না গেলে public Account Deletion page বা Google Play listing-এর developer contact ব্যবহার করা যাবে।

8. Changes to this policy
App feature বা service পরিবর্তন হলে এই Privacy Policy update করা হতে পারে। Updated policy app বা public policy page-এ প্রকাশ করা হবে।''',
        '''LexiShikhi Privacy Policy

LexiShikhi is an English-learning application. This Privacy Policy explains the information that may be stored or processed when you use the app and how it may be used.

1. Local app data
LexiShikhi may store your coin balance, unlocked topics, saved topics, practice progress, language preference, dark-mode preference, and other app settings on your device.

2. Account and Firebase
If you use Google or Email sign-in, Firebase Authentication may process account sign-in. When account sync is enabled, app data such as your user ID, email/display name, and learning progress may be stored using Firebase services so supported devices can sync account data.

3. Rewarded advertisements
LexiShikhi is designed without forced advertisements. A rewarded ad is shown only after you choose the Watch Ad option. Google AdMob may process device or advertising-related information for ad delivery, fraud prevention, measurement, and applicable consent settings.

4. In-app purchases
Coin-pack purchases are processed through Google Play Billing. Prices are provided by Google Play in the user’s applicable country and currency. LexiShikhi does not receive or store your full payment-card details. Google Play may provide purchase status and product information so purchased coins can be delivered.

5. How information is used
Information may be used to provide app features, preserve learning progress, deliver purchases, sync account data, prevent abuse, and improve the app experience.

6. Data sharing
LexiShikhi does not sell personal data. Service providers such as Firebase, Google Play, and AdMob may process information necessary to provide their services and may apply their own privacy terms.

7. Data control
Local app data may be removed by clearing app data or uninstalling the app. Signed-in users can delete their Firebase account and synced LexiShikhi learning data from Settings → Google / Email Login → Delete account. If an ad privacy entry point is required, Settings → Ad Privacy Options lets users reopen the applicable privacy form. If the app cannot be accessed, use the public Account Deletion page or the developer contact information shown on the Google Play listing.

8. Changes to this policy
This Privacy Policy may be updated when app features or services change. The updated policy will be made available in the app or on the public policy page.''',
      );

  String _termsText() => appState.t(
        '''LexiShikhi Terms & Conditions

LexiShikhi শিক্ষামূলক English-learning content, model writing, grammar, vocabulary, translation এবং practice প্রদান করে। Content শেখা ও practice-এর জন্য; academic requirement অনুযায়ী user প্রয়োজন হলে content review বা adapt করবে।

Coin হলো app-এর learning credit। Normal topic, practice pack বা অন্য eligible feature unlock করতে coin ব্যবহার হতে পারে। একবার permanently unlocked হিসেবে দেখানো content পুনরায় খুলতে একই unlock charge নেওয়া হবে না।

Real-money coin purchase Google Play Billing-এর মাধ্যমে process হবে। Purchase completion Google Play-এর নিয়ম ও availability-এর উপর নির্ভরশীল।

Rewarded ad সম্পূর্ণ optional। User নিজে ad দেখার option বেছে নিলে reward পাওয়ার যোগ্য হবে।

App-এর misuse, unauthorized modification, purchase manipulation বা service abuse অনুমোদিত নয়।''',
        '''LexiShikhi Terms & Conditions

LexiShikhi provides educational English-learning content, model writing, grammar, vocabulary, translation, and practice. Content is intended for learning and practice, and users should review or adapt model material where required by their academic needs.

Coins are in-app learning credits. Coins may be used to unlock normal topics, practice packs, or other eligible features. Content shown as permanently unlocked will not charge the same unlock cost again when reopened.

Real-money coin purchases are processed through Google Play Billing and are subject to Google Play availability and transaction rules.

Rewarded ads are optional. A user becomes eligible for the stated reward only after choosing to watch an eligible rewarded ad.

Misuse of the app, unauthorized modification, purchase manipulation, or abuse of app services is not permitted.''',
      );

  String _aboutText() => appState.t(
        '''LexiShikhi

বাংলা-friendly English learning app।

Main sections:
• Writing
• Grammar
• Vocabulary
• Translation
• Practice Packs
• Saved content

Normal study topics অল্প coin দিয়ে unlock করা যায়। Practice section-এ অনেকগুলো practice একসাথে pack হিসেবে unlock করা যায়। একবার unlock হলে content পুনরায় পড়তে নতুন coin লাগে না।

Package: ${AppConfig.packageName}''',
        '''LexiShikhi

A Bangla-friendly English learning app.

Main sections:
• Writing
• Grammar
• Vocabulary
• Translation
• Practice Packs
• Saved content

Normal study topics use small amounts of coins. The Practice section groups multiple exercises into packs that can be unlocked together. Once content is unlocked, reopening it does not require another unlock charge.

Package: ${AppConfig.packageName}''',
      );
}
