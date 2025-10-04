import 'dart:convert';
import 'menu_item_model.dart';

enum FavoriteType { restaurant, menuItem }

class FavoriteItemModel {
  final String id;
  final FavoriteType type;
  final String name;
  final String
  subtitle; // Restaurant name for menu items, cuisine type for restaurants
  final double rating;
  final DateTime addedAt;

  // For restaurants
  final String? adminId;
  final String? adminName;
  final List<String>? categories;
  final String? deliveryTime;
  final double? deliveryFee;

  // For menu items
  final MenuItemModel? menuItem;
  final String? adminIdForMenuItem;

  FavoriteItemModel({
    required this.id,
    required this.type,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.addedAt,
    this.adminId,
    this.adminName,
    this.categories,
    this.deliveryTime,
    this.deliveryFee,
    this.menuItem,
    this.adminIdForMenuItem,
  });

  // Factory constructor for restaurant favorites
  factory FavoriteItemModel.restaurant({
    required String id,
    required String name,
    required String subtitle,
    required double rating,
    required String adminId,
    required String adminName,
    List<String>? categories,
    String? deliveryTime,
    double? deliveryFee,
  }) {
    return FavoriteItemModel(
      id: id,
      type: FavoriteType.restaurant,
      name: name,
      subtitle: subtitle,
      rating: rating,
      addedAt: DateTime.now(),
      adminId: adminId,
      adminName: adminName,
      categories: categories,
      deliveryTime: deliveryTime,
      deliveryFee: deliveryFee,
    );
  }

  // Factory constructor for menu item favorites
  factory FavoriteItemModel.menuItem({
    required String id,
    required MenuItemModel menuItem,
    required String restaurantId,
    required String restaurantName,
    required double rating,
  }) {
    return FavoriteItemModel(
      id: id,
      type: FavoriteType.menuItem,
      name: menuItem.name,
      subtitle: restaurantName,
      rating: rating,
      addedAt: DateTime.now(),
      menuItem: menuItem,
      adminIdForMenuItem: menuItem.adminId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'name': name,
      'subtitle': subtitle,
      'rating': rating,
      'addedAt': addedAt.toIso8601String(),
      'adminId': adminId,
      'adminName': adminName,
      'categories': categories,
      'deliveryTime': deliveryTime,
      'deliveryFee': deliveryFee,
      'menuItem': menuItem?.toMap(),
      'menuItemAdminId': adminIdForMenuItem,
    };
  }

  String toJson() => json.encode(toMap());

  factory FavoriteItemModel.fromMap(Map<String, dynamic> map) {
    return FavoriteItemModel(
      id: map['id'] ?? '',
      type: FavoriteType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => FavoriteType.menuItem,
      ),
      name: map['name'] ?? '',
      subtitle: map['subtitle'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      addedAt: DateTime.parse(map['addedAt']),
      adminId: map['adminId'],
      adminName: map['adminName'],
      categories: map['categories'] != null
          ? List<String>.from(map['categories'])
          : null,
      deliveryTime: map['deliveryTime'],
      deliveryFee: map['deliveryFee']?.toDouble(),
      menuItem: map['menuItem'] != null
          ? MenuItemModel.fromMap(map['menuItem'])
          : null,
      adminIdForMenuItem: map['menuItemAdminId'] ?? map['restaurantId'],
    );
  }

  factory FavoriteItemModel.fromJson(String source) =>
      FavoriteItemModel.fromMap(json.decode(source));

  FavoriteItemModel copyWith({
    String? id,
    FavoriteType? type,
    String? name,
    String? subtitle,
    double? rating,
    DateTime? addedAt,
    String? adminId,
    String? adminName,
    List<String>? categories,
    String? deliveryTime,
    double? deliveryFee,
    MenuItemModel? menuItem,
    String? adminIdForMenuItem,
  }) {
    return FavoriteItemModel(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      rating: rating ?? this.rating,
      addedAt: addedAt ?? this.addedAt,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      categories: categories ?? this.categories,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      menuItem: menuItem ?? this.menuItem,
      adminIdForMenuItem: adminIdForMenuItem ?? this.adminIdForMenuItem,
    );
  }

  @override
  String toString() {
    return 'FavoriteItemModel(id: $id, type: $type, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FavoriteItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
