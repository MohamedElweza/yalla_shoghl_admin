// Your existing Subscription model (as provided by you, with required endDate)
import 'package:cloud_firestore/cloud_firestore.dart';

class Subscription {
  final String plan;
  final DateTime startDate;
  final DateTime endDate;

  Subscription({
    required this.plan,
    required this.startDate,
    required this.endDate,
  });

  factory Subscription.fromMap(Map<String, dynamic> data) {
    return Subscription(
      plan: data['plan'] as String,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plan': plan,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }
}
