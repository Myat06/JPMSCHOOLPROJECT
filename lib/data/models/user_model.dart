import 'dart:convert';

enum UserRole { customer, admin }

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final UserRole role;
  final DateTime createdAt;
  final bool isActive;
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.isActive = true,
    this.profileImageUrl,
  });

  // Convert UserModel to Map for local storage
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Convert to JSON string
  String toJson() => json.encode(toMap());

  // Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => UserRole.customer,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? true,
      profileImageUrl: map['profileImageUrl'],
    );
  }

  // Create UserModel from JSON string
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  // Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phone,
    UserRole? role,
    DateTime? createdAt,
    bool? isActive,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, name: $name, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
