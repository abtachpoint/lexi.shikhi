import 'package:flutter/material.dart';
import '../app_state.dart';
import '../config/app_config.dart';
import '../config/iap_products.dart';
import '../services/purchase_service.dart';
import '../services/rewarded_ad_service.dart';
import 'coin_history_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key, required this.appState});
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final purchaseService = PurchaseService.instance;
    final adService = RewardedAdService.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(appState.t('কয়েন', 'Coins')),
        actions: [
          IconButton(
            tooltip: appState.t('হিস্টোরি', 'History'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CoinHistoryScreen(appState: appState),
              ),
            ),
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([appState, purchaseService, adService]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const Icon(Icons.monetization_on_rounded, size: 46),
                      const SizedBox(height: 8),
                      Text(
                        '${appState.coins}',
                        style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(appState.t('বর্তমান কয়েন', 'Current coins')),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                appState.t('কয়েন অর্জন করুন', 'Earn Coins'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 9),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.card_giftcard_rounded),
                  ),
                  title: Text(
                    appState.t('Daily Reward', 'Daily Reward'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '+${AppConfig.dailyReward} ${appState.t('কয়েন', 'coins')}',
                  ),
                  trailing: FilledButton(
                    onPressed: appState.canClaimDailyReward
                        ? () {
                            appState.claimDailyReward();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  appState.t(
                                    'Reward যোগ হয়েছে।',
                                    'Reward added.',
                                  ),
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      appState.canClaimDailyReward
                          ? appState.t('নিন', 'Claim')
                          : appState.t('নেওয়া হয়েছে', 'Claimed'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.play_circle_outline_rounded),
                  ),
                  title: Text(
                    appState.t('Rewarded Ad দেখুন', 'Watch Rewarded Ad'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    appState.t(
                      '+${AppConfig.rewardedAdCoins} কয়েন • আজ ${appState.rewardedAdsRemainingToday}টি বাকি',
                      '+${AppConfig.rewardedAdCoins} coins • ${appState.rewardedAdsRemainingToday} left today',
                    ),
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: appState.canWatchRewardedAd && !adService.showing
                        ? () => _showRewardedAd(context)
                        : null,
                    child: adService.loading || adService.showing
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(appState.t('Ad দেখুন', 'Watch')),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                appState.t('কয়েন কিনুন', 'Buy Coins'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                appState.t(
                  'দাম Google Play থেকে আপনার দেশের currency অনুযায়ী দেখাবে।',
                  'Prices are loaded from Google Play in your local currency.',
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 9),
              ...coinPacks.map(
                (pack) {
                  final price = purchaseService.localizedPrice(pack.productId);
                  final productReady = purchaseService.product(pack.productId) != null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            pack.isMega
                                ? Icons.workspace_premium_rounded
                                : Icons.monetization_on_outlined,
                          ),
                        ),
                        title: Text(
                          pack.isMega
                              ? '${pack.totalCoins} Coins • Mega Pack'
                              : '${pack.totalCoins} Coins',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: pack.bonus > 0
                            ? Text('+${pack.bonus} Bonus Coins')
                            : null,
                        trailing: Text(
                          price ?? '—',
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        onTap: productReady
                            ? () => _buyPack(context, pack)
                            : () => _productUnavailable(context),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showRewardedAd(BuildContext context) async {
    final success = await RewardedAdService.instance.show(appState);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.t(
              '+${AppConfig.rewardedAdCoins} কয়েন যোগ হয়েছে।',
              '+${AppConfig.rewardedAdCoins} coins added.',
            ),
          ),
        ),
      );
      return;
    }
    final error = RewardedAdService.instance.lastError;
    if (error != null || appState.canWatchRewardedAd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.t(
              'Ad এখন load হয়নি। একটু পরে আবার চেষ্টা করুন।',
              'The ad is not ready yet. Please try again shortly.',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _buyPack(BuildContext context, CoinPack pack) async {
    final started = await PurchaseService.instance.buy(pack);
    if (!started && context.mounted) {
      _productUnavailable(context);
    }
  }

  void _productUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appState.t(
            'এই coin pack এখন Google Play থেকে পাওয়া যাচ্ছে না।',
            'This coin pack is not available from Google Play right now.',
          ),
        ),
      ),
    );
  }
}
