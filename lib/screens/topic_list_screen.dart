import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/local_content_service.dart';
import 'topic_detail_screen.dart';

class TopicListScreen extends StatefulWidget {
  const TopicListScreen({
    super.key,
    required this.appState,
    required this.title,
    required this.fileName,
  });

  final AppState appState;
  final String title;
  final String fileName;

  @override
  State<TopicListScreen> createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: LocalContentService.loadNormalized(widget.fileName),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final all = snapshot.data!;
          final items = all.where((e) {
            final text = '${e['title_en'] ?? ''} ${e['title_bn'] ?? ''} ${e['content'] ?? ''}'.toLowerCase();
            return text.contains(query.toLowerCase());
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  onChanged: (v) => setState(() => query = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: widget.appState.t('Topic খুঁজুন', 'Search topics'),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    final id = '${item['id']}';
                    final cost = (item['coin_cost'] as num?)?.toInt() ?? 1;
                    final unlocked = widget.appState.isUnlocked(id);
                    final title = widget.appState.isBangla
                        ? '${item['title_bn'] ?? item['title_en']}'
                        : '${item['title_en'] ?? item['title_bn']}';

                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text(
                          unlocked
                              ? widget.appState.t('Unlocked • আবার কয়েন লাগবে না', 'Unlocked • no more coins needed')
                              : '$cost ${widget.appState.t('কয়েন', cost == 1 ? 'coin' : 'coins')}',
                        ),
                        trailing: Icon(unlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TopicDetailScreen(appState: widget.appState, item: item),
                          ),
                        ).then((_) => setState(() {})),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
