import 'package:flutter/material.dart';
import '../app_state.dart';
import 'wallet_screen.dart';

class TopicDetailScreen extends StatefulWidget {
  const TopicDetailScreen({
    super.key,
    required this.appState,
    required this.item,
  });

  final AppState appState;
  final Map<String, dynamic> item;

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final item = widget.item;
    final id = '${item['id']}';
    final cost = (item['coin_cost'] as num?)?.toInt() ?? 1;
    final unlocked = appState.isUnlocked(id);
    final title = appState.isBangla
        ? '${item['title_bn'] ?? item['title_en'] ?? ''}'
        : '${item['title_en'] ?? item['title_bn'] ?? ''}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: unlocked
            ? [
                IconButton(
                  tooltip: appState.t('Save', 'Save'),
                  onPressed: () {
                    appState.toggleSaved(id);
                    setState(() {});
                  },
                  icon: Icon(appState.isSaved(id) ? Icons.bookmark : Icons.bookmark_border),
                ),
              ]
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (!unlocked)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_rounded, size: 40, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 14),
                    Text(
                      appState.t('এই Topic টি লক করা', 'This topic is locked'),
                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${item['preview'] ?? ''}',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(height: 1.5),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          if (appState.unlock(id, cost, title: title)) {
                            setState(() {});
                          } else {
                            _showNotEnoughCoins();
                          }
                        },
                        icon: const Icon(Icons.monetization_on_rounded),
                        label: Text(
                          '${appState.t('Unlock করুন', 'Unlock')} • $cost ${appState.t('কয়েন', cost == 1 ? 'coin' : 'coins')}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      appState.t(
                        'একবার unlock করলে পরে আবার কয়েন লাগবে না।',
                        'Once unlocked, you can read it again without paying coins.',
                      ),
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            _ContentCard(
              title: appState.t('English Answer', 'English Answer'),
              text: '${item['content'] ?? item['lesson'] ?? ''}',
            ),
            if ('${item['bangla_explanation'] ?? ''}'.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _ContentCard(
                title: appState.t('বাংলায় ব্যাখ্যা', 'Bangla Explanation'),
                text: '${item['bangla_explanation']}',
              ),
            ],
            if (item['examples'] is List) ...[
              const SizedBox(height: 12),
              _ContentCard(
                title: appState.t('উদাহরণ', 'Examples'),
                text: (item['examples'] as List).join('\n'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  void _showNotEnoughCoins() {
    final appState = widget.appState;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(appState.t('কয়েন কম আছে', 'Not enough coins')),
        content: Text(
          appState.t(
            'এই Topic unlock করতে আরও কয়েন দরকার।',
            'You need more coins to unlock this topic.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.t('বন্ধ করুন', 'Close')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => WalletScreen(appState: appState)),
              );
            },
            child: Text(appState.t('কয়েন নিন', 'Get coins')),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            SelectableText(text, style: const TextStyle(fontSize: 16, height: 1.65)),
          ],
        ),
      ),
    );
  }
}
