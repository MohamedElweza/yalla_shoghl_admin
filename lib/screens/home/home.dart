import 'package:flutter/material.dart';
import 'package:yalla_shogl_admin/screens/admin_subscriptions/admin_subscriptions_screen.dart';
import 'package:yalla_shogl_admin/screens/users_list/users_list_screen.dart';

import '../../core/utils/app_colors.dart';
import '../services/services_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality( // To support RTL for Arabic
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('لوحة تحكم المدير', style: TextStyle(fontSize: 20, color: Colors.white)),
          backgroundColor: AppColors.primaryPurple,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _AdminOptionCard(
                title: 'الخدمات',
                icon: Icons.design_services,
                color: Colors.blueAccent,
                onTap: () {
                  // TODO: Replace with ServicesAdminScreen
                  _navigateTo(context, const ServicesScreen());
                },
              ),
              _AdminOptionCard(
                title: 'الإعلانات',
                icon: Icons.people,
                color: Colors.green,
                onTap: () {
                  // TODO: Replace with UsersAdminScreen
                  _navigateTo(context, UsersScreen());
                },
              ),
              _AdminOptionCard(
                title: 'الاشتراكات',
                icon: Icons.campaign,
                color: Colors.orangeAccent,
                onTap: () {
                  // TODO: Replace with AdsAdminScreen
                  _navigateTo(context, const AdminSubscriptionsScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminOptionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Temporary placeholder for navigation
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(title), backgroundColor: AppColors.primaryPurple),
        body: Center(child: Text('شاشة $title قيد التطوير')),
      ),
    );
  }
}
