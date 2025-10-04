import 'dart:convert';

class MenuItemModel {
  final String id;
  final String adminId;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;
  final List<String> tags;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isSpicy;
  final int preparationTimeMinutes;
  final bool isAvailable;
  final int calories;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  MenuItemModel({
    required this.id,
    required this.adminId,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    this.tags = const [],
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.isSpicy = false,
    this.preparationTimeMinutes = 15,
    this.isAvailable = true,
    this.calories = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'adminId': adminId,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'tags': tags,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'isSpicy': isSpicy,
      'preparationTimeMinutes': preparationTimeMinutes,
      'isAvailable': isAvailable,
      'calories': calories,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    final dynamic createdAtRaw = map['createdAt'];
    final dynamic updatedAtRaw = map['updatedAt'];

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (value is DateTime) return value;
      // Firestore Timestamp support without import to avoid coupling
      final String typeName = value.runtimeType.toString();
      if (typeName == 'Timestamp') {
        // Access seconds and nanoseconds dynamically
        final seconds = (value as dynamic).seconds as int?;
        final nanoseconds = (value as dynamic).nanoseconds as int?;
        final int ms =
            (seconds ?? 0) * 1000 + ((nanoseconds ?? 0) / 1e6).floor();
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
      if (value is String) {
        return DateTime.tryParse(value) ??
            DateTime.fromMillisecondsSinceEpoch(0);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return MenuItemModel(
      id: map['id'] ?? map['docId'] ?? map['menuItemId'] ?? '',
      adminId: map['adminId'] ?? map['restaurantId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: parseDouble(map['price']),
      imageUrl: map['imageUrl'],
      category: map['category'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      isVegetarian: map['isVegetarian'] ?? false,
      isVegan: map['isVegan'] ?? false,
      isGlutenFree: map['isGlutenFree'] ?? false,
      isSpicy: map['isSpicy'] ?? false,
      preparationTimeMinutes: map['preparationTimeMinutes'] ?? 15,
      isAvailable: map['isAvailable'] ?? true,
      calories: map['calories'] ?? 0,
      rating: parseDouble(map['rating']),
      reviewCount: map['reviewCount'] ?? 0,
      createdAt: parseDate(createdAtRaw),
      updatedAt: parseDate(updatedAtRaw),
    );
  }

  factory MenuItemModel.fromJson(String source) =>
      MenuItemModel.fromMap(json.decode(source));

  MenuItemModel copyWith({
    String? id,
    String? adminId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    List<String>? tags,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    bool? isSpicy,
    int? preparationTimeMinutes,
    bool? isAvailable,
    int? calories,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      isSpicy: isSpicy ?? this.isSpicy,
      preparationTimeMinutes:
          preparationTimeMinutes ?? this.preparationTimeMinutes,
      isAvailable: isAvailable ?? this.isAvailable,
      calories: calories ?? this.calories,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MenuItemModel(id: $id, name: $name, price: \$${price.toStringAsFixed(2)}, available: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MenuItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
