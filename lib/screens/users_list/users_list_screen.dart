import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_colors.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  final List<Map<String, String>> users = const [
    {
      'name': 'أحمد محمد',
      'email': 'ahmed@example.com',
      'type': 'مشترك شهري',
    },
    {
      'name': 'منى علي',
      'email': 'mona@example.com',
      'type': 'مشترك سنوي',
    },
    {
      'name': 'خالد حسن',
      'email': 'khaled@example.com',
      'type': 'مجاني',
    },
    {
      'name': 'سارة عبد الله',
      'email': 'sara@example.com',
      'type': 'مشترك شهري',
    },
  ];

  Widget _buildUserCard(BuildContext context, Map<String, String> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 80,
              width: 80,
              color: AppColors.lightGreyBackground,
              child: const Icon(
                Icons.person,
                color: AppColors.primaryPurple,
                size: 40,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user['email'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user['type'] ?? '',
                    style: const TextStyle(
                      color: AppColors.primaryPurple,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 22,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightGreyBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'قائمة المستخدمين',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: Container(),
          actions: [
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                // Navigate to add user screen
                Navigator.pop(context );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return _buildUserCard(context, users[index]);
            },
          ),
        ),
      ),
    );
  }
}
