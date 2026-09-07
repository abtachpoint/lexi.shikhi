import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config/app_config.dart';
import 'writing_categories_screen.dart';
import 'simple_data_screen.dart';
import 'practice_screen.dart';
import 'saved_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final items = [
      _HomeItem(
        appState.t('রাইটিং', 'Writing'),
        appState.t('Story, Paragraph, Composition ও আরও', 'Story, Paragraph, Composition & more'),
        Icons.edit_note_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WritingCategoriesScreen(appState: appState)),
        ),
      ),
      _HomeItem(
        appState.t('গ্রামার', 'Grammar'),
        appState.t('সহজ নিয়ম, উদাহরণ ও lesson', 'Rules, examples and lessons'),
        Icons.school_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SimpleDataScreen(
              appState: appState,
              titleBn: 'গ্রামার',
              titleEn: 'Grammar',
              fileName: 'grammar.json',
              itemType: DataItemType.grammar,
            ),
          ),
        ),
      ),
      _HomeItem(
        appState.t('ভোকাবুলারি', 'Vocabulary'),
        appState.t('বাংলা অর্থ ও example', 'Bangla meaning and examples'),
        Icons.menu_book_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SimpleDataScreen(
              appState: appState,
              titleBn: 'ভোকাবুলারি',
              titleEn: 'Vocabulary',
              fileName: 'vocabulary.json',
              itemType: DataItemType.vocabulary,
            ),
          ),
        ),
      ),
      _HomeItem(
        appState.t('অনুবাদ', 'Translation'),
        appState.t('বাংলা ↔ English', 'Bangla ↔ English'),
        Icons.translate_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SimpleDataScreen(
              appState: appState,
              titleBn: 'অনুবাদ',
              titleEn: 'Translation',
              fileName: 'translation.json',
              itemType: DataItemType.translation,
            ),
          ),
        ),
      ),
      _HomeItem(
        appState.t('প্র্যাকটিস', 'Practice'),
        appState.t('MCQ ও Translation challenge', 'MCQ and translation challenges'),
        Icons.quiz_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PracticeScreen(appState: appState)),
        ),
      ),
      _HomeItem(
        appState.t('সেভ করা', 'Saved'),
        appState.t('আপনার bookmarked content', 'Your bookmarked content'),
        Icons.bookmark_rounded,
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SavedScreen(appState: appState)),
        ),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3157C8), Color(0xFF6B5AD8)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.t('ইংরেজি শেখা হোক সহজ', 'Make English learning easier'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                appState.t(
                  'বাংলায় বুঝুন, English-এ পড়ুন ও practice করুন।',
                  'Read, understand and practice English in one place.',
                ),
                style: const TextStyle(color: Colors.white70, height: 1.45),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _MiniStat(icon: Icons.lock_open_rounded, value: '${appState.unlockedTopics.length}', label: appState.t('Unlocked', 'Unlocked')),
                  const SizedBox(width: 10),
                  _MiniStat(icon: Icons.quiz_rounded, value: '${appState.quizzesCompleted}', label: appState.t('Practice', 'Practice')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (appState.canClaimDailyReward)
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.card_giftcard_rounded)),
              title: Text(
                appState.t('আজকের Daily Reward', 'Today’s Daily Reward'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('+${AppConfig.dailyReward} ${appState.t('কয়েন', 'coins')}'),
              trailing: FilledButton(
                onPressed: () {
                  appState.claimDailyReward();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(appState.t('Daily reward যোগ হয়েছে।', 'Daily reward added.'))),
                  );
                },
                child: Text(appState.t('নিন', 'Claim')),
              ),
            ),
          ),
        if (appState.canClaimDailyReward) const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Text(
                appState.t('শেখার বিভাগ', 'Study Sections'),
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WalletScreen(appState: appState)),
              ),
              icon: const Icon(Icons.monetization_on_outlined),
              label: Text(appState.t('কয়েন', 'Coins')),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: .93,
          ),
          itemBuilder: (context, i) => _SectionCard(item: items[i]),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('$value $label', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _HomeItem {
  _HomeItem(this.title, this.subtitle, this.icon, this.onTap);
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.item});
  final _HomeItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(item.icon),
              ),
              const Spacer(),
              Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
              const SizedBox(height: 5),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, height: 1.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
