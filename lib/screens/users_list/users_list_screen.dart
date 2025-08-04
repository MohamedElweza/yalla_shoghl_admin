import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yalla_shogl_admin/screens/users_list/user_detail_screen.dart';
import '../../core/utils/app_colors.dart';

class UsersListScreen extends StatelessWidget {
  final bool showWorkers;

  const UsersListScreen({super.key, required this.showWorkers});

  @override
  Widget build(BuildContext context) {
    final collection = showWorkers ? 'workers' : 'users';

    final query = FirebaseFirestore.instance.collection(collection);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightGreyBackground,
        appBar: AppBar(
          title: Text(
            showWorkers ? 'قائمة العمال' : 'قائمة العملاء',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: query.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('حدث خطأ: ${snapshot.error}'));
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Text(
                  showWorkers ? 'لا يوجد عمال حالياً' : 'لا يوجد عملاء حالياً',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final id = docs[index].id;
                return _buildUserCard(context, data, id);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(
      BuildContext context, Map<String, dynamic> user, String id) {
    final name = user['name'] ?? 'بدون اسم';
    final phone = user['phone'] ?? 'غير متوفر';
    final imageUrl = user['imageUrl'] ?? '';
    final rating = double.tryParse(user['rating']?.toString() ?? '0') ?? 0.0;
    final ratingCount = user['ratingCount'] ?? 0;
    final service = user['service'] ?? 'غير محدد';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserDetailScreen(
              userId: id,
              isWorker: showWorkers,
            ),
          ),
        );
      },
      child: Container(
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
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: AppColors.lightGreyBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primaryPurple,
                  size: 40,
                ),
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phone,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (showWorkers) ...[
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('الخدمة: $service',
                        style: const TextStyle(fontSize: 12)),
                    Text('عدد التقييمات: $ratingCount',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 22, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
