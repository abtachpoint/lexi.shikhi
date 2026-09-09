class CoinPack {
  const CoinPack({
    required this.productId,
    required this.coins,
    this.bonus = 0,
    this.isMega = false,
  });

  final String productId;
  final int coins;
  final int bonus;
  final bool isMega;

  int get totalCoins => coins + bonus;
}

// Create these exact IDs in Google Play Console after the first AAB upload.
// Prices are NOT hardcoded; the app reads localized prices from Google Play.
const coinPacks = <CoinPack>[
  CoinPack(productId: 'coins_50', coins: 50),
  CoinPack(productId: 'coins_110', coins: 110),
  CoinPack(productId: 'coins_240', coins: 240),
  CoinPack(productId: 'coins_390', coins: 390),
  CoinPack(productId: 'coins_560', coins: 560),
  CoinPack(
    productId: 'coins_2000',
    coins: 1600,
    bonus: 400,
    isMega: true,
  ),
];

CoinPack? coinPackByProductId(String productId) {
  for (final pack in coinPacks) {
    if (pack.productId == productId) return pack;
  }
  return null;
}
