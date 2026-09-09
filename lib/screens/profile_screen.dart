import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/auth_service.dart';
import 'account_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final accuracy = appState.quizzesCompleted == 0
        ? 0
        : ((appState.correctAnswers / appState.quizzesCompleted) * 100).round();
    final user = AuthService.instance.user;
    final name = user == null
        ? appState.t('Guest Learner', 'Guest Learner')
        : ((user.displayName?.trim().isNotEmpty ?? false)
            ? user.displayName!
            : (user.email?.split('@').first ?? 'Learner'));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AccountScreen(appState: appState)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 31,
                    backgroundImage:
                        user?.photoURL == null ? null : NetworkImage(user!.photoURL!),
                    child: user?.photoURL == null
                        ? const Icon(Icons.person_rounded, size: 33)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          user?.email ??
                              appState.t(
                                'Sign in করলে progress sync হবে',
                                'Sign in to sync progress',
                              ),
                        ),
                        if (user != null)
                          Text(
                            appState.cloudSyncReady
                                ? appState.t('Cloud sync চালু', 'Cloud sync active')
                                : appState.t('Sync হচ্ছে…', 'Syncing…'),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              _statTile(
                Icons.lock_open_rounded,
                appState.t('Unlocked Topics', 'Unlocked Topics'),
                '${appState.unlockedTopics.length}',
              ),
              const Divider(height: 1),
              _statTile(
                Icons.inventory_2_outlined,
                appState.t('Unlocked Practice Packs', 'Unlocked Practice Packs'),
                '${appState.unlockedPracticePacks.length}',
              ),
              const Divider(height: 1),
              _statTile(
                Icons.bookmark_rounded,
                appState.t('Saved Topics', 'Saved Topics'),
                '${appState.savedTopics.length}',
              ),
              const Divider(height: 1),
              _statTile(
                Icons.quiz_rounded,
                appState.t('Practice Completed', 'Practice Completed'),
                '${appState.completedPracticeIds.length}',
              ),
              const Divider(height: 1),
              _statTile(
                Icons.insights_rounded,
                appState.t('Correct Rate', 'Correct Rate'),
                '$accuracy%',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(
              appState.t('সেটিংস', 'Settings'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(appState: appState),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statTile(IconData icon, String title, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
    );
  }
}
