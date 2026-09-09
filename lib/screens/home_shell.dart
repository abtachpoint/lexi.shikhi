import 'package:flutter/material.dart';
import '../app_state.dart';
import 'home_screen.dart';
import 'practice_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';
import 'wallet_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.appState});
  final AppState appState;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  void _selectTab(int value) {
    if (value == index) return;
    setState(() => index = value);
  }

  void _openWallet() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WalletScreen(appState: widget.appState),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final pages = [
      HomeScreen(
        appState: state,
        onOpenPractice: () => _selectTab(1),
        onOpenSaved: () => _selectTab(2),
      ),
      PracticeScreen(appState: state),
      SavedScreen(appState: state),
      ProfileScreen(appState: state),
    ];
    final titles = [
      'LexiShikhi',
      state.t('প্র্যাকটিস', 'Practice'),
      state.t('সেভ করা', 'Saved'),
      state.t('প্রোফাইল', 'Profile'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[index],
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          TextButton(
            onPressed: _openWallet,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: const Size(0, 40),
            ),
            child: Text(
              state.t('কয়েন কিনুন', 'Buy Coins'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ActionChip(
              avatar: const Icon(Icons.monetization_on_rounded, size: 19),
              label: Text(
                '${state.coins}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              onPressed: _openWallet,
            ),
          ),
        ],
      ),
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: _selectTab,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: state.t('হোম', 'Home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.quiz_outlined),
            selectedIcon: const Icon(Icons.quiz_rounded),
            label: state.t('প্র্যাকটিস', 'Practice'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border),
            selectedIcon: const Icon(Icons.bookmark),
            label: state.t('সেভ', 'Saved'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: state.t('প্রোফাইল', 'Profile'),
          ),
        ],
      ),
    );
  }
}
