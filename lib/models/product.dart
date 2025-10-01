class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String? imageUrl;
  final List<String> images;
  final String category;
  final double sustainabilityScore;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final String brand;
  final List<String> tags;
  final Map<String, String> specifications;
  final bool isFeatured;
  final bool isSustainable;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.imageUrl,
    this.images = const [],
    required this.category,
    this.sustainabilityScore = 0.0,
    this.stockQuantity = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.brand = '',
    this.tags = const [],
    this.specifications = const {},
    this.isFeatured = false,
    this.isSustainable = false,
    required this.createdAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'],
      images: List<String>.from(map['images'] ?? []),
      category: map['category'] ?? '',
      sustainabilityScore: (map['sustainabilityScore'] ?? 0.0).toDouble(),
      stockQuantity: map['stockQuantity'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      brand: map['brand'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      specifications: Map<String, String>.from(map['specifications'] ?? {}),
      isFeatured: map['isFeatured'] ?? false,
      isSustainable: map['isSustainable'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'images': images,
      'category': category,
      'sustainabilityScore': sustainabilityScore,
      'stockQuantity': stockQuantity,
      'rating': rating,
      'reviewCount': reviewCount,
      'brand': brand,
      'tags': tags,
      'specifications': specifications,
      'isFeatured': isFeatured,
      'isSustainable': isSustainable,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

enum SortOption {
  priceAsc,
  priceDesc,
  nameAsc,
  nameDesc,
  ratingDesc,
  sustainabilityDesc,
  newest,
}

extension SortOptionExt on SortOption {
  String get displayName {
    switch (this) {
      case SortOption.priceAsc:
        return 'Price: Low to High';
      case SortOption.priceDesc:
        return 'Price: High to Low';
      case SortOption.nameAsc:
        return 'Name: A to Z';
      case SortOption.nameDesc:
        return 'Name: Z to A';
      case SortOption.ratingDesc:
        return 'Highest Rated';
      case SortOption.sustainabilityDesc:
        return 'Most Sustainable';
      case SortOption.newest:
        return 'Newest First';
    }
  }
}

class MarketplaceFilters {
  final String? category;
  final double? minPrice;
  final double? maxPrice;
  final double? minRating;
  final double? minSustainability;
  final List<String> tags;
  final bool inStockOnly;
  final SortOption sortBy;

  const MarketplaceFilters({
    this.category,
    this.minPrice,
    this.maxPrice,
    this.minRating,
    this.minSustainability,
    this.tags = const [],
    this.inStockOnly = false,
    this.sortBy = SortOption.newest,
  });

  MarketplaceFilters copyWith({
    String? category,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    double? minSustainability,
    List<String>? tags,
    bool? inStockOnly,
    SortOption? sortBy,
  }) {
    return MarketplaceFilters(
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      minSustainability: minSustainability ?? this.minSustainability,
      tags: tags ?? this.tags,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}
