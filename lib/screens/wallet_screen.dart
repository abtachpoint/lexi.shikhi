import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config/app_config.dart';
import '../config/iap_products.dart';
import 'coin_history_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appState.t('কয়েন', 'Coins')),
        actions: [
          IconButton(
            tooltip: appState.t('History', 'History'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CoinHistoryScreen(appState: appState)),
            ),
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  const Icon(Icons.monetization_on_rounded, size: 46),
                  const SizedBox(height: 8),
                  Text('${appState.coins}', style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900)),
                  Text(appState.t('বর্তমান কয়েন', 'Current coins')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(appState.t('কয়েন অর্জন করুন', 'Earn Coins'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 9),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.card_giftcard_rounded)),
              title: Text(appState.t('Daily Reward', 'Daily Reward'), style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('+${AppConfig.dailyReward} ${appState.t('কয়েন', 'coins')}'),
              trailing: FilledButton(
                onPressed: appState.canClaimDailyReward
                    ? () {
                        appState.claimDailyReward();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(appState.t('Reward যোগ হয়েছে।', 'Reward added.'))),
                        );
                      }
                    : null,
                child: Text(appState.canClaimDailyReward ? appState.t('নিন', 'Claim') : appState.t('নেওয়া হয়েছে', 'Claimed')),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.play_circle_outline_rounded)),
              title: Text(appState.t('Rewarded Ad দেখুন', 'Watch Rewarded Ad'), style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(appState.t(
                '+${AppConfig.rewardedAdCoins} কয়েন • কোনো forced ad থাকবে না',
                '+${AppConfig.rewardedAdCoins} coins • no forced ads',
              )),
              trailing: FilledButton.tonal(
                onPressed: AppConfig.rewardedAdsConnected
                    ? () {}
                    : () => _pending(context, appState, 'AdMob Rewarded Ad'),
                child: Text(appState.t('Ad দেখুন', 'Watch')),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(appState.t('কয়েন কিনুন', 'Buy Coins'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 9),
          ...coinPacks.map(
            (pack) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(pack.isMega ? Icons.workspace_premium_rounded : Icons.monetization_on_outlined),
                  ),
                  title: Text(
                    pack.isMega
                        ? '${pack.totalCoins} Coins • Mega Pack'
                        : '${pack.totalCoins} Coins',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: pack.bonus > 0 ? Text('+${pack.bonus} Bonus Coins') : null,
                  trailing: Text(pack.priceLabel, style: const TextStyle(fontWeight: FontWeight.w900)),
                  onTap: () => AppConfig.iapConnected
                      ? null
                      : _pending(context, appState, 'Google Play IAP'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pending(BuildContext context, AppState state, String service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.t(
            '$service external setup-এর সময় connect হবে।',
            '$service will be connected during the external-service setup.',
          ),
        ),
      ),
    );
  }
}
