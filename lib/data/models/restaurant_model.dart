import 'dart:convert';

enum RestaurantStatus { open, closed, busy }

class RestaurantModel {
  final String id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String email;
  final String? imageUrl;
  final String? logoUrl;
  final double rating;
  final int reviewCount;
  final String adminId; // The admin who manages this restaurant
  final RestaurantStatus status;
  final List<String> categories;
  final double deliveryFee;
  final int deliveryTimeMin;
  final int deliveryTimeMax;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  RestaurantModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    this.imageUrl,
    this.logoUrl,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.adminId,
    this.status = RestaurantStatus.open,
    this.categories = const [],
    this.deliveryFee = 0.0,
    this.deliveryTimeMin = 20,
    this.deliveryTimeMax = 30,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'imageUrl': imageUrl,
      'logoUrl': logoUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'adminId': adminId,
      'status': status.name,
      'categories': categories,
      'deliveryFee': deliveryFee,
      'deliveryTimeMin': deliveryTimeMin,
      'deliveryTimeMax': deliveryTimeMax,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  String toJson() => json.encode(toMap());

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'],
      logoUrl: map['logoUrl'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      adminId: map['adminId'] ?? '',
      status: RestaurantStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => RestaurantStatus.open,
      ),
      categories: List<String>.from(map['categories'] ?? []),
      deliveryFee: (map['deliveryFee'] ?? 0.0).toDouble(),
      deliveryTimeMin: map['deliveryTimeMin'] ?? 20,
      deliveryTimeMax: map['deliveryTimeMax'] ?? 30,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isActive: map['isActive'] ?? true,
    );
  }

  factory RestaurantModel.fromJson(String source) =>
      RestaurantModel.fromMap(json.decode(source));

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? imageUrl,
    String? logoUrl,
    double? rating,
    int? reviewCount,
    String? adminId,
    RestaurantStatus? status,
    List<String>? categories,
    double? deliveryFee,
    int? deliveryTimeMin,
    int? deliveryTimeMax,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      adminId: adminId ?? this.adminId,
      status: status ?? this.status,
      categories: categories ?? this.categories,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryTimeMin: deliveryTimeMin ?? this.deliveryTimeMin,
      deliveryTimeMax: deliveryTimeMax ?? this.deliveryTimeMax,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'RestaurantModel(id: $id, name: $name, status: $status, rating: $rating)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RestaurantModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
