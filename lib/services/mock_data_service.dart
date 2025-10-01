import 'dart:async';
import 'dart:math';

/// Mock chat service for WiseBot interactions
class ChatService {
  static const List<String> _mockResponses = [
    "That's a great question about recycling! Let me help you with that.",
    "Based on the image you shared, this item should go in the recyclable bin.",
    "Did you know that recycling aluminum cans saves 95% of the energy needed to make new ones?",
    "Here are some eco-friendly tips for your daily routine...",
    "Great job on maintaining your recycling streak! Keep it up!",
    "I can help you find nearby recycling centers. What's your location?",
    "That's not recyclable in most areas, but you can check with your local facility.",
    "Composting is a great way to reduce organic waste. Would you like some tips?",
  ];

  static const List<Map<String, String>> _quickActions = [
    {"text": "How to recycle plastic?", "action": "recycle_plastic"},
    {"text": "Find recycling centers", "action": "find_centers"},
    {"text": "Environmental tips", "action": "eco_tips"},
    {"text": "Check recycling guidelines", "action": "guidelines"},
  ];

  /// Send a message to the chatbot
  Future<Map<String, dynamic>> sendMessage(String message) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
    
    final random = Random();
    final response = _mockResponses[random.nextInt(_mockResponses.length)];
    
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'response': response,
      'timestamp': DateTime.now(),
      'quickActions': _quickActions.take(2).toList(),
    };
  }

  /// Get quick action suggestions
  List<Map<String, String>> getQuickActions() {
    return _quickActions;
  }

  /// Handle quick action tap
  Future<Map<String, dynamic>> handleQuickAction(String actionType) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    switch (actionType) {
      case 'recycle_plastic':
        return {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'response': 'Plastic recycling depends on the type. Look for recycling codes 1-7. Most bottles and containers with codes 1,2,4,5 are widely accepted.',
          'timestamp': DateTime.now(),
        };
      case 'find_centers':
        return {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'response': 'I can help you find recycling centers near you. Please share your location or zip code.',
          'timestamp': DateTime.now(),
        };
      case 'eco_tips':
        return {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'response': 'Here are today\'s eco tips: 1) Use reusable bags, 2) Reduce single-use plastics, 3) Compost organic waste, 4) Choose products with minimal packaging.',
          'timestamp': DateTime.now(),
        };
      case 'guidelines':
        return {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'response': 'Check our recycling guidelines section for detailed information about what can and cannot be recycled in your area.',
          'timestamp': DateTime.now(),
        };
      default:
        return sendMessage('Tell me more about $actionType');
    }
  }
}

/// Mock marketplace service for buying/selling recyclables  
class MarketplaceService {
  static final List<Map<String, dynamic>> _mockItems = [
    {
      'id': '1',
      'title': 'Eco-Friendly Bamboo Water Bottle',
      'description': 'Sustainable bamboo water bottle with stainless steel interior. Perfect for reducing plastic waste on the go. Features temperature retention and eco-friendly materials.',
      'price': 29.99,
      'category': 'bottles',
      'brand': 'GreenLife',
      'rating': 4.8,
      'reviewCount': 124,
      'sustainabilityScore': 95,
      'stockQuantity': 25,
      'images': [],
      'tags': ['bamboo', 'sustainable', 'BPA-free', 'insulated'],
      'specifications': {
        'Material': 'Bamboo exterior, stainless steel interior',
        'Capacity': '500ml',
        'Weight': '280g',
        'Temperature retention': '12 hours hot, 24 hours cold'
      },
      'isFeatured': true,
      'isSustainable': true,
      'createdAt': '2024-01-15T10:00:00Z'
    },
    {
      'id': '2', 
      'title': 'Organic Cotton Reusable Shopping Bags',
      'description': 'Set of 3 premium organic cotton shopping bags. Durable, washable, and perfect for groceries. Help eliminate single-use plastic bags.',
      'price': 24.50,
      'category': 'bags',
      'brand': 'EcoCarry',
      'rating': 4.6,
      'reviewCount': 89,
      'sustainabilityScore': 88,
      'stockQuantity': 42,
      'images': [],
      'tags': ['organic cotton', 'reusable', 'washable', 'durable'],
      'specifications': {
        'Material': '100% Organic Cotton',
        'Size': 'Large (40x35cm)',
        'Weight capacity': '15kg per bag',
        'Care': 'Machine washable'
      },
      'isFeatured': false,
      'isSustainable': true,
      'createdAt': '2024-01-10T14:30:00Z'
    },
    {
      'id': '3',
      'title': 'Compost Bin Starter Kit',
      'description': 'Complete composting starter kit with aerated bin, thermometer, and organic activator. Transform kitchen scraps into nutrient-rich soil.',
      'price': 89.00,
      'category': 'composting',
      'brand': 'CompostMaster',
      'rating': 4.9,
      'reviewCount': 67,
      'sustainabilityScore': 92,
      'stockQuantity': 15,
      'images': [],
      'tags': ['composting', 'organic', 'garden', 'waste-reduction'],
      'specifications': {
        'Capacity': '80 liters',
        'Material': 'Recycled plastic',
        'Dimensions': '60x60x83cm',
        'Features': 'Aeration system, thermometer included'
      },
      'isFeatured': true,
      'isSustainable': true,
      'createdAt': '2024-01-08T09:15:00Z'
    },
    {
      'id': '4',
      'title': 'Solar-Powered LED Lantern',
      'description': 'Rechargeable solar lantern with USB charging port. Perfect for camping, emergencies, or outdoor activities. Zero-emission lighting solution.',
      'price': 45.75,
      'category': 'lighting',
      'brand': 'SolarTech',
      'rating': 4.4,
      'reviewCount': 156,
      'sustainabilityScore': 90,
      'stockQuantity': 0, // Out of stock
      'images': [],
      'tags': ['solar-powered', 'LED', 'portable', 'emergency'],
      'specifications': {
        'Battery': 'Lithium-ion 2000mAh',
        'Charging': 'Solar panel + USB',
        'Runtime': '10-50 hours',
        'Brightness': '400 lumens max'
      },
      'isFeatured': false,
      'isSustainable': true,
      'createdAt': '2024-01-05T16:45:00Z'
    },
    {
      'id': '5',
      'title': 'Beeswax Food Wraps Set',
      'description': 'Plastic-free food storage solution. Set of 6 different sizes made from organic cotton and beeswax. Reusable for up to a year.',
      'price': 32.99,
      'category': 'food-storage',
      'brand': 'BeeWrap Co',
      'rating': 4.7,
      'reviewCount': 203,
      'sustainabilityScore': 94,
      'stockQuantity': 38,
      'images': [],
      'tags': ['beeswax', 'plastic-free', 'organic', 'reusable'],
      'specifications': {
        'Material': 'Organic cotton, beeswax, jojoba oil',
        'Sizes included': 'Small (7x8"), Medium (10x11"), Large (13x14")',
        'Lifespan': '1 year with proper care',
        'Care': 'Cold water wash, air dry'
      },
      'isFeatured': false,
      'isSustainable': true,
      'createdAt': '2024-01-03T11:20:00Z'
    },
  ];

  static const List<String> _categories = [
    'all',
    'bottles',
    'bags',
    'composting',
    'lighting',
    'food-storage',
    'cleaning',
    'electronics',
  ];

  /// Get marketplace items with optional filters
  Future<List<Map<String, dynamic>>> getItems({
    String category = 'all',
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? minSustainability,
    String? searchQuery,
    List<String> tags = const [],
    bool inStockOnly = false,
    String sortBy = 'newest',
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    var items = List<Map<String, dynamic>>.from(_mockItems);
    
    // Filter by stock availability
    if (inStockOnly) {
      items = items.where((item) => (item['stockQuantity'] ?? 0) > 0).toList();
    }
    
    // Filter by category
    if (category != 'all') {
      items = items.where((item) => item['category'] == category).toList();
    }
    
    // Filter by price range
    if (minPrice != null) {
      items = items.where((item) => (item['price'] ?? 0) >= minPrice).toList();
    }
    if (maxPrice != null) {
      items = items.where((item) => (item['price'] ?? 0) <= maxPrice).toList();
    }
    
    // Filter by rating
    if (minRating != null) {
      items = items.where((item) => (item['rating'] ?? 0) >= minRating).toList();
    }
    
    // Filter by sustainability score
    if (minSustainability != null) {
      items = items.where((item) => (item['sustainabilityScore'] ?? 0) >= minSustainability).toList();
    }
    
    // Filter by tags
    if (tags.isNotEmpty) {
      items = items.where((item) {
        final itemTags = List<String>.from(item['tags'] ?? []);
        return tags.any((tag) => itemTags.contains(tag));
      }).toList();
    }
    
    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      items = items.where((item) {
        final query = searchQuery.toLowerCase();
        return (item['title'] ?? '').toLowerCase().contains(query) ||
               (item['description'] ?? '').toLowerCase().contains(query) ||
               (item['brand'] ?? '').toLowerCase().contains(query) ||
               (item['tags'] ?? []).any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    }
    
    // Sort items
    items.sort((a, b) {
      switch (sortBy) {
        case 'price_asc':
          return (a['price'] ?? 0).compareTo(b['price'] ?? 0);
        case 'price_desc':
          return (b['price'] ?? 0).compareTo(a['price'] ?? 0);
        case 'name_asc':
          return (a['title'] ?? '').compareTo(b['title'] ?? '');
        case 'name_desc':
          return (b['title'] ?? '').compareTo(a['title'] ?? '');
        case 'rating_desc':
          return (b['rating'] ?? 0).compareTo(a['rating'] ?? 0);
        case 'sustainability_desc':
          return (b['sustainabilityScore'] ?? 0).compareTo(a['sustainabilityScore'] ?? 0);
        case 'newest':
        default:
          final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(2020);
          final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(2020);
          return bDate.compareTo(aDate);
      }
    });
    
    // Implement pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= items.length) {
      return [];
    }
    
    return items.sublist(
      startIndex,
      endIndex > items.length ? items.length : endIndex,
    );
  }

  /// Get available categories
  List<String> getCategories() {
    return _categories;
  }

  /// Create a new marketplace listing
  Future<bool> createListing(Map<String, dynamic> itemData) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful creation
    return true;
  }

  /// Purchase an item
  Future<Map<String, dynamic>> purchaseItem(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    return {
      'success': true,
      'transactionId': 'txn_${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Purchase successful! Seller will contact you soon.',
    };
  }
}

/// Mock scan service for waste classification
class ScanService {
  static final List<Map<String, dynamic>> _mockClassifications = [
    {
      'category': 'Plastic Bottle',
      'confidence': 0.95,
      'recyclable': true,
      'recyclingInstructions': 'Remove cap and rinse before recycling. Check recycling code - PET (#1) bottles are widely accepted.',
      'ecoPoints': 10,
      'environmentalImpact': 'Recycling this plastic bottle saves energy and reduces landfill waste.',
      'alternativeUses': ['Storage container', 'Plant pot', 'Bird feeder'],
      'carbonSaved': 0.8, // kg CO2
    },
    {
      'category': 'Aluminum Can',
      'confidence': 0.92,
      'recyclable': true,
      'recyclingInstructions': 'Rinse can and place in aluminum recycling bin. No need to remove labels.',
      'ecoPoints': 15,
      'environmentalImpact': 'Aluminum recycling saves 95% of energy compared to making new aluminum.',
      'alternativeUses': ['Small planter', 'Pencil holder', 'Lantern'],
      'carbonSaved': 1.2, // kg CO2
    },
    {
      'category': 'Cardboard Box',
      'confidence': 0.88,
      'recyclable': true,
      'recyclingInstructions': 'Remove tape and staples. Flatten box and place in cardboard recycling.',
      'ecoPoints': 8,
      'environmentalImpact': 'Recycling cardboard reduces deforestation and saves water.',
      'alternativeUses': ['Storage', 'Moving box', 'Art supplies'],
      'carbonSaved': 0.5, // kg CO2
    },
    {
      'category': 'Food Container',
      'confidence': 0.78,
      'recyclable': false,
      'recyclingInstructions': 'This type of container is not recyclable. Consider reusing or dispose in regular trash.',
      'ecoPoints': 2,
      'environmentalImpact': 'Consider switching to reusable containers to reduce waste.',
      'alternativeUses': ['Food storage', 'Small organizer', 'Seedling starter'],
      'carbonSaved': 0.0, // kg CO2
    },
  ];

  /// Classify waste from image (mock implementation)
  Future<Map<String, dynamic>> classifyWaste({String? imagePath}) async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate processing time
    
    final random = Random();
    final classification = _mockClassifications[random.nextInt(_mockClassifications.length)];
    
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'timestamp': DateTime.now(),
      'classification': classification,
      'processingTime': '1.8s',
    };
  }

  /// Get scan history
  Future<List<Map<String, dynamic>>> getScanHistory() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    // Mock scan history
    return List.generate(10, (index) => {
      'id': 'scan_$index',
      'timestamp': DateTime.now().subtract(Duration(days: index)),
      'category': _mockClassifications[index % _mockClassifications.length]['category'],
      'recyclable': _mockClassifications[index % _mockClassifications.length]['recyclable'],
      'ecoPoints': _mockClassifications[index % _mockClassifications.length]['ecoPoints'],
    });
  }
}

/// Mock user data service for profile and achievements
class UserDataService {
  /// Get user achievements
  Future<List<Map<String, dynamic>>> getAchievements() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      {
        'id': 'first_scan',
        'title': 'First Scanner',
        'description': 'Complete your first waste scan',
        'icon': '🔍',
        'unlocked': true,
        'unlockedAt': DateTime.now().subtract(const Duration(days: 10)),
        'ecoPoints': 50,
      },
      {
        'id': 'recycler_champion',
        'title': 'Recycling Champion',
        'description': 'Recycle 50 items',
        'icon': '♻️',
        'unlocked': true,
        'unlockedAt': DateTime.now().subtract(const Duration(days: 5)),
        'ecoPoints': 200,
      },
      {
        'id': 'eco_warrior',
        'title': 'Eco Warrior',
        'description': 'Save 10kg of CO2 through recycling',
        'icon': '🌱',
        'unlocked': false,
        'progress': 0.7,
        'ecoPoints': 500,
      },
      {
        'id': 'streak_master',
        'title': 'Streak Master',
        'description': 'Maintain a 30-day recycling streak',
        'icon': '🔥',
        'unlocked': false,
        'progress': 0.5,
        'ecoPoints': 300,
      },
    ];
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    return {
      'totalScans': 127,
      'recycledItems': 95,
      'carbonSaved': 47.8,
      'ecoPointsEarned': 1250,
      'currentStreak': 15,
      'longestStreak': 28,
      'level': 5,
      'nextLevelProgress': 0.65,
      'weeklyStats': [
        {'day': 'Mon', 'scans': 3, 'points': 45},
        {'day': 'Tue', 'scans': 2, 'points': 30},
        {'day': 'Wed', 'scans': 4, 'points': 60},
        {'day': 'Thu', 'scans': 1, 'points': 15},
        {'day': 'Fri', 'scans': 3, 'points': 45},
        {'day': 'Sat', 'scans': 5, 'points': 75},
        {'day': 'Sun', 'scans': 2, 'points': 30},
      ],
    };
  }
}
