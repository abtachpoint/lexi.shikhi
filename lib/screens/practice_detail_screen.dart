import 'package:flutter/material.dart';
import '../app_state.dart';

class PracticeDetailScreen extends StatefulWidget {
  const PracticeDetailScreen({
    super.key,
    required this.appState,
    required this.item,
  });

  final AppState appState;
  final Map<String, dynamic> item;

  @override
  State<PracticeDetailScreen> createState() => _PracticeDetailScreenState();
}

class _PracticeDetailScreenState extends State<PracticeDetailScreen> {
  int? selectedIndex;
  bool checked = false;
  bool revealed = false;
  bool rewardEarnedThisAttempt = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final type = '${item['type']}';
    final reward = (item['reward_coin'] as num?)?.toInt() ?? 0;
    final id = '${item['id']}';
    final alreadyCompleted = widget.appState.isPracticeCompleted(id);

    return Scaffold(
      appBar: AppBar(title: Text('${item['title']}')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.appState.t('প্রশ্ন', 'Question'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item['question']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (!alreadyCompleted && reward > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                widget.appState.t(
                  'প্রথমবার সঠিকভাবে সম্পন্ন করলে +$reward কয়েন পাবেন।',
                  'Complete it correctly for the first time to earn +$reward coin.',
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          if (type == 'mcq')
            ..._buildMcq(item, reward)
          else
            ..._buildTranslation(item, reward),
        ],
      ),
    );
  }

  List<Widget> _buildMcq(Map<String, dynamic> item, int reward) {
    final options = (item['options'] as List<dynamic>).map((e) => '$e').toList();
    final answerIndex = (item['answer_index'] as num?)?.toInt() ?? 0;
    return [
      ...List.generate(options.length, (i) {
        final selected = selectedIndex == i;
        Color? tileColor;
        if (checked) {
          if (i == answerIndex) tileColor = Colors.green.withOpacity(.12);
          if (selected && i != answerIndex) {
            tileColor = Colors.red.withOpacity(.10);
          }
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Card(
            color: tileColor,
            child: RadioListTile<int>(
              value: i,
              groupValue: selectedIndex,
              onChanged: checked ? null : (v) => setState(() => selectedIndex = v),
              title: Text(options[i]),
            ),
          ),
        );
      }),
      const SizedBox(height: 8),
      FilledButton(
        onPressed: selectedIndex == null || checked
            ? null
            : () {
                final correct = selectedIndex == answerIndex;
                final wasCompleted = widget.appState.isPracticeCompleted('${item['id']}');
                widget.appState.recordPractice(
                  practiceId: '${item['id']}',
                  correct: correct,
                  reward: correct ? reward : 0,
                );
                setState(() {
                  checked = true;
                  rewardEarnedThisAttempt = correct && !wasCompleted && reward > 0;
                });
              },
        child: Text(widget.appState.t('উত্তর যাচাই করুন', 'Check Answer')),
      ),
      if (checked) ...[
        const SizedBox(height: 14),
        _resultCard(
          selectedIndex == answerIndex,
          '${item['explanation'] ?? ''}',
          reward,
        ),
      ],
    ];
  }

  List<Widget> _buildTranslation(Map<String, dynamic> item, int reward) {
    return [
      Text(
        widget.appState.t(
          'আগে নিজে English-এ translate করার চেষ্টা করুন।',
          'Try translating it into English before revealing the answer.',
        ),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 16),
      FilledButton.tonalIcon(
        onPressed: revealed
            ? null
            : () {
                final wasCompleted = widget.appState.isPracticeCompleted('${item['id']}');
                widget.appState.recordPractice(
                  practiceId: '${item['id']}',
                  correct: true,
                  reward: reward,
                );
                setState(() {
                  revealed = true;
                  rewardEarnedThisAttempt = !wasCompleted && reward > 0;
                });
              },
        icon: const Icon(Icons.visibility_outlined),
        label: Text(widget.appState.t('Model Answer দেখুন', 'Show Model Answer')),
      ),
      if (revealed) ...[
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: SelectableText(
              '${item['answer']}',
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    ];
  }

  Widget _resultCard(
    bool correct,
    String explanation,
    int reward,
  ) {
    final rewarded = correct && rewardEarnedThisAttempt;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              correct
                  ? widget.appState.t('সঠিক উত্তর!', 'Correct!')
                  : widget.appState.t('উত্তরটি সঠিক হয়নি', 'Not quite correct'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: correct ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
            if (rewarded) ...[
              const SizedBox(height: 6),
              Text(
                widget.appState.t(
                  'প্রথম completion reward যোগ হয়েছে।',
                  'First-completion reward has been added.',
                ),
              ),
            ],
            if (explanation.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(explanation, style: const TextStyle(height: 1.45)),
            ],
          ],
        ),
      ),
    );
  }
}
