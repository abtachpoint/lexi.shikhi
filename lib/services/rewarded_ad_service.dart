import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import '../app_state.dart';
import '../config/app_config.dart';

class RewardedAdService extends ChangeNotifier {
  RewardedAdService._();

  static final RewardedAdService instance = RewardedAdService._();

  RewardedAd? _ad;
  Completer<bool>? _loadingCompleter;
  String? lastError;
  bool showing = false;
  bool consentChecked = false;
  bool privacyOptionsRequired = false;
  bool _mobileAdsInitialized = false;
  Timer? _retryTimer;

  bool get ready => _ad != null;
  bool get loading => _loadingCompleter != null;

  Future<void> initialize() async {
    await _gatherConsent();
    await _refreshPrivacyOptionsStatus();
    final canRequest = await ConsentInformation.instance.canRequestAds();
    if (canRequest) {
      await _ensureMobileAdsInitialized();
      final loaded = await load();
      if (!loaded) _scheduleRetry();
    }
    notifyListeners();
  }

  Future<void> _gatherConsent() async {
    final completer = Completer<void>();
    final params = ConsentRequestParameters();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
            if (formError != null) lastError = formError.message;
            if (!completer.isCompleted) completer.complete();
          });
        } catch (error) {
          lastError = '$error';
          if (!completer.isCompleted) completer.complete();
        }
      },
      (formError) {
        lastError = formError.message;
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
    consentChecked = true;
  }

  Future<void> _refreshPrivacyOptionsStatus() async {
    try {
      final status = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      privacyOptionsRequired =
          status == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      privacyOptionsRequired = false;
    }
  }

  Future<void> _ensureMobileAdsInitialized() async {
    if (_mobileAdsInitialized) return;
    await MobileAds.instance.initialize();
    _mobileAdsInitialized = true;
  }

  Future<bool> showPrivacyOptions() async {
    await _refreshPrivacyOptionsStatus();
    if (!privacyOptionsRequired) return false;

    final completer = Completer<bool>();
    await ConsentForm.showPrivacyOptionsForm((formError) {
      if (formError != null) {
        lastError = formError.message;
        completer.complete(false);
      } else {
        completer.complete(true);
      }
    });
    final result = await completer.future;
    await _refreshPrivacyOptionsStatus();
    notifyListeners();
    return result;
  }

  Future<bool> load() async {
    if (_ad != null) return true;
    if (_loadingCompleter != null) return _loadingCompleter!.future;

    if (!consentChecked) await _gatherConsent();
    final canRequest = await ConsentInformation.instance.canRequestAds();
    if (!canRequest) return false;
    await _ensureMobileAdsInitialized();

    final completer = Completer<bool>();
    _loadingCompleter = completer;
    lastError = null;
    notifyListeners();

    RewardedAd.load(
      adUnitId: AppConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _retryTimer?.cancel();
          _retryTimer = null;
          _ad = ad;
          _loadingCompleter = null;
          if (!completer.isCompleted) completer.complete(true);
          notifyListeners();
        },
        onAdFailedToLoad: (error) {
          _ad = null;
          lastError = error.message;
          _loadingCompleter = null;
          if (!completer.isCompleted) completer.complete(false);
          notifyListeners();
          _scheduleRetry();
        },
      ),
    );

    return completer.future;
  }

  Future<bool> show(AppState appState) async {
    if (showing || !appState.canWatchRewardedAd) return false;
    final loaded = await load();
    if (!loaded || _ad == null) return false;

    showing = true;
    lastError = null;
    notifyListeners();

    final ad = _ad!;
    _ad = null;
    final result = Completer<bool>();
    var rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        showing = false;
        if (!result.isCompleted) result.complete(rewarded);
        notifyListeners();
        unawaited(load());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        lastError = error.message;
        ad.dispose();
        showing = false;
        if (!result.isCompleted) result.complete(false);
        notifyListeners();
        unawaited(load());
      },
    );

    await ad.show(
      onUserEarnedReward: (_, reward) {
        if (!rewarded) {
          rewarded = appState.grantRewardedAdCoins();
        }
      },
    );

    return result.future;
  }
}
