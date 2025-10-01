const express = require('express');
const { body, param, query } = require('express-validator');
const rewardController = require('../controllers/rewardController');
const rateLimit = require('express-rate-limit');

const router = express.Router();

// Rate limiting for reward endpoints
const rewardRateLimit = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute
  max: 30, // limit each IP to 30 requests per windowMs
  message: {
    success: false,
    error: 'Too many reward requests, please try again later'
  }
});

const batchRateLimit = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 5, // limit batch operations
  message: {
    success: false,
    error: 'Too many batch requests, please try again later'
  }
});

// Custom Solana address validator
const isSolanaAddress = (value) => {
  try {
    // Solana addresses are Base58 encoded and should be 32-44 characters
    return /^[1-9A-HJ-NP-Za-km-z]{32,44}$/.test(value);
  } catch {
    return false;
  }
};

// Validation middleware
const scanRewardValidation = [
  body('userId').notEmpty().withMessage('User ID is required'),
  body('walletAddress').custom(isSolanaAddress).withMessage('Valid Solana wallet address is required'),
  body('itemType').notEmpty().withMessage('Item type is required'),
  body('classification').notEmpty().withMessage('Classification is required'),
  body('confidence').isFloat({ min: 0, max: 1 }).withMessage('Confidence must be between 0 and 1'),
  body('isCorrect').isBoolean().withMessage('isCorrect must be a boolean'),
  body('timestamp').optional().isISO8601().withMessage('Timestamp must be valid ISO 8601 date'),
  body('location').optional().notEmpty().withMessage('Location cannot be empty if provided')
];

const streakRewardValidation = [
  body('userId').notEmpty().withMessage('User ID is required'),
  body('walletAddress').custom(isSolanaAddress).withMessage('Valid Solana wallet address is required'),
  body('currentStreak').isInt({ min: 1 }).withMessage('Current streak must be a positive integer'),
  body('streakType').isIn(['daily', 'weekly', 'monthly']).withMessage('Invalid streak type'),
  body('isNewRecord').optional().isBoolean().withMessage('isNewRecord must be a boolean')
];

const achievementRewardValidation = [
  body('userId').notEmpty().withMessage('User ID is required'),
  body('walletAddress').custom(isSolanaAddress).withMessage('Valid Solana wallet address is required'),
  body('achievementType').isIn(['recycling', 'accuracy', 'streak', 'community']).withMessage('Invalid achievement type'),
  body('milestone').isInt({ min: 1 }).withMessage('Milestone must be a positive integer'),
  body('isRare').optional().isBoolean().withMessage('isRare must be a boolean')
];

const communityRewardValidation = [
  body('userId').notEmpty().withMessage('User ID is required'),
  body('walletAddress').custom(isSolanaAddress).withMessage('Valid Solana wallet address is required'),
  body('activityType').isIn(['tip_sharing', 'location_reporting', 'community_challenge', 'mentoring', 'content_creation']).withMessage('Invalid activity type'),
  body('impact').isIn(['low', 'medium', 'high', 'viral']).withMessage('Invalid impact level'),
  body('userLevel').isIn(['beginner', 'intermediate', 'advanced', 'expert', 'master']).withMessage('Invalid user level')
];

const batchRewardValidation = [
  body('userActivities').isArray({ min: 1, max: 100 }).withMessage('userActivities must be an array with 1-100 items'),
  body('userActivities.*.userId').notEmpty().withMessage('Each activity must have a userId'),
  body('userActivities.*.activityType').isIn(['scan', 'streak', 'achievement', 'community']).withMessage('Invalid activity type'),
  body('userActivities.*.data').isObject().withMessage('Each activity must have data object')
];

const gasEstimationValidation = [
  body('toAddress').custom(isSolanaAddress).withMessage('Valid Solana wallet address is required'),
  body('tokenAmount').isFloat({ min: 0 }).withMessage('Token amount must be a positive number')
];

// Routes

/**
 * Process recycling scan reward
 * POST /api/rewards/scan
 */
router.post('/scan', 
  rewardRateLimit,
  scanRewardValidation,
  rewardController.processScanReward.bind(rewardController)
);

/**
 * Process streak reward
 * POST /api/rewards/streak
 */
router.post('/streak',
  rewardRateLimit,
  streakRewardValidation,
  rewardController.processStreakReward.bind(rewardController)
);

/**
 * Process achievement reward
 * POST /api/rewards/achievement
 */
router.post('/achievement',
  rewardRateLimit,
  achievementRewardValidation,
  rewardController.processAchievementReward.bind(rewardController)
);

/**
 * Process community contribution reward
 * POST /api/rewards/community
 */
router.post('/community',
  rewardRateLimit,
  communityRewardValidation,
  rewardController.processCommunityReward.bind(rewardController)
);

/**
 * Process batch rewards for multiple users
 * POST /api/rewards/batch
 */
router.post('/batch',
  batchRateLimit,
  batchRewardValidation,
  rewardController.processBatchRewards.bind(rewardController)
);

/**
 * Get user token balance
 * GET /api/rewards/balance/:walletAddress
 */
router.get('/balance/:walletAddress',
  param('walletAddress').custom(isSolanaAddress).withMessage('Valid Solana wallet address is required'),
  rewardController.getUserBalance.bind(rewardController)
);

/**
 * Get token information
 * GET /api/rewards/token-info
 */
router.get('/token-info',
  rewardController.getTokenInfo.bind(rewardController)
);

/**
 * Get transaction status
 * GET /api/rewards/transaction/:txHash
 */
router.get('/transaction/:txHash',
  param('txHash').isLength({ min: 64, max: 66 }).withMessage('Invalid transaction hash'),
  rewardController.getTransactionStatus.bind(rewardController)
);

/**
 * Get service statistics
 * GET /api/rewards/stats
 */
router.get('/stats',
  rewardController.getStats.bind(rewardController)
);

/**
 * Get current gas prices
 * GET /api/rewards/gas-prices
 */
router.get('/gas-prices',
  rewardController.getGasPrices.bind(rewardController)
);

/**
 * Estimate gas for token transfer
 * POST /api/rewards/estimate-gas
 */
router.post('/estimate-gas',
  gasEstimationValidation,
  rewardController.estimateGas.bind(rewardController)
);

/**
 * Force process reward queue (Admin only)
 * POST /api/rewards/process-queue
 */
router.post('/process-queue',
  // Add admin authentication middleware here
  rewardController.processQueue.bind(rewardController)
);

/**
 * Get reward history for user
 * GET /api/rewards/history/:userId
 */
router.get('/history/:userId',
  param('userId').notEmpty().withMessage('User ID is required'),
  query('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
  rewardController.getRewardHistory.bind(rewardController)
);

/**
 * Airdrop SOL for devnet testing
 * POST /api/rewards/airdrop-sol
 */
router.post('/airdrop-sol',
  body('walletAddress').custom(isSolanaAddress).withMessage('Valid Solana wallet address is required'),
  body('amount').optional().isFloat({ min: 0.1, max: 5 }).withMessage('Amount must be between 0.1 and 5 SOL on devnet'),
  rewardController.airdropSol.bind(rewardController)
);

/**
 * Get available achievements
 * GET /api/rewards/achievements
 */
router.get('/achievements',
  rewardController.getAchievements.bind(rewardController)
);

// Health check endpoint
router.get('/health', (req, res) => {
  res.status(200).json({
    success: true,
    message: 'Reward API is healthy',
    timestamp: new Date().toISOString()
  });
});

module.exports = router;
