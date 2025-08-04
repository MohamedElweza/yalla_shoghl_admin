class ServiceWorker {
  final String id;
  final String name;
  final String service;
  final String phone;
  final String imageUrl;
  final double rating;
  final int ratingCount;

  ServiceWorker({
    required this.id,
    required this.name,
    required this.service,
    required this.phone,
    required this.imageUrl,
    required this.rating,
    required this.ratingCount,
  });

  factory ServiceWorker.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceWorker(
      id: documentId,
      name: map['name'] ?? '',
      service: map['service'] ?? '',
      phone: map['phone'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'service': service,
      'phone': phone,
      'imageUrl': imageUrl,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }
}
