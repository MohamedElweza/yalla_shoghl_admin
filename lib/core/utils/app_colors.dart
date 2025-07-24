import 'package:flutter/material.dart';

class AppColors {
  static const Color mainColor = Color(0xFF6A06F5);
  static const Color accentPurple = Color(0xFF8A2BE2);
  static const Color darkText = Colors.black;
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white30 = Colors.white30;
  static const Color lightGreyBackground = Color(0xFFF5F5F5);
  static const Color borderColor = Colors.grey;
  static const Color starColor = Colors.amber;
  
  static const Color primaryPurple = Color(0xFF9C27B0); // Darker purple
  static const Color deepPurple = Color(0xFF673AB7);
  static const Color lightGrey = Color(0xFFF5F5F5); // Colors.grey[100]
  static const Color darkGrey = Color(0xFF616161); // Colors.grey[600]
  static const Color amberStar = Color(0xFFFFC107); // Colors.amber
  static const Color redError = Color(0xFFF44336); // Colors.red
  static const Color greenSuccess = Color(0xFF4CAF50); // Colors.green
  static const Color blueInfo = Color(0xFF2196F3); // Colors.blue
  static const Color orangeWarning = Color(0xFFFF9800); // Colors.orange

  static const BoxShadow cardShadow = BoxShadow(
    color: Color.fromARGB(25, 0, 0, 0), // grey.withOpacity(0.1)
    blurRadius: 10,
    spreadRadius: 1,
  );
}
