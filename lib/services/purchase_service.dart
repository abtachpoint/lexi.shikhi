import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../app_state.dart';
import '../config/iap_products.dart';

class PurchaseService extends ChangeNotifier {
  PurchaseService._();

  static final PurchaseService instance = PurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  final Map<String, ProductDetails> _products = <String, ProductDetails>{};
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  AppState? _appState;

  bool initialized = false;
  bool storeAvailable = false;
  bool loadingProducts = false;
  String? lastError;

  Future<void> initialize(AppState appState) async {
    if (initialized) return;
    initialized = true;
    _appState = appState;

    _purchaseSubscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (Object error) {
        lastError = '$error';
        notifyListeners();
      },
    );

    try {
      storeAvailable = await _iap.isAvailable();
      if (storeAvailable) {
        await refreshProducts();
      }
    } catch (error) {
      lastError = '$error';
      storeAvailable = false;
    }
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    if (!storeAvailable) return;
    loadingProducts = true;
    lastError = null;
    notifyListeners();

    try {
      final ids = coinPacks.map((e) => e.productId).toSet();
      final response = await _iap.queryProductDetails(ids);
      _products
        ..clear()
        ..addEntries(response.productDetails.map((p) => MapEntry(p.id, p)));
      if (response.error != null) {
        lastError = response.error!.message;
      }
    } catch (error) {
      lastError = '$error';
    } finally {
      loadingProducts = false;
      notifyListeners();
    }
  }

  ProductDetails? product(String productId) => _products[productId];

  String? localizedPrice(String productId) => _products[productId]?.price;

  Future<bool> buy(CoinPack pack) async {
    if (!storeAvailable) return false;
    var details = _products[pack.productId];
    if (details == null) {
      await refreshProducts();
      details = _products[pack.productId];
    }
    if (details == null) return false;

    final purchaseParam = PurchaseParam(productDetails: details);
    return _iap.buyConsumable(
      purchaseParam: purchaseParam,
      autoConsume: true,
    );
  }

  Future<void> restorePurchases() async {
    if (!storeAvailable) return;
    await _iap.restorePurchases();
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchases,
  ) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.error) {
        lastError = purchase.error?.message ?? 'Purchase failed';
      }

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        final pack = coinPackByProductId(purchase.productID);
        if (pack != null) {
          final purchaseKey = purchase.purchaseID ??
              '${purchase.productID}:${purchase.transactionDate ?? ''}';
          _appState?.deliverPurchasedCoins(
            purchaseKey: purchaseKey,
            amount: pack.totalCoins,
            productId: pack.productId,
          );
        }
      }

      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (error) {
          lastError = '$error';
        }
      }
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
