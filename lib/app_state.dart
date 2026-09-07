import 'dart:convert';
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
  final List<CoinTransaction> coinHistory = <CoinTransaction>[];

  String? _dailyRewardDate;

  static Future<AppState> create() async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs);
    state._load();
    return state;
  }

  String t(String bn, String en) => isBangla ? bn : en;

  void _load() {
    isBangla = _prefs.getBool('isBangla') ?? true;
    onboardingDone = _prefs.getBool('onboardingDone') ?? false;
    isDarkMode = _prefs.getBool('isDarkMode') ?? false;
    notificationsEnabled = _prefs.getBool('notificationsEnabled') ?? true;
    coins = _prefs.getInt('coins') ?? AppConfig.newUserBonus;
    quizzesCompleted = _prefs.getInt('quizzesCompleted') ?? 0;
    correctAnswers = _prefs.getInt('correctAnswers') ?? 0;
    _dailyRewardDate = _prefs.getString('dailyRewardDate');

    unlockedTopics.addAll(_prefs.getStringList('unlockedTopics') ?? const []);
    savedTopics.addAll(_prefs.getStringList('savedTopics') ?? const []);

    final raw = _prefs.getString('coinHistory');
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        coinHistory.addAll(
          decoded.map((e) => CoinTransaction.fromJson(Map<String, dynamic>.from(e))),
        );
      } catch (_) {}
    }

    if (!_prefs.containsKey('coins')) {
      _addHistory(AppConfig.newUserBonus, 'Welcome bonus', persist: false);
      _persist();
    }
  }

  Future<void> _persist() async {
    await _prefs.setBool('isBangla', isBangla);
    await _prefs.setBool('onboardingDone', onboardingDone);
    await _prefs.setBool('isDarkMode', isDarkMode);
    await _prefs.setBool('notificationsEnabled', notificationsEnabled);
    await _prefs.setInt('coins', coins);
    await _prefs.setInt('quizzesCompleted', quizzesCompleted);
    await _prefs.setInt('correctAnswers', correctAnswers);
    await _prefs.setStringList('unlockedTopics', unlockedTopics.toList());
    await _prefs.setStringList('savedTopics', savedTopics.toList());
    if (_dailyRewardDate != null) {
      await _prefs.setString('dailyRewardDate', _dailyRewardDate!);
    }
    await _prefs.setString(
      'coinHistory',
      jsonEncode(coinHistory.take(100).map((e) => e.toJson()).toList()),
    );
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

  void recordPractice({required bool correct, int reward = 0}) {
    quizzesCompleted += 1;
    if (correct) {
      correctAnswers += 1;
      if (reward > 0) {
        coins += reward;
        _addHistory(reward, 'Practice reward', persist: false);
      }
    }
    _persist();
    notifyListeners();
  }

  bool get canClaimDailyReward {
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return _dailyRewardDate != today;
  }

  bool claimDailyReward() {
    if (!canClaimDailyReward) return false;
    final now = DateTime.now();
    _dailyRewardDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    coins += AppConfig.dailyReward;
    _addHistory(AppConfig.dailyReward, 'Daily reward', persist: false);
    _persist();
    notifyListeners();
    return true;
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

  Future<void> resetLocalProgress() async {
    await _prefs.clear();
    isBangla = true;
    onboardingDone = false;
    isDarkMode = false;
    notificationsEnabled = true;
    coins = AppConfig.newUserBonus;
    quizzesCompleted = 0;
    correctAnswers = 0;
    unlockedTopics.clear();
    savedTopics.clear();
    coinHistory
      ..clear()
      ..add(CoinTransaction(
        amount: AppConfig.newUserBonus,
        reason: 'Welcome bonus',
        timeIso: DateTime.now().toIso8601String(),
      ));
    _dailyRewardDate = null;
    await _persist();
    notifyListeners();
  }
}
