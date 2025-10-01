class TokenReward {
  final String id;
  final String userId;
  final String activityType;
  final double tokenAmount;
  final DateTime earnedAt;
  final String description;
  final RewardCategory category;
  final Map<String, dynamic> metadata;

  TokenReward({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.tokenAmount,
    required this.earnedAt,
    required this.description,
    required this.category,
    this.metadata = const {},
  });

  factory TokenReward.fromJson(Map<String, dynamic> json) {
    return TokenReward(
      id: json['id'],
      userId: json['userId'],
      activityType: json['activityType'],
      tokenAmount: json['tokenAmount'].toDouble(),
      earnedAt: DateTime.parse(json['earnedAt']),
      description: json['description'],
      category: RewardCategory.values.firstWhere(
        (e) => e.toString() == 'RewardCategory.${json['category']}',
        orElse: () => RewardCategory.recycling,
      ),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'activityType': activityType,
      'tokenAmount': tokenAmount,
      'earnedAt': earnedAt.toIso8601String(),
      'description': description,
      'category': category.toString().split('.').last,
      'metadata': metadata,
    };
  }
}

enum RewardCategory {
  recycling,
  streak,
  milestone,
  accuracy,
  community,
  education,
  referral,
}

class RecyclingActivity {
  final String id;
  final String userId;
  final String itemType;
  final String classification;
  final bool isCorrect;
  final double confidence;
  final DateTime timestamp;
  final String? imageUrl;
  final String location;
  final Map<String, dynamic> metadata;

  RecyclingActivity({
    required this.id,
    required this.userId,
    required this.itemType,
    required this.classification,
    required this.isCorrect,
    required this.confidence,
    required this.timestamp,
    this.imageUrl,
    required this.location,
    this.metadata = const {},
  });

  factory RecyclingActivity.fromJson(Map<String, dynamic> json) {
    return RecyclingActivity(
      id: json['id'],
      userId: json['userId'],
      itemType: json['itemType'],
      classification: json['classification'],
      isCorrect: json['isCorrect'],
      confidence: json['confidence'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'],
      location: json['location'],
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'itemType': itemType,
      'classification': classification,
      'isCorrect': isCorrect,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
      'location': location,
      'metadata': metadata,
    };
  }
}

class UserStats {
  final String userId;
  final int totalRecyclingCount;
  final int correctClassifications;
  final int currentStreak;
  final int longestStreak;
  final double averageAccuracy;
  final double totalTokensEarned;
  final double currentTokenBalance;
  final DateTime lastActivity;
  final Map<String, int> itemTypeCounts;
  final List<Achievement> achievements;

  UserStats({
    required this.userId,
    required this.totalRecyclingCount,
    required this.correctClassifications,
    required this.currentStreak,
    required this.longestStreak,
    required this.averageAccuracy,
    required this.totalTokensEarned,
    required this.currentTokenBalance,
    required this.lastActivity,
    required this.itemTypeCounts,
    required this.achievements,
  });

  double get accuracyPercentage => 
      totalRecyclingCount > 0 ? (correctClassifications / totalRecyclingCount) * 100 : 0;

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'],
      totalRecyclingCount: json['totalRecyclingCount'],
      correctClassifications: json['correctClassifications'],
      currentStreak: json['currentStreak'],
      longestStreak: json['longestStreak'],
      averageAccuracy: json['averageAccuracy'].toDouble(),
      totalTokensEarned: json['totalTokensEarned'].toDouble(),
      currentTokenBalance: json['currentTokenBalance'].toDouble(),
      lastActivity: DateTime.parse(json['lastActivity']),
      itemTypeCounts: Map<String, int>.from(json['itemTypeCounts']),
      achievements: (json['achievements'] as List)
          .map((a) => Achievement.fromJson(a))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalRecyclingCount': totalRecyclingCount,
      'correctClassifications': correctClassifications,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'averageAccuracy': averageAccuracy,
      'totalTokensEarned': totalTokensEarned,
      'currentTokenBalance': currentTokenBalance,
      'lastActivity': lastActivity.toIso8601String(),
      'itemTypeCounts': itemTypeCounts,
      'achievements': achievements.map((a) => a.toJson()).toList(),
    };
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final double tokenReward;
  final DateTime unlockedAt;
  final AchievementType type;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.tokenReward,
    required this.unlockedAt,
    required this.type,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      tokenReward: json['tokenReward'].toDouble(),
      unlockedAt: DateTime.parse(json['unlockedAt']),
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == 'AchievementType.${json['type']}',
        orElse: () => AchievementType.recycling,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconUrl': iconUrl,
      'tokenReward': tokenReward,
      'unlockedAt': unlockedAt.toIso8601String(),
      'type': type.toString().split('.').last,
    };
  }
}

enum AchievementType {
  recycling,
  streak,
  accuracy,
  milestone,
  community,
  learning,
}
