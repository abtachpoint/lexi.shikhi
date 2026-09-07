import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/local_content_service.dart';
import 'topic_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    if (appState.savedTopics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bookmark_border_rounded, size: 64),
              const SizedBox(height: 14),
              Text(
                appState.t('এখনও কিছু Save করা হয়নি', 'Nothing saved yet'),
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 7),
              Text(
                appState.t(
                  'Unlocked topic থেকে bookmark চাপলে এখানে দেখা যাবে।',
                  'Bookmark an unlocked topic and it will appear here.',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<Map<String, Map<String, dynamic>>>(
      future: LocalContentService.loadContentIndex(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final index = snapshot.data!;
        final saved = appState.savedTopics.map((id) => index[id]).whereType<Map<String, dynamic>>().toList();

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: saved.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            final item = saved[i];
            final title = appState.isBangla
                ? '${item['title_bn'] ?? item['title_en']}'
                : '${item['title_en'] ?? item['title_bn']}';
            return Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.bookmark_rounded)),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TopicDetailScreen(appState: appState, item: item)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
