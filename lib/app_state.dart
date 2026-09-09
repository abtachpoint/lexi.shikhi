import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/app_config.dart';

class CoinTransaction {
  const CoinTransaction({
    required this.amount,
    required this.reason,
    required this.timeIso,
  });

  final int amount;
  final String reason;
  final String timeIso;

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'reason': reason,
        'timeIso': timeIso,
      };

  static CoinTransaction fromJson(Map<String, dynamic> json) => CoinTransaction(
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        reason: '${json['reason'] ?? ''}',
        timeIso: '${json['timeIso'] ?? ''}',
      );
}

class AppState extends ChangeNotifier {
  AppState(this._prefs);

  final SharedPreferences _prefs;

  bool isBangla = true;
  bool onboardingDone = false;
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  int coins = AppConfig.newUserBonus;
  int quizzesCompleted = 0;
  int correctAnswers = 0;

  final Set<String> unlockedTopics = <String>{};
  final Set<String> savedTopics = <String>{};
  final Set<String> unlockedPracticePacks = <String>{};
  final Set<String> completedPracticeIds = <String>{};
  final Set<String> processedPurchaseIds = <String>{};
  final List<CoinTransaction> coinHistory = <CoinTransaction>[];

  String? _dailyRewardDate;
  String? _rewardedAdDate;
  int rewardedAdsWatchedToday = 0;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _cloudSubscription;
  Timer? _cloudDebounce;
  bool _applyingCloud = false;
  bool cloudSyncReady = false;
  String? cloudSyncError;
  User? currentUser;

  static Future<AppState> create() async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs);
    state._load();
    return state;
  }

  String t(String bn, String en) => isBangla ? bn : en;
  bool get isSignedIn => currentUser != null;

  void _load() {
    isBangla = _prefs.getBool('isBangla') ?? true;
    onboardingDone = _prefs.getBool('onboardingDone') ?? false;
    isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
    coins = _prefs.getInt('coins') ?? AppConfig.newUserBonus;
    quizzesCompleted = _prefs.getInt('quizzesCompleted') ?? 0;
    correctAnswers = _prefs.getInt('correctAnswers') ?? 0;
    _dailyRewardDate = _prefs.getString('dailyRewardDate');
    _rewardedAdDate = _prefs.getString('rewardedAdDate');
    rewardedAdsWatchedToday = _prefs.getInt('rewardedAdsWatchedToday') ?? 0;

    unlockedTopics.addAll(
      _prefs.getStringList('unlockedTopics') ?? const <String>[],
    );
    savedTopics.addAll(
      _prefs.getStringList('savedTopics') ?? const <String>[],
    );
    unlockedPracticePacks.addAll(
      _prefs.getStringList('unlockedPracticePacks') ?? const <String>[],
    );
    completedPracticeIds.addAll(
      _prefs.getStringList('completedPracticeIds') ?? const <String>[],
    );
    processedPurchaseIds.addAll(
      _prefs.getStringList('processedPurchaseIds') ?? const <String>[],
    );

    final raw = _prefs.getString('coinHistory');
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        coinHistory.addAll(
          decoded.map(
            (e) => CoinTransaction.fromJson(Map<String, dynamic>.from(e)),
          ),
        );
      } catch (_) {}
    }

    _refreshRewardedAdDay();

    if (!_prefs.containsKey('coins')) {
      _addHistory(AppConfig.newUserBonus, 'Welcome bonus', persist: false);
      _persist(syncCloud: false);
    }
  }

  Future<void> startCloudSync() async {
    await _authSubscription?.cancel();
    await _handleAuthChanged(FirebaseAuth.instance.currentUser);
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (user) {
        final sameUser = user?.uid == currentUser?.uid;
        if (!sameUser) unawaited(_handleAuthChanged(user));
      },
      onError: (Object error) {
        cloudSyncError = '$error';
        cloudSyncReady = false;
        notifyListeners();
      },
    );
  }

  Future<void> _handleAuthChanged(User? user) async {
    final previousUser = currentUser;
    if (previousUser != null &&
        (user == null || previousUser.uid != user.uid)) {
      await _resetLearningDataForAccountSwitch();
    }
    currentUser = user;
    cloudSyncError = null;
    cloudSyncReady = false;
    await _cloudSubscription?.cancel();
    _cloudSubscription = null;

    if (user == null) {
      notifyListeners();
      return;
    }

    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    try {
      final snapshot = await ref.get();
      if (snapshot.exists && snapshot.data() != null) {
        await _applyCloud(snapshot.data()!);
        await _writeCloudNow();
      } else {
        await _writeCloudNow();
      }
      cloudSyncReady = true;
      notifyListeners();

    } catch (error) {
      cloudSyncError = '$error';
      cloudSyncReady = false;
      notifyListeners();
    }
  }

  Future<void> _resetLearningDataForAccountSwitch() async {
    coins = AppConfig.newUserBonus;
    quizzesCompleted = 0;
    correctAnswers = 0;
    unlockedTopics.clear();
    savedTopics.clear();
    unlockedPracticePacks.clear();
    completedPracticeIds.clear();
    processedPurchaseIds.clear();
    coinHistory
      ..clear()
      ..add(
        CoinTransaction(
          amount: AppConfig.newUserBonus,
          reason: 'Welcome bonus',
          timeIso: DateTime.now().toIso8601String(),
        ),
      );
    _dailyRewardDate = null;
    _rewardedAdDate = null;
    rewardedAdsWatchedToday = 0;
    await _prefs.remove('dailyRewardDate');
    await _prefs.remove('rewardedAdDate');
    await _persist(syncCloud: false);
  }

  Future<void> _applyCloud(Map<String, dynamic> data) async {
    if (_applyingCloud) return;
    _applyingCloud = true;
    try {
      coins = (data['coins'] as num?)?.toInt() ?? AppConfig.newUserBonus;

      unlockedTopics
        ..clear()
        ..addAll(_stringList(data['unlockedTopics']));
      savedTopics
        ..clear()
        ..addAll(_stringList(data['savedTopics']));
      unlockedPracticePacks
        ..clear()
        ..addAll(_stringList(data['unlockedPracticePacks']));
      completedPracticeIds
        ..clear()
        ..addAll(_stringList(data['completedPracticeIds']));
      processedPurchaseIds
        ..clear()
        ..addAll(_stringList(data['processedPurchaseIds']));

      quizzesCompleted = (data['quizzesCompleted'] as num?)?.toInt() ?? 0;
      correctAnswers = (data['correctAnswers'] as num?)?.toInt() ?? 0;
      _dailyRewardDate = data['dailyRewardDate'] as String?;
      _rewardedAdDate = data['rewardedAdDate'] as String?;
      rewardedAdsWatchedToday =
          (data['rewardedAdsWatchedToday'] as num?)?.toInt() ?? 0;

      final cloudHistory = data['coinHistory'];
      coinHistory.clear();
      if (cloudHistory is List) {
        for (final item in cloudHistory.take(100)) {
          if (item is Map) {
            coinHistory.add(
              CoinTransaction.fromJson(Map<String, dynamic>.from(item)),
            );
          }
        }
      }

      await _persist(syncCloud: false);
      notifyListeners();
    } finally {
      _applyingCloud = false;
    }
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) return const <String>[];
    return value.map((e) => '$e').where((e) => e.isNotEmpty).toList();
  }

  Map<String, dynamic> _cloudPayload(User user) => {
        'schemaVersion': 1,
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'coins': coins,
        'unlockedTopics': unlockedTopics.toList(),
        'savedTopics': savedTopics.toList(),
        'unlockedPracticePacks': unlockedPracticePacks.toList(),
        'completedPracticeIds': completedPracticeIds.toList(),
        'processedPurchaseIds': processedPurchaseIds.toList(),
        'quizzesCompleted': quizzesCompleted,
        'correctAnswers': correctAnswers,
        'dailyRewardDate': _dailyRewardDate,
        'rewardedAdDate': _rewardedAdDate,
        'rewardedAdsWatchedToday': rewardedAdsWatchedToday,
        'coinHistory': coinHistory.take(100).map((e) => e.toJson()).toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  void _scheduleCloudSync() {
    if (_applyingCloud || FirebaseAuth.instance.currentUser == null) return;
    _cloudDebounce?.cancel();
    _cloudDebounce = Timer(const Duration(milliseconds: 450), () {
      _writeCloudNow();
    });
  }

  Future<void> _writeCloudNow() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _applyingCloud) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(_cloudPayload(user), SetOptions(merge: true));
      cloudSyncReady = true;
      cloudSyncError = null;
    } catch (error) {
      cloudSyncError = '$error';
    }
  }

  Future<void> _persist({bool syncCloud = true}) async {
    await _prefs.setBool('isBangla', isBangla);
    await _prefs.setBool('onboardingDone', onboardingDone);
    await _prefs.setBool('isDarkMode', isDarkMode);
    await _prefs.setBool('notificationsEnabled', notificationsEnabled);
    await _prefs.setInt('coins', coins);
    await _prefs.setInt('quizzesCompleted', quizzesCompleted);
    await _prefs.setInt('correctAnswers', correctAnswers);
    await _prefs.setInt('rewardedAdsWatchedToday', rewardedAdsWatchedToday);
    await _prefs.setStringList('unlockedTopics', unlockedTopics.toList());
    await _prefs.setStringList('savedTopics', savedTopics.toList());
    await _prefs.setStringList(
      'unlockedPracticePacks',
      unlockedPracticePacks.toList(),
    );
    await _prefs.setStringList(
      'completedPracticeIds',
      completedPracticeIds.toList(),
    );
    await _prefs.setStringList(
      'processedPurchaseIds',
      processedPurchaseIds.toList(),
    );
    if (_dailyRewardDate != null) {
      await _prefs.setString('dailyRewardDate', _dailyRewardDate!);
    }
    if (_rewardedAdDate != null) {
      await _prefs.setString('rewardedAdDate', _rewardedAdDate!);
    }
    await _prefs.setString(
      'coinHistory',
      jsonEncode(coinHistory.take(100).map((e) => e.toJson()).toList()),
    );
    if (syncCloud) _scheduleCloudSync();
  }

  void setLanguage(bool bangla) {
    isBangla = bangla;
    _prefs.setBool('isBangla', bangla);
    notifyListeners();
  }

  void toggleLanguage() => setLanguage(!isBangla);

  void setDarkMode(bool value) {
    isDarkMode = value;
    _prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  void setNotifications(bool value) {
    notificationsEnabled = value;
    _prefs.setBool('notificationsEnabled', value);
    notifyListeners();
  }

  void completeOnboarding() {
    onboardingDone = true;
    _prefs.setBool('onboardingDone', true);
    notifyListeners();
  }

  bool isUnlocked(String id) => unlockedTopics.contains(id);
  bool isSaved(String id) => savedTopics.contains(id);
  bool isPracticePackUnlocked(String id) => unlockedPracticePacks.contains(id);
  bool isPracticeCompleted(String id) => completedPracticeIds.contains(id);

  bool unlock(String id, int cost, {String? title}) {
    if (isUnlocked(id)) return true;
    if (coins < cost) return false;
    coins -= cost;
    unlockedTopics.add(id);
    _addHistory(-cost, 'Unlocked: ${title ?? id}', persist: false);
    _persist();
    notifyListeners();
    return true;
  }

  bool unlockPracticePack(String id, int cost, {String? title}) {
    if (isPracticePackUnlocked(id)) return true;
    if (coins < cost) return false;
    coins -= cost;
    unlockedPracticePacks.add(id);
    _addHistory(-cost, 'Practice pack: ${title ?? id}', persist: false);
    _persist();
    notifyListeners();
    return true;
  }

  bool spendCoins(int amount, String reason) {
    if (amount <= 0) return true;
    if (coins < amount) return false;
    coins -= amount;
    _addHistory(-amount, reason, persist: false);
    _persist();
    notifyListeners();
    return true;
  }

  void toggleSaved(String id) {
    if (savedTopics.contains(id)) {
      savedTopics.remove(id);
    } else {
      savedTopics.add(id);
    }
    _persist();
    notifyListeners();
  }

  void addCoins(int amount, String reason) {
    if (amount <= 0) return;
    coins += amount;
    _addHistory(amount, reason, persist: false);
    _persist();
    notifyListeners();
  }

  bool deliverPurchasedCoins({
    required String purchaseKey,
    required int amount,
    required String productId,
  }) {
    if (purchaseKey.trim().isEmpty || processedPurchaseIds.contains(purchaseKey)) {
      return false;
    }
    processedPurchaseIds.add(purchaseKey);
    coins += amount;
    _addHistory(amount, 'Coin purchase: $productId', persist: false);
    _persist();
    notifyListeners();
    return true;
  }

  void recordPractice({
    required String practiceId,
    required bool correct,
    int reward = 0,
  }) {
    quizzesCompleted += 1;
    if (correct) {
      correctAnswers += 1;
      final firstCompletion = completedPracticeIds.add(practiceId);
      if (firstCompletion && reward > 0) {
        coins += reward;
        _addHistory(reward, 'Practice reward', persist: false);
      }
    }
    _persist();
    notifyListeners();
  }

  bool get canClaimDailyReward {
    final today = _todayKey();
    return _dailyRewardDate != today;
  }

  bool claimDailyReward() {
    if (!canClaimDailyReward) return false;
    _dailyRewardDate = _todayKey();
    coins += AppConfig.dailyReward;
    _addHistory(AppConfig.dailyReward, 'Daily reward', persist: false);
    _persist();
    notifyListeners();
    return true;
  }

  int get rewardedAdsRemainingToday {
    _refreshRewardedAdDay();
    final remaining = AppConfig.rewardedAdDailyLimit - rewardedAdsWatchedToday;
    return remaining < 0 ? 0 : remaining;
  }

  bool get canWatchRewardedAd => rewardedAdsRemainingToday > 0;

  bool grantRewardedAdCoins() {
    _refreshRewardedAdDay();
    if (!canWatchRewardedAd) return false;
    rewardedAdsWatchedToday += 1;
    coins += AppConfig.rewardedAdCoins;
    _addHistory(AppConfig.rewardedAdCoins, 'Rewarded ad', persist: false);
    _persist();
    notifyListeners();
    return true;
  }

  void _refreshRewardedAdDay() {
    final today = _todayKey();
    if (_rewardedAdDate != today) {
      _rewardedAdDate = today;
      rewardedAdsWatchedToday = 0;
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _addHistory(int amount, String reason, {bool persist = true}) {
    coinHistory.insert(
      0,
      CoinTransaction(
        amount: amount,
        reason: reason,
        timeIso: DateTime.now().toIso8601String(),
      ),
    );
    if (coinHistory.length > 100) {
      coinHistory.removeRange(100, coinHistory.length);
    }
    if (persist) _persist();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _cloudSubscription?.cancel();
    _cloudDebounce?.cancel();
    super.dispose();
  }
}
