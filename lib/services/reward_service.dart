import 'package:shared_preferences/shared_preferences.dart';

class RewardService {
  RewardService._privateConstructor();
  static final RewardService instance = RewardService._privateConstructor();

  Future<Map<String, dynamic>> getWallet() async {
    // Placeholder: fetch wallet data from backend or local storage
    return {
      'balance': 1000.0,
      'transactions': [
        {'description': 'Catch Reward', 'date': '2025-09-01', 'type': 'Reward', 'amount': 100},
        {'description': 'Store Purchase', 'date': '2025-09-01', 'type': 'Purchase', 'amount': -50},
      ],
      'badges': ['First Catch', 'Streak Master'],
    };
  }

  double calculateReward({required int runnerLevel, required int streak, required bool referral, required bool cityBonus}) {
    double base = 100.0 * runnerLevel;
    if (streak > 0) base *= (1 + streak * 0.05);
    if (referral) base += 50.0;
    if (cityBonus) base *= 1.2;
    return base;
  }

  Future<void> awardBadge(String badge) async {
    // Placeholder: update backend and local storage
  }

  Future<void> updateStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak', streak);
  }

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('streak') ?? 0;
  }

  Future<void> addTransaction(Map<String, dynamic> tx) async {
    // Placeholder: update backend and local storage
  }

  Future<void> purchaseItem(String item) async {
    // Placeholder: update inventory and deduct balance
  }

  Future<List<String>> getInventory() async {
    // Placeholder: fetch inventory from backend/local
    return ['Runner Detector'];
  }

  Future<Map<String, dynamic>> getRewardAnalytics() async {
    // Placeholder: fetch analytics data
    return {'totalRewards': 5000, 'topBadge': 'Streak Master'};
  }
}
