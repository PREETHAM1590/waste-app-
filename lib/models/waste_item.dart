class WasteItem {
  final String id;
  final String name;
  final String category;
  final double confidence;
  final String disposalInstructions;
  final List<String> tips;
  final bool recyclable;
  final int points;
  final String? imageUrl;
  final DateTime? timestamp;

  const WasteItem({
    required this.id,
    required this.name,
    required this.category,
    required this.confidence,
    required this.disposalInstructions,
    required this.tips,
    required this.recyclable,
    required this.points,
    this.imageUrl,
    this.timestamp,
  });

  /// Create WasteItem from JSON
  factory WasteItem.fromJson(Map<String, dynamic> json) {
    return WasteItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      disposalInstructions: json['disposalInstructions'] as String,
      tips: List<String>.from(json['tips'] as List),
      recyclable: json['recyclable'] as bool,
      points: json['points'] as int,
      imageUrl: json['imageUrl'] as String?,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  /// Convert WasteItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'confidence': confidence,
      'disposalInstructions': disposalInstructions,
      'tips': tips,
      'recyclable': recyclable,
      'points': points,
      'imageUrl': imageUrl,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  /// Create a copy of this WasteItem with some properties replaced
  WasteItem copyWith({
    String? id,
    String? name,
    String? category,
    double? confidence,
    String? disposalInstructions,
    List<String>? tips,
    bool? recyclable,
    int? points,
    String? imageUrl,
    DateTime? timestamp,
  }) {
    return WasteItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      disposalInstructions: disposalInstructions ?? this.disposalInstructions,
      tips: tips ?? this.tips,
      recyclable: recyclable ?? this.recyclable,
      points: points ?? this.points,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is WasteItem &&
        other.id == id &&
        other.name == name &&
        other.category == category &&
        other.confidence == confidence &&
        other.disposalInstructions == disposalInstructions &&
        other.recyclable == recyclable &&
        other.points == points &&
        other.imageUrl == imageUrl &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      category,
      confidence,
      disposalInstructions,
      recyclable,
      points,
      imageUrl,
      timestamp,
    );
  }

  @override
  String toString() {
    return 'WasteItem(id: $id, name: $name, category: $category, confidence: $confidence, recyclable: $recyclable, points: $points)';
  }
}
