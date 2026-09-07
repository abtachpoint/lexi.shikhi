class CoinPack {
  const CoinPack({
    required this.productId,
    required this.coins,
    required this.priceLabel,
    this.bonus = 0,
    this.isMega = false,
  });

  final String productId;
  final int coins;
  final String priceLabel;
  final int bonus;
  final bool isMega;

  int get totalCoins => coins + bonus;
}

const coinPacks = <CoinPack>[
  CoinPack(productId: 'lexi_coins_50', coins: 50, priceLabel: r'$0.51'),
  CoinPack(productId: 'lexi_coins_110', coins: 110, priceLabel: r'$1.01'),
  CoinPack(productId: 'lexi_coins_240', coins: 240, priceLabel: r'$2.01'),
  CoinPack(productId: 'lexi_coins_390', coins: 390, priceLabel: r'$3.01'),
  CoinPack(productId: 'lexi_coins_560', coins: 560, priceLabel: r'$4.01'),
  CoinPack(
    productId: 'lexi_mega_2000',
    coins: 1600,
    bonus: 400,
    priceLabel: r'$10.01',
    isMega: true,
  ),
];
