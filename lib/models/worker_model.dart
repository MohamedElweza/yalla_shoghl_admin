import 'base_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'subscription.dart';
import 'service_model.dart';

class WorkerModel extends BaseUser {
  final double rating;
  final Subscription? subscription;
  final String bio;
  final String governorateName;
  final String cityName;
  final List<ServiceModel> services;


  WorkerModel({
    required super.id,
    required super.name,
    required super.email,
    super.password,
    required super.phone,
    required super.type,
    required super.createdAt,
    super.profileImageUrl,
    super.favorites,
    this.rating = 0.0,
    this.subscription,
    this.bio = '',
    this.governorateName = '',
    this.cityName = '',
    this.services = const [],
  });

  factory WorkerModel.fromMap(Map<String, dynamic> data, String id) {
    // Handle favorites list conversion safely
    final List<String> favorites = data['favorites'] is List
        ? List<String>.from(
            (data['favorites'] as List).map((e) => e.toString()),
          )
        : [];

    // Handle services list conversion safely
    final services =
        (data['services'] as List<dynamic>?)?.map((serviceData) {
          if (serviceData is Map<String, dynamic>) {
            return ServiceModel.fromMap(serviceData);
          }
          return ServiceModel(
            id: '',
            name: 'Unknown Service',
            price: '0',
            description: '',
            isActive: true,
          );
        }).toList() ??
        <ServiceModel>[];


    return WorkerModel(
      id: id,
      name: data['name']?.toString() ?? 'Unknown Worker',
      email: data['email']?.toString() ?? '',
      password: data['password']?.toString(),
      type: data['type']?.toString() ?? 'worker',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profileImageUrl: data['profileImageUrl']?.toString(),
      favorites: favorites,
      rating: (data['rating'] as double?) ?? 0.0,
      subscription: data['subscription'] is Map<String, dynamic>
          ? Subscription.fromMap(data['subscription'] as Map<String, dynamic>)
          : null,
      bio: data['bio']?.toString() ?? '',
      governorateName: data['governorateName']?.toString() ?? '',
      cityName: data['cityName']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      services: services,
    );
  }

  Map<String, dynamic> toMap() {
    final base = toBaseMap();
    base.addAll({
      'rating': rating,
      'subscription': subscription?.toMap(),
      'bio': bio,
      'governorateName': governorateName,
      'cityName': cityName,
      'phone': phone,
      'services': services.map((e) => e.toFirestore()).toList(),
    });
    return base;
  }
}
