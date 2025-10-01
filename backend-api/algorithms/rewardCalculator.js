/**
 * Advanced Token Reward Distribution Algorithms
 * Handles multiple reward criteria and sophisticated token distribution
 */

class RewardCalculator {
  constructor() {
    // Base reward rates (tokens per action)
    this.BASE_REWARDS = {
      CORRECT_SCAN: 10,
      HIGH_CONFIDENCE_SCAN: 5, // Additional for >90% confidence
      DAILY_STREAK: 20,
      WEEKLY_STREAK: 100,
      MONTHLY_STREAK: 500,
      PERFECT_ACCURACY_DAY: 50,
      COMMUNITY_CONTRIBUTION: 25,
      EDUCATION_COMPLETION: 30,
      REFERRAL: 200
    };

    // Multipliers for consistency and performance
    this.MULTIPLIERS = {
      ACCURACY: {
        PERFECT: 2.0,    // 100% accuracy
        EXCELLENT: 1.5,  // 95%+
        GOOD: 1.2,       // 80%+
        AVERAGE: 1.0,    // <80%
      },
      STREAK: {
        LEGENDARY: 3.0,  // 100+ days
        MASTER: 2.5,     // 50+ days
        EXPERT: 2.0,     // 30+ days
        ADVANCED: 1.5,   // 14+ days
        BEGINNER: 1.0    // <14 days
      },
      FREQUENCY: {
        SUPER_ACTIVE: 2.0,    // 10+ scans/day
        VERY_ACTIVE: 1.7,     // 5-9 scans/day
        ACTIVE: 1.4,          // 3-4 scans/day
        MODERATE: 1.0,        // 1-2 scans/day
        OCCASIONAL: 0.8       // <1 scan/day average
      },
      CONSISTENCY: {
        PERFECT: 2.5,    // Active every day for 30 days
        EXCELLENT: 2.0,  // Active 25+ out of 30 days
        GOOD: 1.5,       // Active 20+ out of 30 days
        AVERAGE: 1.0     // Less consistent
      }
    };

    // Achievement thresholds
    this.ACHIEVEMENTS = {
      RECYCLING_MILESTONES: [10, 50, 100, 250, 500, 1000, 2500, 5000],
      ACCURACY_MILESTONES: [80, 90, 95, 99], // Percentage
      STREAK_MILESTONES: [7, 14, 30, 50, 100, 250, 365],
      COMMUNITY_MILESTONES: [5, 25, 50, 100] // Community contributions
    };
  }

  /**
   * Calculate tokens for a single recycling scan
   * @param {Object} scanData - Contains confidence, accuracy, userStats, etc.
   * @returns {Object} - Reward breakdown and total tokens
   */
  calculateScanReward(scanData) {
    const {
      isCorrect,
      confidence,
      userStats,
      itemType,
      timestamp
    } = scanData;

    let totalTokens = 0;
    const breakdown = {};

    // Base reward for correct scan
    if (isCorrect) {
      totalTokens += this.BASE_REWARDS.CORRECT_SCAN;
      breakdown.correctScan = this.BASE_REWARDS.CORRECT_SCAN;

      // High confidence bonus
      if (confidence > 0.9) {
        totalTokens += this.BASE_REWARDS.HIGH_CONFIDENCE_SCAN;
        breakdown.highConfidence = this.BASE_REWARDS.HIGH_CONFIDENCE_SCAN;
      }
    }

    // Apply multipliers based on user performance
    const accuracyMultiplier = this.getAccuracyMultiplier(userStats.averageAccuracy);
    const streakMultiplier = this.getStreakMultiplier(userStats.currentStreak);
    const frequencyMultiplier = this.getFrequencyMultiplier(userStats.dailyAverage);
    const consistencyMultiplier = this.getConsistencyMultiplier(userStats.consistency);

    // Calculate final multiplier
    const finalMultiplier = (accuracyMultiplier + streakMultiplier + frequencyMultiplier + consistencyMultiplier) / 4;

    totalTokens = Math.floor(totalTokens * finalMultiplier);

    return {
      totalTokens,
      breakdown,
      multipliers: {
        accuracy: accuracyMultiplier,
        streak: streakMultiplier,
        frequency: frequencyMultiplier,
        consistency: consistencyMultiplier,
        final: finalMultiplier
      }
    };
  }

  /**
   * Calculate streak rewards (daily, weekly, monthly)
   * @param {Object} streakData - Current streak info
   * @returns {Object} - Streak reward breakdown
   */
  calculateStreakReward(streakData) {
    const { currentStreak, streakType, isNewRecord } = streakData;
    let totalTokens = 0;
    const breakdown = {};

    // Daily streak rewards
    if (streakType === 'daily') {
      totalTokens += this.BASE_REWARDS.DAILY_STREAK;
      breakdown.dailyStreak = this.BASE_REWARDS.DAILY_STREAK;

      // Weekly streak bonus
      if (currentStreak % 7 === 0 && currentStreak > 0) {
        const weeklyBonus = this.BASE_REWARDS.WEEKLY_STREAK;
        totalTokens += weeklyBonus;
        breakdown.weeklyBonus = weeklyBonus;
      }

      // Monthly streak bonus
      if (currentStreak % 30 === 0 && currentStreak > 0) {
        const monthlyBonus = this.BASE_REWARDS.MONTHLY_STREAK;
        totalTokens += monthlyBonus;
        breakdown.monthlyBonus = monthlyBonus;
      }

      // New record bonus
      if (isNewRecord) {
        const recordBonus = Math.floor(currentStreak * 5); // 5 tokens per day of new record
        totalTokens += recordBonus;
        breakdown.newRecordBonus = recordBonus;
      }
    }

    return { totalTokens, breakdown };
  }

  /**
   * Calculate achievement rewards
   * @param {Object} achievementData - Achievement unlocked info
   * @returns {Object} - Achievement reward
   */
  calculateAchievementReward(achievementData) {
    const { type, milestone, isRare } = achievementData;
    let baseReward = 0;

    switch (type) {
      case 'recycling':
        baseReward = milestone * 10; // More items = more tokens
        break;
      case 'accuracy':
        baseReward = milestone * 20; // Higher accuracy = premium rewards
        break;
      case 'streak':
        baseReward = milestone * 15;
        break;
      case 'community':
        baseReward = milestone * 25;
        break;
      default:
        baseReward = 100;
    }

    // Rare achievement multiplier
    if (isRare) {
      baseReward *= 2;
    }

    return {
      totalTokens: baseReward,
      breakdown: {
        baseReward,
        rareMultiplier: isRare ? 2 : 1
      }
    };
  }

  /**
   * Calculate community contribution rewards
   * @param {Object} contributionData - Community activity data
   * @returns {Object} - Community reward
   */
  calculateCommunityReward(contributionData) {
    const { activityType, impact, userLevel } = contributionData;
    let baseReward = this.BASE_REWARDS.COMMUNITY_CONTRIBUTION;

    // Activity type multipliers
    const activityMultipliers = {
      'tip_sharing': 1.0,
      'location_reporting': 1.2,
      'community_challenge': 1.5,
      'mentoring': 2.0,
      'content_creation': 2.5
    };

    // Impact multipliers
    const impactMultipliers = {
      'low': 0.5,
      'medium': 1.0,
      'high': 1.5,
      'viral': 3.0
    };

    // User level multipliers
    const levelMultipliers = {
      'beginner': 1.0,
      'intermediate': 1.2,
      'advanced': 1.5,
      'expert': 2.0,
      'master': 2.5
    };

    const totalMultiplier = (activityMultipliers[activityType] || 1.0) *
                          (impactMultipliers[impact] || 1.0) *
                          (levelMultipliers[userLevel] || 1.0);

    const totalTokens = Math.floor(baseReward * totalMultiplier);

    return {
      totalTokens,
      breakdown: {
        baseReward,
        activityMultiplier: activityMultipliers[activityType] || 1.0,
        impactMultiplier: impactMultipliers[impact] || 1.0,
        levelMultiplier: levelMultipliers[userLevel] || 1.0,
        totalMultiplier
      }
    };
  }

  /**
   * Calculate batch rewards for multiple users
   * @param {Array} userActivities - Array of user activities to reward
   * @returns {Array} - Array of reward calculations
   */
  calculateBatchRewards(userActivities) {
    return userActivities.map(activity => {
      const { userId, activityType, data } = activity;

      let reward = { totalTokens: 0, breakdown: {}, userId };

      switch (activityType) {
        case 'scan':
          reward = { ...this.calculateScanReward(data), userId };
          break;
        case 'streak':
          reward = { ...this.calculateStreakReward(data), userId };
          break;
        case 'achievement':
          reward = { ...this.calculateAchievementReward(data), userId };
          break;
        case 'community':
          reward = { ...this.calculateCommunityReward(data), userId };
          break;
      }

      return reward;
    });
  }

  /**
   * Calculate seasonal/event bonus multipliers
   * @param {Date} timestamp - When the activity occurred
   * @returns {Number} - Seasonal multiplier
   */
  getSeasonalMultiplier(timestamp = new Date()) {
    const month = timestamp.getMonth();
    const date = timestamp.getDate();

    // Earth Day (April 22) - 3x multiplier for the week
    if (month === 3 && date >= 18 && date <= 25) {
      return 3.0;
    }

    // World Environment Day (June 5) - 2x multiplier
    if (month === 5 && date === 5) {
      return 2.0;
    }

    // Recycle Week (varies, but let's say first week of November) - 2x multiplier
    if (month === 10 && date <= 7) {
      return 2.0;
    }

    // Weekend bonus - 1.2x multiplier
    const dayOfWeek = timestamp.getDay();
    if (dayOfWeek === 0 || dayOfWeek === 6) {
      return 1.2;
    }

    return 1.0;
  }

  // Helper methods for multiplier calculations
  getAccuracyMultiplier(accuracy) {
    if (accuracy >= 100) return this.MULTIPLIERS.ACCURACY.PERFECT;
    if (accuracy >= 95) return this.MULTIPLIERS.ACCURACY.EXCELLENT;
    if (accuracy >= 80) return this.MULTIPLIERS.ACCURACY.GOOD;
    return this.MULTIPLIERS.ACCURACY.AVERAGE;
  }

  getStreakMultiplier(streak) {
    if (streak >= 100) return this.MULTIPLIERS.STREAK.LEGENDARY;
    if (streak >= 50) return this.MULTIPLIERS.STREAK.MASTER;
    if (streak >= 30) return this.MULTIPLIERS.STREAK.EXPERT;
    if (streak >= 14) return this.MULTIPLIERS.STREAK.ADVANCED;
    return this.MULTIPLIERS.STREAK.BEGINNER;
  }

  getFrequencyMultiplier(dailyAverage) {
    if (dailyAverage >= 10) return this.MULTIPLIERS.FREQUENCY.SUPER_ACTIVE;
    if (dailyAverage >= 5) return this.MULTIPLIERS.FREQUENCY.VERY_ACTIVE;
    if (dailyAverage >= 3) return this.MULTIPLIERS.FREQUENCY.ACTIVE;
    if (dailyAverage >= 1) return this.MULTIPLIERS.FREQUENCY.MODERATE;
    return this.MULTIPLIERS.FREQUENCY.OCCASIONAL;
  }

  getConsistencyMultiplier(consistencyScore) {
    if (consistencyScore >= 95) return this.MULTIPLIERS.CONSISTENCY.PERFECT;
    if (consistencyScore >= 80) return this.MULTIPLIERS.CONSISTENCY.EXCELLENT;
    if (consistencyScore >= 65) return this.MULTIPLIERS.CONSISTENCY.GOOD;
    return this.MULTIPLIERS.CONSISTENCY.AVERAGE;
  }

  /**
   * Anti-fraud detection for reward calculations
   * @param {Object} userActivity - User activity data
   * @param {Object} userHistory - Historical user data
   * @returns {Boolean} - Whether activity seems legitimate
   */
  validateRewardEligibility(userActivity, userHistory) {
    const { timestamp, location, confidence, sessionDuration } = userActivity;
    const { recentActivities, averageSessionTime, typicalLocations } = userHistory;

    // Check for suspicious patterns
    const suspiciousIndicators = [];

    // Too many activities in short time
    const recentCount = recentActivities.filter(
      activity => timestamp - activity.timestamp < 60000 // 1 minute
    ).length;
    if (recentCount > 5) {
      suspiciousIndicators.push('rapid_scanning');
    }

    // Session too short for claimed accuracy
    if (sessionDuration < 5000 && confidence > 0.95) { // Less than 5 seconds
      suspiciousIndicators.push('unrealistic_speed');
    }

    // Location jumping (different cities in short time)
    if (location && typicalLocations.length > 0) {
      const locationVariance = this.calculateLocationVariance(location, typicalLocations);
      if (locationVariance > 100) { // More than 100km variance
        suspiciousIndicators.push('location_jumping');
      }
    }

    // Return false if too many suspicious indicators
    return suspiciousIndicators.length < 2;
  }

  calculateLocationVariance(currentLocation, historicalLocations) {
    // Simple distance calculation (you'd use a proper geolocation library)
    // This is a simplified version for demonstration
    return 0; // Placeholder
  }
}

module.exports = RewardCalculator;
