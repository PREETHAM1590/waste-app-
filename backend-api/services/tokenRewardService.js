const RewardCalculator = require('../algorithms/rewardCalculator');
const SolanaBlockchainService = require('./solanaBlockchainService');
const mongoose = require('mongoose');
const cron = require('node-cron');

/**
 * Token Reward Service
 * Main service that orchestrates reward calculation and distribution
 */
class TokenRewardService {
  constructor() {
    this.rewardCalculator = new RewardCalculator();
    this.blockchainService = new SolanaBlockchainService();
    
    // Queue for batch processing
    this.rewardQueue = [];
    this.processing = false;
    
    // Statistics tracking
    this.stats = {
      totalTokensDistributed: 0,
      totalRewardsProcessed: 0,
      totalUsers: 0,
      averageRewardPerUser: 0,
      distributionSuccessRate: 0
    };

    this.initializeScheduler();
  }

  /**
   * Process a recycling scan and calculate rewards
   * @param {Object} scanData - Recycling scan data
   * @returns {Object} - Reward calculation and distribution result
   */
  async processScanReward(scanData) {
    try {
      const {
        userId,
        walletAddress,
        itemType,
        classification,
        confidence,
        isCorrect,
        timestamp,
        location
      } = scanData;

      // Get user statistics for better reward calculation
      const userStats = await this.getUserStats(userId);

      // Calculate reward
      const rewardData = this.rewardCalculator.calculateScanReward({
        isCorrect,
        confidence,
        userStats,
        itemType,
        timestamp
      });

      // Apply seasonal multipliers
      const seasonalMultiplier = this.rewardCalculator.getSeasonalMultiplier(new Date(timestamp));
      const finalTokenAmount = Math.floor(rewardData.totalTokens * seasonalMultiplier);

      // Validate reward eligibility (anti-fraud)
      const userHistory = await this.getUserHistory(userId);
      const isEligible = this.rewardCalculator.validateRewardEligibility(scanData, userHistory);

      if (!isEligible) {
        return {
          success: false,
          error: 'Activity failed fraud detection checks',
          userId,
          tokensAwarded: 0
        };
      }

      // Add to reward queue for batch processing
      const rewardEntry = {
        userId,
        walletAddress,
        tokenAmount: finalTokenAmount,
        activityType: 'scan',
        reason: `Recycling ${itemType} - ${Math.round(confidence * 100)}% confidence`,
        breakdown: rewardData.breakdown,
        multipliers: {
          ...rewardData.multipliers,
          seasonal: seasonalMultiplier
        },
        timestamp: new Date(timestamp),
        metadata: {
          itemType,
          classification,
          confidence,
          location
        }
      };

      // For high-value rewards or VIP users, process immediately
      if (finalTokenAmount > 100 || userStats.userLevel === 'vip') {
        const distributionResult = await this.distributeRewardImmediate(rewardEntry);
        return distributionResult;
      } else {
        // Add to batch queue
        this.addToRewardQueue(rewardEntry);
        return {
          success: true,
          queued: true,
          userId,
          tokensAwarded: finalTokenAmount,
          estimatedProcessingTime: '5-15 minutes'
        };
      }

    } catch (error) {
      console.error('Error processing scan reward:', error);
      return {
        success: false,
        error: error.message,
        userId: scanData.userId,
        tokensAwarded: 0
      };
    }
  }

  /**
   * Process streak rewards
   * @param {Object} streakData - Streak information
   * @returns {Object} - Reward result
   */
  async processStreakReward(streakData) {
    try {
      const { userId, walletAddress, currentStreak, streakType, isNewRecord } = streakData;

      const rewardData = this.rewardCalculator.calculateStreakReward({
        currentStreak,
        streakType,
        isNewRecord
      });

      if (rewardData.totalTokens > 0) {
        const rewardEntry = {
          userId,
          walletAddress,
          tokenAmount: rewardData.totalTokens,
          activityType: 'streak',
          reason: `${currentStreak}-day recycling streak${isNewRecord ? ' (New Record!)' : ''}`,
          breakdown: rewardData.breakdown,
          timestamp: new Date(),
          metadata: { currentStreak, streakType, isNewRecord }
        };

        // Streak rewards are always processed immediately for motivation
        return await this.distributeRewardImmediate(rewardEntry);
      }

      return {
        success: true,
        userId,
        tokensAwarded: 0,
        message: 'No streak reward earned'
      };

    } catch (error) {
      console.error('Error processing streak reward:', error);
      return {
        success: false,
        error: error.message,
        userId: streakData.userId,
        tokensAwarded: 0
      };
    }
  }

  /**
   * Process achievement rewards
   * @param {Object} achievementData - Achievement information
   * @returns {Object} - Reward result
   */
  async processAchievementReward(achievementData) {
    try {
      const { userId, walletAddress, achievementType, milestone, isRare } = achievementData;

      const rewardData = this.rewardCalculator.calculateAchievementReward({
        type: achievementType,
        milestone,
        isRare
      });

      const rewardEntry = {
        userId,
        walletAddress,
        tokenAmount: rewardData.totalTokens,
        activityType: 'achievement',
        reason: `Achievement Unlocked: ${achievementType} milestone ${milestone}${isRare ? ' (RARE!)' : ''}`,
        breakdown: rewardData.breakdown,
        timestamp: new Date(),
        metadata: { achievementType, milestone, isRare }
      };

      // Achievement rewards are processed immediately for celebration
      return await this.distributeRewardImmediate(rewardEntry);

    } catch (error) {
      console.error('Error processing achievement reward:', error);
      return {
        success: false,
        error: error.message,
        userId: achievementData.userId,
        tokensAwarded: 0
      };
    }
  }

  /**
   * Process community contribution rewards
   * @param {Object} contributionData - Community activity data
   * @returns {Object} - Reward result
   */
  async processCommunityReward(contributionData) {
    try {
      const { userId, walletAddress, activityType, impact, userLevel } = contributionData;

      const rewardData = this.rewardCalculator.calculateCommunityReward({
        activityType,
        impact,
        userLevel
      });

      const rewardEntry = {
        userId,
        walletAddress,
        tokenAmount: rewardData.totalTokens,
        activityType: 'community',
        reason: `Community contribution: ${activityType}`,
        breakdown: rewardData.breakdown,
        timestamp: new Date(),
        metadata: { activityType, impact, userLevel }
      };

      // Community rewards go to batch processing
      this.addToRewardQueue(rewardEntry);
      
      return {
        success: true,
        queued: true,
        userId,
        tokensAwarded: rewardData.totalTokens
      };

    } catch (error) {
      console.error('Error processing community reward:', error);
      return {
        success: false,
        error: error.message,
        userId: contributionData.userId,
        tokensAwarded: 0
      };
    }
  }

  /**
   * Process batch rewards for multiple users
   * @param {Array} userActivities - Array of user activities
   * @returns {Array} - Array of reward results
   */
  async processBatchRewards(userActivities) {
    try {
      // Calculate all rewards
      const rewards = this.rewardCalculator.calculateBatchRewards(userActivities);

      // Prepare distributions
      const distributions = rewards
        .filter(reward => reward.totalTokens > 0)
        .map(reward => ({
          address: reward.walletAddress,
          amount: reward.totalTokens,
          reason: `Batch reward: ${reward.activityType}`
        }));

      // Execute blockchain distributions
      const results = await this.blockchainService.batchDistributeTokens(distributions);

      // Update statistics
      this.updateStats(results);

      return results;

    } catch (error) {
      console.error('Error processing batch rewards:', error);
      return [];
    }
  }

  /**
   * Distribute reward immediately
   * @param {Object} rewardEntry - Reward data
   * @returns {Object} - Distribution result
   */
  async distributeRewardImmediate(rewardEntry) {
    try {
      const { walletAddress, tokenAmount, reason } = rewardEntry;

      const distributionResult = await this.blockchainService.distributeTokensToUser(
        walletAddress,
        tokenAmount,
        reason
      );

      // Log the reward transaction
      await this.logRewardTransaction({
        ...rewardEntry,
        distributionResult,
        processedAt: new Date()
      });

      // Update user stats
      await this.updateUserStats(rewardEntry.userId, tokenAmount);

      return {
        success: distributionResult.success,
        userId: rewardEntry.userId,
        tokensAwarded: tokenAmount,
        transactionHash: distributionResult.transactionHash,
        error: distributionResult.error
      };

    } catch (error) {
      console.error('Error distributing immediate reward:', error);
      return {
        success: false,
        userId: rewardEntry.userId,
        tokensAwarded: 0,
        error: error.message
      };
    }
  }

  /**
   * Add reward to processing queue
   * @param {Object} rewardEntry - Reward data
   */
  addToRewardQueue(rewardEntry) {
    this.rewardQueue.push({
      ...rewardEntry,
      queuedAt: new Date()
    });

    // Process immediately if queue is getting full
    if (this.rewardQueue.length >= 50 && !this.processing) {
      this.processBatchQueue();
    }
  }

  /**
   * Process the reward queue in batches
   */
  async processBatchQueue() {
    if (this.processing || this.rewardQueue.length === 0) {
      return;
    }

    this.processing = true;
    console.log(`Processing ${this.rewardQueue.length} queued rewards...`);

    try {
      // Take all items from queue
      const queueItems = [...this.rewardQueue];
      this.rewardQueue = [];

      // Group by wallet address to optimize gas costs
      const groupedRewards = this.groupRewardsByWallet(queueItems);

      // Process each group
      for (const walletAddress in groupedRewards) {
        const userRewards = groupedRewards[walletAddress];
        const totalTokens = userRewards.reduce((sum, reward) => sum + reward.tokenAmount, 0);

        if (totalTokens > 0) {
          const distributionResult = await this.blockchainService.distributeTokensToUser(
            walletAddress,
            totalTokens,
            `Batch reward: ${userRewards.length} activities`
          );

          // Log each reward transaction
          for (const reward of userRewards) {
            await this.logRewardTransaction({
              ...reward,
              distributionResult,
              processedAt: new Date(),
              batchProcessed: true
            });

            // Update user stats
            await this.updateUserStats(reward.userId, reward.tokenAmount);
          }
        }

        // Small delay to prevent nonce issues
        await new Promise(resolve => setTimeout(resolve, 1000));
      }

      console.log('Batch processing completed successfully');

    } catch (error) {
      console.error('Error processing batch queue:', error);
    } finally {
      this.processing = false;
    }
  }

  /**
   * Group rewards by wallet address for efficient batch processing
   * @param {Array} rewards - Array of reward entries
   * @returns {Object} - Grouped rewards by wallet address
   */
  groupRewardsByWallet(rewards) {
    return rewards.reduce((groups, reward) => {
      const wallet = reward.walletAddress;
      if (!groups[wallet]) {
        groups[wallet] = [];
      }
      groups[wallet].push(reward);
      return groups;
    }, {});
  }

  /**
   * Initialize scheduled tasks
   */
  initializeScheduler() {
    // Process reward queue every 5 minutes
    cron.schedule('*/5 * * * *', () => {
      this.processBatchQueue();
    });

    // Generate daily streak rewards at midnight
    cron.schedule('0 0 * * *', () => {
      this.processDailyStreaks();
    });

    // Update statistics every hour
    cron.schedule('0 * * * *', () => {
      this.updateDashboardStats();
    });
  }

  /**
   * Process daily streak rewards for all users
   */
  async processDailyStreaks() {
    try {
      console.log('Processing daily streaks...');
      // This would connect to your user database to check streaks
      // Implementation depends on your database structure
    } catch (error) {
      console.error('Error processing daily streaks:', error);
    }
  }

  /**
   * Get user statistics for reward calculation
   * @param {string} userId - User ID
   * @returns {Object} - User statistics
   */
  async getUserStats(userId) {
    // This would connect to your database
    // Returning mock data for now
    return {
      averageAccuracy: 85,
      currentStreak: 7,
      dailyAverage: 3,
      consistency: 80,
      userLevel: 'intermediate',
      totalRecycled: 150
    };
  }

  /**
   * Get user history for fraud detection
   * @param {string} userId - User ID
   * @returns {Object} - User activity history
   */
  async getUserHistory(userId) {
    // This would connect to your database
    // Returning mock data for now
    return {
      recentActivities: [],
      averageSessionTime: 30000,
      typicalLocations: []
    };
  }

  /**
   * Log reward transaction
   * @param {Object} rewardData - Complete reward information
   */
  async logRewardTransaction(rewardData) {
    try {
      // This would save to your database
      console.log('Reward transaction logged:', {
        userId: rewardData.userId,
        tokenAmount: rewardData.tokenAmount,
        transactionHash: rewardData.distributionResult?.transactionHash,
        success: rewardData.distributionResult?.success
      });
    } catch (error) {
      console.error('Error logging reward transaction:', error);
    }
  }

  /**
   * Update user statistics
   * @param {string} userId - User ID
   * @param {number} tokensEarned - Tokens earned
   */
  async updateUserStats(userId, tokensEarned) {
    try {
      // This would update your database
      console.log(`Updated stats for user ${userId}: +${tokensEarned} tokens`);
    } catch (error) {
      console.error('Error updating user stats:', error);
    }
  }

  /**
   * Update service statistics
   * @param {Array} results - Distribution results
   */
  updateStats(results) {
    const successful = results.filter(r => r.success);
    const totalTokens = successful.reduce((sum, r) => sum + r.tokenAmount, 0);

    this.stats.totalTokensDistributed += totalTokens;
    this.stats.totalRewardsProcessed += results.length;
    this.stats.distributionSuccessRate = successful.length / results.length;
  }

  /**
   * Update dashboard statistics
   */
  async updateDashboardStats() {
    try {
      // This would calculate and cache statistics for dashboard
      console.log('Dashboard stats updated');
    } catch (error) {
      console.error('Error updating dashboard stats:', error);
    }
  }

  /**
   * Get service statistics
   * @returns {Object} - Current service statistics
   */
  getStats() {
    return { ...this.stats };
  }

  /**
   * Get current reward queue status
   * @returns {Object} - Queue information
   */
  getQueueStatus() {
    return {
      queueLength: this.rewardQueue.length,
      processing: this.processing,
      oldestQueuedAt: this.rewardQueue.length > 0 ? this.rewardQueue[0].queuedAt : null
    };
  }
}

module.exports = TokenRewardService;
