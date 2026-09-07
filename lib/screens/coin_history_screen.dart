import 'package:flutter/material.dart';
import '../app_state.dart';

class CoinHistoryScreen extends StatelessWidget {
  const CoinHistoryScreen({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appState.t('কয়েন হিস্ট্রি', 'Coin History'))),
      body: appState.coinHistory.isEmpty
          ? Center(child: Text(appState.t('এখনও কোনো transaction নেই।', 'No transactions yet.')))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: appState.coinHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final tx = appState.coinHistory[i];
                final positive = tx.amount > 0;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(positive ? Icons.add_rounded : Icons.remove_rounded),
                    ),
                    title: Text(tx.reason, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(_formatTime(tx.timeIso)),
                    trailing: Text(
                      '${positive ? '+' : ''}${tx.amount}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: positive ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatTime(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
