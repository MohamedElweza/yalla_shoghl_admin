import 'package:flutter/material.dart';

class ServiceModel {
  final String id;
  final String name;
  final String price;
  final String description;
  final bool isActive;
  final List<String> galleryImages; // Ensure this is List<String>

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.isActive,
    this.galleryImages = const [], // Provide default empty list
  });

  factory ServiceModel.fromMap(Map<String, dynamic> data) {
    try {
      // Handle galleryImages conversion safely
      final galleryImages =
          (data['galleryImages'] as List<dynamic>?)?.map((e) {
            return e?.toString() ?? ''; // Convert each item to string
          }).toList() ??
          []; // Fallback to empty list

      return ServiceModel(
        id: data['id']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        price: data['price']?.toString() ?? '0',
        description: data['description']?.toString() ?? '',
        isActive: data['isActive'] ?? true,
        galleryImages: galleryImages,
      );
    } catch (e) {
      debugPrint('Error creating ServiceModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'isActive': isActive,
      'createdAt': DateTime.now().toIso8601String(),
      'galleryImages': galleryImages, // Already List<String>
    };
  }
}
