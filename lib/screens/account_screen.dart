import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/auth_service.dart';
import 'email_auth_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;
    return Scaffold(
      appBar: AppBar(title: Text(appState.t('Account', 'Account'))),
      body: AnimatedBuilder(
        animation: Listenable.merge([auth, appState]),
        builder: (context, _) {
          final user = auth.user;
          if (user == null) return _signedOut(context, auth);
          return _signedIn(context, auth, user);
        },
      ),
    );
  }

  Widget _signedOut(BuildContext context, AuthService auth) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const SizedBox(height: 18),
        Icon(Icons.account_circle_rounded, size: 82, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 14),
        Text(
          appState.t('Sign in করে progress sync করুন', 'Sign in to sync your progress'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 22),
        OutlinedButton.icon(
          onPressed: auth.busy ? null : () => _googleSignIn(context),
          icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
          label: Text(appState.t('Google দিয়ে Sign in', 'Sign in with Google')),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: auth.busy
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EmailAuthScreen(appState: appState)),
                  ),
          icon: const Icon(Icons.email_outlined),
          label: Text(appState.t('Email দিয়ে Sign in', 'Sign in with Email')),
        ),
        if (auth.lastError != null) ...[
          const SizedBox(height: 12),
          Text(auth.lastError!, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        ],
      ],
    );
  }

  Widget _signedIn(BuildContext context, AuthService auth, User user) {
    final name = (user.displayName?.trim().isNotEmpty ?? false)
        ? user.displayName!
        : (user.email?.split('@').first ?? 'Learner');
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundImage: user.photoURL == null ? null : NetworkImage(user.photoURL!),
                  child: user.photoURL == null ? const Icon(Icons.person_rounded, size: 34) : null,
                ),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                if (user.email != null) Text(user.email!),
                const SizedBox(height: 8),
                Chip(
                  avatar: Icon(
                    appState.cloudSyncReady ? Icons.cloud_done_rounded : Icons.cloud_sync_rounded,
                    size: 18,
                  ),
                  label: Text(
                    appState.cloudSyncReady
                        ? appState.t('Progress sync চালু', 'Progress sync active')
                        : appState.t('Sync হচ্ছে…', 'Syncing…'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: auth.busy ? null : () => auth.signOut(),
          icon: const Icon(Icons.logout_rounded),
          label: Text(appState.t('Sign out', 'Sign out')),
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          appState.t('Account deletion', 'Account deletion'),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          appState.t(
            'Account delete করলে Firebase account এবং synced learning data মুছে যাবে।',
            'Deleting your account removes the Firebase account and synced learning data.',
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: auth.busy ? null : () => _confirmDelete(context, user),
          icon: const Icon(Icons.delete_outline_rounded),
          label: Text(appState.t('Account delete করুন', 'Delete account')),
          style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
        ),
      ],
    );
  }

  Future<void> _googleSignIn(BuildContext context) async {
    final auth = AuthService.instance;
    try {
      await auth.signInWithGoogle();
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.lastError ?? appState.t('Google sign in ব্যর্থ হয়েছে।', 'Google sign-in failed.'))),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, User user) async {
    final usesPassword = user.providerData.any((p) => p.providerId == 'password');
    final password = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(appState.t('Account delete করবেন?', 'Delete account?')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(appState.t(
              'এই কাজ undo করা যাবে না। Synced progress-ও delete হবে।',
              'This cannot be undone. Synced progress will also be deleted.',
            )),
            if (usesPassword) ...[
              const SizedBox(height: 12),
              TextField(
                controller: password,
                obscureText: true,
                decoration: InputDecoration(labelText: appState.t('Password', 'Password')),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(appState.t('Cancel', 'Cancel'))),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(appState.t('Delete', 'Delete')),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      password.dispose();
      return;
    }
    final ok = await AuthService.instance.deleteCurrentAccount(
      password: usesPassword ? password.text : null,
    );
    password.dispose();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? appState.t('Account delete হয়েছে।', 'Account deleted.')
              : (AuthService.instance.lastError ?? appState.t('Account delete করা যায়নি।', 'Could not delete account.')),
        ),
      ),
    );
  }
}
