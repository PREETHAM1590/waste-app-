const TokenRewardService = require('../services/tokenRewardService');
const { validationResult } = require('express-validator');

/**
 * Reward Controller
 * Handles all reward-related API endpoints
 */
class RewardController {
  constructor() {
    this.tokenRewardService = new TokenRewardService();
  }

  /**
   * Process recycling scan reward
   * POST /api/rewards/scan
   */
  async processScanReward(req, res) {
    try {
      // Check validation errors
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array()
        });
      }

      const {
        userId,
        walletAddress,
        itemType,
        classification,
        confidence,
        isCorrect,
        timestamp,
        location
      } = req.body;

      const result = await this.tokenRewardService.processScanReward({
        userId,
        walletAddress,
        itemType,
        classification,
        confidence,
        isCorrect,
        timestamp: timestamp || new Date().toISOString(),
        location
      });

      res.status(200).json({
        success: true,
        data: result
      });

    } catch (error) {
      console.error('Error in processScanReward:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Process streak reward
   * POST /api/rewards/streak
   */
  async processStreakReward(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array()
        });
      }

      const { userId, walletAddress, currentStreak, streakType, isNewRecord } = req.body;

      const result = await this.tokenRewardService.processStreakReward({
        userId,
        walletAddress,
        currentStreak,
        streakType,
        isNewRecord
      });

      res.status(200).json({
        success: true,
        data: result
      });

    } catch (error) {
      console.error('Error in processStreakReward:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Process achievement reward
   * POST /api/rewards/achievement
   */
  async processAchievementReward(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array()
        });
      }

      const { userId, walletAddress, achievementType, milestone, isRare } = req.body;

      const result = await this.tokenRewardService.processAchievementReward({
        userId,
        walletAddress,
        achievementType,
        milestone,
        isRare: isRare || false
      });

      res.status(200).json({
        success: true,
        data: result
      });

    } catch (error) {
      console.error('Error in processAchievementReward:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Process community contribution reward
   * POST /api/rewards/community
   */
  async processCommunityReward(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array()
        });
      }

      const { userId, walletAddress, activityType, impact, userLevel } = req.body;

      const result = await this.tokenRewardService.processCommunityReward({
        userId,
        walletAddress,
        activityType,
        impact,
        userLevel
      });

      res.status(200).json({
        success: true,
        data: result
      });

    } catch (error) {
      console.error('Error in processCommunityReward:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Process batch rewards for multiple users
   * POST /api/rewards/batch
   */
  async processBatchRewards(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array()
        });
      }

      const { userActivities } = req.body;

      if (!Array.isArray(userActivities) || userActivities.length === 0) {
        return res.status(400).json({
          success: false,
          error: 'userActivities must be a non-empty array'
        });
      }

      const results = await this.tokenRewardService.processBatchRewards(userActivities);

      res.status(200).json({
        success: true,
        data: {
          results,
          totalProcessed: results.length,
          successful: results.filter(r => r.success).length,
          failed: results.filter(r => !r.success).length
        }
      });

    } catch (error) {
      console.error('Error in processBatchRewards:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Get user token balance
   * GET /api/rewards/balance/:walletAddress
   */
  async getUserBalance(req, res) {
    try {
      const { walletAddress } = req.params;

      if (!walletAddress || !this.tokenRewardService.blockchainService.isValidAddress(walletAddress)) {
        return res.status(400).json({
          success: false,
          error: 'Invalid wallet address'
        });
      }

      const result = await this.tokenRewardService.blockchainService.getUserTokenBalance(walletAddress);

      res.status(200).json({
        success: true,
        data: result
      });

    } catch (error) {
      console.error('Error in getUserBalance:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Get token information
   * GET /api/rewards/token-info
   */
  async getTokenInfo(req, res) {
    try {
      const result = await this.tokenRewardService.blockchainService.getTokenInfo();

      res.status(200).json({
        success: true,
        data: result
      });

    } catch (error) {
      console.error('Error in getTokenInfo:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Get transaction status
   * GET /api/rewards/transaction/:txHash
   */
  async getTransactionStatus(req, res) {
    try {
      const { txHash } = req.params;

      if (!txHash) {
        return res.status(400).json({
          success: false,
          error: 'Transaction hash is required'
        });
      }

      const result = await this.tokenRewardService.blockchainService.getTransactionStatus(txHash);

      res.status(200).json({
        success: true,
        data: result
      });

    } catch (error) {
      console.error('Error in getTransactionStatus:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Get service statistics
   * GET /api/rewards/stats
   */
  async getStats(req, res) {
    try {
      const stats = this.tokenRewardService.getStats();
      const queueStatus = this.tokenRewardService.getQueueStatus();
      const networkInfo = await this.tokenRewardService.blockchainService.getNetworkInfo();

      res.status(200).json({
        success: true,
        data: {
          serviceStats: stats,
          queueStatus,
          networkInfo
        }
      });

    } catch (error) {
      console.error('Error in getStats:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Get gas prices
   * GET /api/rewards/gas-prices
   */
  async getGasPrices(req, res) {
    try {
      const result = await this.tokenRewardService.blockchainService.getGasPrices();

      res.status(200).json({
        success: true,
        data: result
      });

    } catch (error) {
      console.error('Error in getGasPrices:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Estimate gas for token transfer
   * POST /api/rewards/estimate-gas
   */
  async estimateGas(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array()
        });
      }

      const { toAddress, tokenAmount } = req.body;

      const result = await this.tokenRewardService.blockchainService.estimateTransferGas(toAddress, tokenAmount);

      res.status(200).json({
        success: true,
        data: result
      });

    } catch (error) {
      console.error('Error in estimateGas:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Force process reward queue
   * POST /api/rewards/process-queue
   */
  async processQueue(req, res) {
    try {
      // This should be protected with admin authentication
      await this.tokenRewardService.processBatchQueue();

      const queueStatus = this.tokenRewardService.getQueueStatus();

      res.status(200).json({
        success: true,
        message: 'Queue processing initiated',
        data: queueStatus
      });

    } catch (error) {
      console.error('Error in processQueue:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Get reward history for user
   * GET /api/rewards/history/:userId
   */
  async getRewardHistory(req, res) {
    try {
      const { userId } = req.params;
      const { page = 1, limit = 20 } = req.query;

      if (!userId) {
        return res.status(400).json({
          success: false,
          error: 'User ID is required'
        });
      }

      // This would fetch from your database
      // For now, returning mock data
      const mockHistory = {
        userId,
        totalEarned: 1250,
        recentRewards: [
          {
            id: '1',
            type: 'scan',
            amount: 15,
            reason: 'Recycling plastic bottle - 92% confidence',
            timestamp: new Date().toISOString(),
            transactionHash: '0x123...'
          },
          {
            id: '2',
            type: 'streak',
            amount: 20,
            reason: '7-day recycling streak',
            timestamp: new Date(Date.now() - 86400000).toISOString(),
            transactionHash: '0x456...'
          }
        ],
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: 25,
          totalPages: Math.ceil(25 / limit)
        }
      };

      res.status(200).json({
        success: true,
        data: mockHistory
      });

    } catch (error) {
      console.error('Error in getRewardHistory:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Airdrop SOL for devnet testing
   * POST /api/rewards/airdrop-sol
   */
  async airdropSol(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          errors: errors.array()
        });
      }

      const { walletAddress, amount = 1 } = req.body;

      const result = await this.tokenRewardService.blockchainService.airdropSol(walletAddress, amount);

      res.status(200).json({
        success: true,
        data: result
      });

    } catch (error) {
      console.error('Error in airdropSol:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }

  /**
   * Get available achievements
   * GET /api/rewards/achievements
   */
  async getAchievements(req, res) {
    try {
      // This would fetch from your database
      // For now, returning mock data based on RewardCalculator achievements
      const achievements = {
        recycling: this.tokenRewardService.rewardCalculator.ACHIEVEMENTS.RECYCLING_MILESTONES.map(milestone => ({
          type: 'recycling',
          milestone,
          reward: milestone * 10,
          description: `Recycle ${milestone} items`,
          icon: '♻️'
        })),
        accuracy: this.tokenRewardService.rewardCalculator.ACHIEVEMENTS.ACCURACY_MILESTONES.map(milestone => ({
          type: 'accuracy',
          milestone,
          reward: milestone * 20,
          description: `Achieve ${milestone}% accuracy`,
          icon: '🎯'
        })),
        streak: this.tokenRewardService.rewardCalculator.ACHIEVEMENTS.STREAK_MILESTONES.map(milestone => ({
          type: 'streak',
          milestone,
          reward: milestone * 15,
          description: `Maintain ${milestone}-day streak`,
          icon: '🔥'
        })),
        community: this.tokenRewardService.rewardCalculator.ACHIEVEMENTS.COMMUNITY_MILESTONES.map(milestone => ({
          type: 'community',
          milestone,
          reward: milestone * 25,
          description: `Make ${milestone} community contributions`,
          icon: '🤝'
        }))
      };

      res.status(200).json({
        success: true,
        data: achievements
      });

    } catch (error) {
      console.error('Error in getAchievements:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
        message: error.message
      });
    }
  }
}

module.exports = new RewardController();
