import 'package:flutter/material.dart';
import '../app_state.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final accuracy = appState.quizzesCompleted == 0
        ? 0
        : ((appState.correctAnswers / appState.quizzesCompleted) * 100).round();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const CircleAvatar(radius: 31, child: Icon(Icons.person_rounded, size: 33)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appState.t('Guest Learner', 'Guest Learner'), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      Text(appState.t('Firebase connect হলে account sync হবে', 'Account sync will activate with Firebase')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: [
              _statTile(Icons.lock_open_rounded, appState.t('Unlocked Topics', 'Unlocked Topics'), '${appState.unlockedTopics.length}'),
              const Divider(height: 1),
              _statTile(Icons.bookmark_rounded, appState.t('Saved Topics', 'Saved Topics'), '${appState.savedTopics.length}'),
              const Divider(height: 1),
              _statTile(Icons.quiz_rounded, appState.t('Practice Completed', 'Practice Completed'), '${appState.quizzesCompleted}'),
              const Divider(height: 1),
              _statTile(Icons.insights_rounded, appState.t('Correct Rate', 'Correct Rate'), '$accuracy%'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(appState.t('সেটিংস', 'Settings'), style: const TextStyle(fontWeight: FontWeight.w800)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen(appState: appState)),
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
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}
