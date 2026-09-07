import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/local_content_service.dart';
import 'topic_list_screen.dart';

class WritingCategoriesScreen extends StatelessWidget {
  const WritingCategoriesScreen({super.key, required this.appState});
  final AppState appState;

  IconData _iconFor(String id) {
    switch (id) {
      case 'paragraphs': return Icons.article_outlined;
      case 'compositions': return Icons.description_outlined;
      case 'stories': return Icons.auto_stories_outlined;
      case 'completing_stories': return Icons.history_edu_outlined;
      case 'dialogues': return Icons.forum_outlined;
      case 'letters': return Icons.mail_outline;
      case 'emails': return Icons.alternate_email_rounded;
      case 'reports': return Icons.newspaper_outlined;
      case 'cv_job': return Icons.work_outline_rounded;
      default: return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appState.t('রাইটিং', 'Writing'))),
      body: FutureBuilder<List<dynamic>>(
        future: LocalContentService.loadWritingCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final item = Map<String, dynamic>.from(items[i]);
              final title = appState.isBangla ? item['title_bn'] : item['title_en'];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  leading: CircleAvatar(child: Icon(_iconFor('${item['id']}'))),
                  title: Text('$title', style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text(appState.t('Topic list দেখুন', 'Browse topics')),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TopicListScreen(
                        appState: appState,
                        title: '$title',
                        fileName: '${item['file']}',
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
