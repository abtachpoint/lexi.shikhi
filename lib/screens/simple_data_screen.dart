import 'package:flutter/material.dart';
import '../app_state.dart';
import '../services/local_content_service.dart';
import 'topic_detail_screen.dart';

enum DataItemType { grammar, vocabulary, translation }

class SimpleDataScreen extends StatefulWidget {
  const SimpleDataScreen({
    super.key,
    required this.appState,
    required this.titleBn,
    required this.titleEn,
    required this.fileName,
    required this.itemType,
  });

  final AppState appState;
  final String titleBn;
  final String titleEn;
  final String fileName;
  final DataItemType itemType;

  @override
  State<SimpleDataScreen> createState() => _SimpleDataScreenState();
}

class _SimpleDataScreenState extends State<SimpleDataScreen> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.appState.t(widget.titleBn, widget.titleEn))),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: LocalContentService.loadNormalized(widget.fileName),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final items = snapshot.data!.where((e) {
            final hay = '${e['title_en']} ${e['title_bn']} ${e['content']}'.toLowerCase();
            return hay.contains(q.toLowerCase());
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (v) => setState(() => q = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: widget.appState.t('খুঁজুন', 'Search'),
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(
                          unlocked
                              ? widget.appState.t('Unlocked', 'Unlocked')
                              : '$cost ${widget.appState.t('কয়েন', cost == 1 ? 'coin' : 'coins')}',
                        ),
                        trailing: Icon(unlocked ? Icons.lock_open : Icons.lock_outline),
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
