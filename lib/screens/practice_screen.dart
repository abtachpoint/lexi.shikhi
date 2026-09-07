import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/local_content_service.dart';
import 'practice_detail_screen.dart';
import 'wallet_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: LocalContentService.loadPractice(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final items = snapshot.data!.map((e) => Map<String, dynamic>.from(e)).toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              appState.t('Practice Sets', 'Practice Sets'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              appState.t(
                'Extra practice-এ basic topic-এর চেয়ে একটু বেশি coin লাগে।',
                'Extra practice costs a little more than normal reading topics.',
              ),
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            ...items.map((item) {
              final cost = (item['coin_cost'] as num?)?.toInt() ?? 2;
              final reward = (item['reward_coin'] as num?)?.toInt() ?? 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.quiz_outlined)),
                    title: Text('${item['title']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(
                      '$cost ${appState.t('কয়েন', cost == 1 ? 'coin' : 'coins')}'
                      '${reward > 0 ? ' • +$reward ${appState.t('reward', 'reward')}' : ''}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (!appState.spendCoins(cost, 'Practice: ${item['title']}')) {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(appState.t('কয়েন কম আছে', 'Not enough coins')),
                            content: Text(appState.t('Practice শুরু করতে আরও কয়েন দরকার।', 'You need more coins to start this practice.')),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: Text(appState.t('বন্ধ', 'Close'))),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => WalletScreen(appState: appState)));
                                },
                                child: Text(appState.t('কয়েন নিন', 'Get coins')),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PracticeDetailScreen(appState: appState, item: item),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
