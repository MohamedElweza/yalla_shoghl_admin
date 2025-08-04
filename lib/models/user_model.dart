import 'package:cloud_firestore/cloud_firestore.dart';

import 'base_user.dart';

class UserModel extends BaseUser {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.password,
    required super.type,
    required super.createdAt,
    super.profileImageUrl,
    super.favorites,
    required super.phone,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? bio,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      password: password,
      type: type,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'],
      phone: map['phone'] ?? '',
      type: map['type'] ?? 'user',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profileImageUrl: map['profileImageUrl'] ?? '',
      favorites: List<String>.from(map['favorites'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => toBaseMap();
}
