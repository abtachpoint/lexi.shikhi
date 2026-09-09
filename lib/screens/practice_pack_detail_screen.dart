import 'package:flutter/material.dart';
import '../app_state.dart';
import 'practice_detail_screen.dart';

class PracticePackDetailScreen extends StatelessWidget {
  const PracticePackDetailScreen({
    super.key,
    required this.appState,
    required this.pack,
    required this.items,
  });

  final AppState appState;
  final Map<String, dynamic> pack;
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final title = appState.isBangla
        ? '${pack['title_bn'] ?? pack['title_en']}'
        : '${pack['title_en'] ?? pack['title_bn']}';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 9),
        itemBuilder: (context, index) {
          final item = items[index];
          final id = '${item['id']}';
          final completed = appState.isPracticeCompleted(id);
          final reward = (item['reward_coin'] as num?)?.toInt() ?? 0;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(
                  completed ? Icons.check_rounded : Icons.quiz_outlined,
                ),
              ),
              title: Text(
                '${item['title']}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                completed
                    ? appState.t('সম্পন্ন • আবার ফ্রি প্র্যাকটিস করুন', 'Completed • practice again free')
                    : reward > 0
                        ? appState.t('প্রথমবার সম্পন্ন করলে +$reward কয়েন', 'First completion: +$reward coin')
                        : appState.t('প্র্যাকটিস শুরু করুন', 'Start practice'),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PracticeDetailScreen(
                    appState: appState,
                    item: item,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
