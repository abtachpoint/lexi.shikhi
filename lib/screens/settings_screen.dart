import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config/app_config.dart';
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
                  title: Text(appState.t('Interface Language: বাংলা', 'Interface Language: English')),
                  subtitle: Text(appState.t('English করতে switch করুন', 'Switch to Bangla')),
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
                  subtitle: Text(appState.t('Preference এখন localভাবে save হবে', 'Preference is saved locally')),
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
                  title: Text(appState.t('Google / Email Login', 'Google / Email Login')),
                  subtitle: Text(appState.t('Firebase setup-এর সময় চালু হবে', 'Will activate with Firebase setup')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pending(context, 'Firebase Authentication'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore_rounded),
                  title: Text(appState.t('Restore Purchases', 'Restore Purchases')),
                  subtitle: Text(appState.t('IAP connect হলে কাজ করবে', 'Will work after IAP connection')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _pending(context, 'Google Play IAP'),
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
                        title: 'Privacy Policy',
                        body: _privacyText(),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(appState.t('Terms & Conditions', 'Terms & Conditions')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TextInfoScreen(
                        title: 'Terms & Conditions',
                        body: _termsText(),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(appState.t('About LexiShikhi', 'About LexiShikhi')),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TextInfoScreen(
                        title: 'About LexiShikhi',
                        body: _aboutText(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            appState.t(
              'Developer/Test option',
              'Developer/Test option',
            ),
            style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _confirmReset(context),
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(appState.t('Local progress reset করুন', 'Reset local progress')),
          ),
        ],
      ),
    );
  }

  void _pending(BuildContext context, String service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appState.t(
            '$service external connection-এর সময় setup হবে।',
            '$service will be set up during the external connection stage.',
          ),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(appState.t('Reset করবেন?', 'Reset progress?')),
        content: Text(appState.t(
          'Local coin, unlock, saved ও practice progress মুছে যাবে।',
          'Local coins, unlocks, saved items and practice progress will be cleared.',
        )),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(appState.t('না', 'Cancel'))),
          FilledButton(
            onPressed: () async {
              await appState.resetLocalProgress();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(appState.t('Reset', 'Reset')),
          ),
        ],
      ),
    );
  }

  String _privacyText() => '''
LexiShikhi Privacy Policy

This offline-first build stores learning progress, coin balance, unlocked topics, saved topics and practice statistics locally on the user’s device.

Google/Firebase login, AdMob rewarded ads and Google Play in-app purchases are not connected in this project build yet.

Before publishing a version that connects Firebase, AdMob or Google Play Billing, the public Privacy Policy and Google Play Data Safety declaration must be updated to accurately describe those services and the data they process.

No forced advertisements are intended. Rewarded advertisements, when connected, will only be shown after the user chooses to watch one.
''';

  String _termsText() => '''
LexiShikhi is an educational English-learning application. Study materials are provided for learning and practice. Users should review and adapt model writing where necessary for their own academic requirements.

Coins are an in-app learning credit system. In the current offline build, progress is stored locally. Real-money coin purchases will only function after Google Play Billing is connected.

The app should be used responsibly and in accordance with applicable Google Play policies.
''';

  String _aboutText() => '''
LexiShikhi

A Bangla-friendly English learning app.

Main areas:
• Writing
• Grammar
• Vocabulary
• Translation
• Practice
• Saved learning content

Normal study topics use small amounts of coins. Extra practice uses more coins. Once a normal topic is unlocked, it can be opened again without another coin charge.

Package: ${AppConfig.packageName}
''';
}
