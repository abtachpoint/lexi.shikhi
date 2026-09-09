import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/local_content_service.dart';
import 'practice_pack_detail_screen.dart';
import 'wallet_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        LocalContentService.loadPracticePacks(),
        LocalContentService.loadPractice(),
      ]).then((value) => <dynamic>[value[0], value[1]]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final packs = (snapshot.data![0] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        final practiceItems = (snapshot.data![1] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        final practiceById = <String, Map<String, dynamic>>{
          for (final item in practiceItems) '${item['id']}': item,
        };

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appState.t('প্র্যাকটিস প্যাক', 'Practice Packs'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appState.t(
                      'একটি প্যাক একবার কয়েন দিয়ে আনলক করলে ভেতরের সব প্র্যাকটিস স্থায়ীভাবে খুলে যাবে।',
                      'Unlock a pack once with coins and every practice inside it stays open permanently.',
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...packs.map((pack) {
              final id = '${pack['id']}';
              final unlocked = appState.isPracticePackUnlocked(id);
              final cost = (pack['coin_cost'] as num?)?.toInt() ?? 0;
              final itemIds = (pack['item_ids'] as List<dynamic>?)
                      ?.map((e) => '$e')
                      .toList() ??
                  const <String>[];
              final items = itemIds
                  .map((itemId) => practiceById[itemId])
                  .whereType<Map<String, dynamic>>()
                  .toList();
              final title = appState.isBangla
                  ? '${pack['title_bn'] ?? pack['title_en']}'
                  : '${pack['title_en'] ?? pack['title_bn']}';
              final description = appState.isBangla
                  ? '${pack['description_bn'] ?? ''}'
                  : '${pack['description_en'] ?? ''}';
              final completedCount = items
                  .where((item) => appState.isPracticeCompleted('${item['id']}'))
                  .length;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      child: Icon(
                        unlocked ? Icons.lock_open_rounded : Icons.inventory_2_outlined,
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16.5,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        unlocked
                            ? appState.t(
                                '$completedCount/${items.length} সম্পন্ন • সব খোলা',
                                '$completedCount/${items.length} completed • all unlocked',
                              )
                            : '$description • $cost ${appState.t('কয়েন', cost == 1 ? 'coin' : 'coins')}',
                        style: const TextStyle(height: 1.35),
                      ),
                    ),
                    trailing: Icon(
                      unlocked ? Icons.chevron_right : Icons.lock_outline_rounded,
                    ),
                    onTap: () {
                      if (unlocked) {
                        _openPack(context, pack, items);
                        return;
                      }
                      _confirmUnlock(context, pack, items, cost);
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

  void _openPack(
    BuildContext context,
    Map<String, dynamic> pack,
    List<Map<String, dynamic>> items,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PracticePackDetailScreen(
          appState: appState,
          pack: pack,
          items: items,
        ),
      ),
    );
  }

  void _confirmUnlock(
    BuildContext context,
    Map<String, dynamic> pack,
    List<Map<String, dynamic>> items,
    int cost,
  ) {
    final title = appState.isBangla
        ? '${pack['title_bn'] ?? pack['title_en']}'
        : '${pack['title_en'] ?? pack['title_bn']}';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(appState.t('প্যাক আনলক করবেন?', 'Unlock this pack?')),
        content: Text(
          appState.t(
            '$cost কয়েন দিয়ে “$title” আনলক করলে ভেতরের ${items.length}টি প্র্যাকটিস স্থায়ীভাবে খুলে যাবে।',
            'Unlock “$title” for $cost coins and all ${items.length} practices inside will stay open permanently.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.t('না', 'Cancel')),
          ),
          FilledButton(
            onPressed: () {
              final ok = appState.unlockPracticePack(
                '${pack['id']}',
                cost,
                title: title,
              );
              Navigator.pop(context);
              if (ok) {
                _openPack(context, pack, items);
              } else {
                _showNotEnoughCoins(context);
              }
            },
            child: Text(appState.t('$cost কয়েন', '$cost coins')),
          ),
        ],
      ),
    );
  }

  void _showNotEnoughCoins(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(appState.t('কয়েন কম আছে', 'Not enough coins')),
        content: Text(
          appState.t(
            'এই প্যাক আনলক করতে আরও কয়েন দরকার।',
            'You need more coins to unlock this pack.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.t('বন্ধ', 'Close')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WalletScreen(appState: appState),
                ),
              );
            },
            child: Text(appState.t('কয়েন নিন', 'Get coins')),
          ),
        ],
      ),
    );
  }
}
