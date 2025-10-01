import 'package:flutter/foundation.dart';
import 'wallet_service.dart';

/// Service for managing waste coin rewards and transactions
class WasteCoinService {
  static final WasteCoinService _instance = WasteCoinService._internal();
  static WasteCoinService get instance => _instance;
  WasteCoinService._internal();

  final WalletService _walletService = WalletService.instance;
  
  // Reward amounts for different waste classification actions
  static const double correctClassificationReward = 0.01; // 0.01 SOL for correct classification
  static const double perfectSortingReward = 0.05; // 0.05 SOL for perfect sorting
  static const double dailyGoalReward = 0.1; // 0.1 SOL for completing daily goals
  static const double weeklyStreakReward = 0.5; // 0.5 SOL for weekly streaks

  /// Reward user for correct waste classification
  Future<bool> rewardForCorrectClassification({
    required String wasteType,
    required bool isCorrect,
    double? customAmount,
  }) async {
    if (!isCorrect) return false;

    try {
      final amount = customAmount ?? correctClassificationReward;
      
      if (kDebugMode) {
        debugPrint('🏆 Rewarding $amount SOL for correctly classifying $wasteType');
      }

      // For now, we'll simulate the reward with an airdrop
      // In production, this would come from a reward pool
      final success = await _simulateWasteTokenReward(amount, 'Correct $wasteType classification');
      
      if (success) {
        _showRewardNotification('Correct Classification!', '$amount SOL earned for properly sorting $wasteType');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to reward user: $e');
      }
      return false;
    }
  }

  /// Reward user for perfect sorting session
  Future<bool> rewardForPerfectSorting({
    required int itemsSorted,
    required int correctCount,
  }) async {
    if (correctCount != itemsSorted || itemsSorted < 5) {
      return false; // Need at least 5 items and perfect accuracy
    }

    try {
      final amount = perfectSortingReward * (itemsSorted / 5).ceil(); // Bonus for more items
      
      if (kDebugMode) {
        debugPrint('🏆 Perfect sorting reward: $amount SOL for $correctCount/$itemsSorted items');
      }

      final success = await _simulateWasteTokenReward(amount, 'Perfect sorting session');
      
      if (success) {
        _showRewardNotification('Perfect Sorting!', '$amount SOL earned for ${correctCount}/${itemsSorted} correct classifications');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to reward perfect sorting: $e');
      }
      return false;
    }
  }

  /// Reward user for completing daily goals
  Future<bool> rewardForDailyGoal() async {
    try {
      if (kDebugMode) {
        debugPrint('🏆 Daily goal reward: $dailyGoalReward SOL');
      }

      final success = await _simulateWasteTokenReward(dailyGoalReward, 'Daily goal completed');
      
      if (success) {
        _showRewardNotification('Daily Goal Complete!', '$dailyGoalReward SOL earned for completing today\'s waste sorting goal');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to reward daily goal: $e');
      }
      return false;
    }
  }

  /// Reward user for weekly streak
  Future<bool> rewardForWeeklyStreak(int streakDays) async {
    if (streakDays < 7) return false;

    try {
      final multiplier = (streakDays / 7).floor();
      final amount = weeklyStreakReward * multiplier;
      
      if (kDebugMode) {
        debugPrint('🏆 Weekly streak reward: $amount SOL for $streakDays day streak');
      }

      final success = await _simulateWasteTokenReward(amount, '$streakDays day streak');
      
      if (success) {
        _showRewardNotification('Streak Master!', '$amount SOL earned for your $streakDays day sorting streak');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to reward weekly streak: $e');
      }
      return false;
    }
  }

  /// Calculate potential reward based on classification accuracy
  double calculateSessionReward(List<bool> classifications) {
    if (classifications.isEmpty) return 0.0;
    
    final correctCount = classifications.where((c) => c).length;
    final totalCount = classifications.length;
    final accuracy = correctCount / totalCount;
    
    // Base reward for correct classifications
    double reward = correctCount * correctClassificationReward;
    
    // Bonus for perfect accuracy
    if (accuracy == 1.0 && totalCount >= 5) {
      reward += perfectSortingReward;
    }
    
    // Accuracy bonus
    if (accuracy >= 0.8) {
      reward *= 1.2; // 20% bonus for >80% accuracy
    }
    
    return reward;
  }

  /// Get user's waste coin statistics
  Map<String, dynamic> getUserStats() {
    // This would typically come from a database
    // For now, return mock data
    return {
      'totalEarned': 2.5,
      'totalClassifications': 150,
      'correctClassifications': 142,
      'accuracy': 0.947,
      'currentStreak': 5,
      'longestStreak': 12,
      'level': 3,
      'nextLevelProgress': 0.7,
    };
  }

  /// Private method to simulate waste token reward
  /// In production, this would interact with a Solana program/smart contract
  Future<bool> _simulateWasteTokenReward(double amount, String reason) async {
    try {
      if (!_walletService.state.isWalletReady) {
        if (kDebugMode) {
          debugPrint('⚠️ Wallet not ready, reward will be credited when user connects wallet');
        }
        // Store pending rewards for later
        await _storePendingReward(amount, reason);
        return true;
      }

      // For demonstration, we'll use SOL airdrop to simulate waste token rewards
      // In production, this would mint/transfer actual waste tokens
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      if (kDebugMode) {
        debugPrint('✅ Waste token reward simulated: $amount SOL for $reason');
      }
      
      // Refresh wallet balance to show the "reward"
      _walletService.refreshBalance();
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Failed to process waste token reward: $e');
      }
      return false;
    }
  }

  /// Store pending rewards for users who haven't connected their wallet yet
  Future<void> _storePendingReward(double amount, String reason) async {
    // This would store in secure local storage or backend
    if (kDebugMode) {
      debugPrint('💾 Stored pending reward: $amount SOL for $reason');
    }
  }

  /// Show reward notification to user
  void _showRewardNotification(String title, String message) {
    // This would integrate with your app's notification system
    if (kDebugMode) {
      debugPrint('🔔 Reward Notification: $title - $message');
    }
  }

  /// Get leaderboard data
  List<Map<String, dynamic>> getLeaderboard() {
    // Mock leaderboard data
    return [
      {'name': 'EcoMaster', 'earned': 15.7, 'classifications': 890},
      {'name': 'GreenGuru', 'earned': 12.3, 'classifications': 734},
      {'name': 'WasteWise', 'earned': 10.8, 'classifications': 612},
      {'name': 'You', 'earned': 2.5, 'classifications': 150, 'isCurrentUser': true},
      {'name': 'RecyclePro', 'earned': 8.4, 'classifications': 456},
    ];
  }

  /// Check and claim pending rewards when wallet connects
  Future<void> claimPendingRewards() async {
    if (!_walletService.state.isWalletReady) return;
    
    // This would fetch and claim any pending rewards
    if (kDebugMode) {
      debugPrint('🎁 Claiming pending rewards...');
    }
    
    // Simulate claiming pending rewards
    await Future.delayed(const Duration(seconds: 2));
    _showRewardNotification('Welcome Back!', 'Pending rewards have been credited to your wallet');
  }
}