import 'package:flutter/material.dart';
import 'package:yalla_shogl_admin/screens/admin_subscriptions/admin_subscriptions_screen.dart';
import 'package:yalla_shogl_admin/screens/users_list/users_list_screen.dart';

import '../../core/utils/app_colors.dart';

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
                title: 'عمال',
                icon: Icons.engineering,
                color: Colors.teal,
                onTap: () {
                  _navigateTo(context, const UsersListScreen(showWorkers: true));
                },
              ),
              _AdminOptionCard(
                title: 'العملاء (البريد الشخصي)',
                icon: Icons.person_outline,
                color: Colors.deepPurple,
                onTap: () {
                  _navigateTo(context, const UsersListScreen(showWorkers: false));
                },
              ),
              _AdminOptionCard(
                title: 'الاشتراكات',
                icon: Icons.campaign,
                color: Colors.orangeAccent,
                onTap: () {
                  _navigateTo(context, const AdminSubscriptionsScreen());
                },
              ),
              _AdminOptionCard(
                title: 'الإعلانات',
                icon: Icons.people,
                color: Colors.green,
                onTap: () {
                  // TODO: Replace with UsersAdminScreen
                  // _navigateTo(context, AdsScreen());
                },
              ),
              _AdminOptionCard(
                title: 'الخدمات',
                icon: Icons.design_services,
                color: Colors.blue,
                onTap: () {
                  // TODO: Replace with UsersAdminScreen
                  // _navigateTo(context, AdsScreen());
                },
              ),
              _AdminOptionCard(
                title: 'الطلبات المنتظرة',
                icon: Icons.design_services,
                color: Colors.brown,
                onTap: () {
                  // TODO: Replace with UsersAdminScreen
                  // _navigateTo(context, AdsScreen());
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
