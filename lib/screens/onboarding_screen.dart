import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config/app_config.dart';
import 'home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.appState});
  final AppState appState;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int step = 0;

  void _continue() {
    if (step == 0) {
      setState(() => step = 1);
      return;
    }
    widget.appState.completeOnboarding();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeShell(appState: widget.appState)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: step == 0 ? _languageStep(state) : _loginStep(state),
        ),
      ),
    );
  }

  Widget _languageStep(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        CircleAvatar(
          radius: 46,
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.auto_stories_rounded,
            size: 46,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'LexiShikhi',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          state.t(
            'বাংলায় বুঝে English শিখুন',
            'Learn English with a simple bilingual interface',
          ),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
        ),
        const SizedBox(height: 32),
        _languageTile(
          title: 'বাংলা',
          subtitle: 'বাংলা interface ব্যবহার করুন',
          selected: state.isBangla,
          onTap: () => state.setLanguage(true),
        ),
        const SizedBox(height: 10),
        _languageTile(
          title: 'English',
          subtitle: 'Use English interface',
          selected: !state.isBangla,
          onTap: () => state.setLanguage(false),
        ),
        const Spacer(),
        FilledButton(
          onPressed: _continue,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(state.t('চালিয়ে যান', 'Continue')),
          ),
        ),
      ],
    );
  }

  Widget _loginStep(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Icon(
          Icons.account_circle_rounded,
          size: 92,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          state.t('আপনার শেখা শুরু করুন', 'Start learning'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Text(
          state.t(
            'নতুন user হিসেবে ${AppConfig.newUserBonus} কয়েন দিয়ে শুরু করুন। Google/Email login Firebase যুক্ত করার সময় চালু হবে।',
            'Start with ${AppConfig.newUserBonus} welcome coins. Google/Email sign-in will activate when Firebase is connected.',
          ),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, height: 1.45),
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: () => _pendingMessage(state),
          icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
          label: Text(state.t('Google দিয়ে Sign in', 'Sign in with Google')),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _pendingMessage(state),
          icon: const Icon(Icons.email_outlined),
          label: Text(state.t('Email দিয়ে Sign in', 'Sign in with Email')),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _continue,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(state.t('এখন Guest হিসেবে চালান', 'Continue as Guest')),
          ),
        ),
        const Spacer(),
      ],
    );
  }

  void _pendingMessage(AppState state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.t(
            'Firebase connection-এর সময় এই login চালু হবে।',
            'This login will be activated during Firebase setup.',
          ),
        ),
      ),
    );
  }

  Widget _languageTile({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Text(title.substring(0, 1))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: Icon(
          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: selected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
    );
  }
}
