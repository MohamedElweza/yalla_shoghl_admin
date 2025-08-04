import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? password;
  String? type; // 'user' or 'worker'
  final DateTime createdAt;
  final String? profileImageUrl;
  final List<String> favorites;

  BaseUser({
    required this.phone,
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.type,
    required this.createdAt,
    this.profileImageUrl,
    this.favorites = const [],
  });

  Map<String, dynamic> toBaseMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'profileImageUrl': profileImageUrl,
      'favorites': favorites,
    };
  }
}
