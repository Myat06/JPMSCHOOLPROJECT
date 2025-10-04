import 'dart:convert';
import 'menu_item_model.dart';

class CartItemModel {
  final String id;
  final MenuItemModel menuItem;
  int quantity;
  final String? specialInstructions;
  final DateTime addedAt;

  CartItemModel({
    required this.id,
    required this.menuItem,
    required this.quantity,
    this.specialInstructions,
    required this.addedAt,
  });

  double get totalPrice => menuItem.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menuItem': menuItem.toMap(),
      'quantity': quantity,
      'specialInstructions': specialInstructions,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] ?? '',
      menuItem: MenuItemModel.fromMap(map['menuItem']),
      quantity: map['quantity'] ?? 1,
      specialInstructions: map['specialInstructions'],
      addedAt: DateTime.parse(map['addedAt']),
    );
  }

  factory CartItemModel.fromJson(String source) =>
      CartItemModel.fromMap(json.decode(source));

  CartItemModel copyWith({
    String? id,
    MenuItemModel? menuItem,
    int? quantity,
    String? specialInstructions,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  String toString() {
    return 'CartItemModel(id: $id, item: ${menuItem.name}, quantity: $quantity, total: \${totalPrice.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItemModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
