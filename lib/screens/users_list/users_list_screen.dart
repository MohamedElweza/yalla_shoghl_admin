import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yalla_shogl_admin/screens/users_list/user_detail_screen.dart';
import '../../core/utils/app_colors.dart';

class UsersListScreen extends StatefulWidget {
  final bool showWorkers;

  const UsersListScreen({super.key, required this.showWorkers});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final collection = widget.showWorkers ? 'workers' : 'users';
    final query = FirebaseFirestore.instance.collection(collection);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightGreyBackground,
        appBar: AppBar(
          title: Text(
            widget.showWorkers ? 'قائمة العمال' : 'قائمة العملاء',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim();
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: query.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('حدث خطأ: ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];
                  // فلترة حسب الاسم
                  final filteredDocs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString();
                    return name.contains(searchQuery) || name.toLowerCase().contains(searchQuery.toLowerCase());
                  }).toList();

                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Text(
                        widget.showWorkers ? 'لا يوجد عمال' : 'لا يوجد عملاء',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final data = filteredDocs[index].data() as Map<String, dynamic>;
                      final id = filteredDocs[index].id;
                      return _buildUserCard(context, data, id, widget.showWorkers);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Map<String, dynamic> user, String id, bool showWorkers) {
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
                    Text('الخدمة: $service', style: const TextStyle(fontSize: 12)),
                    Text('عدد التقييمات: $ratingCount', style: const TextStyle(fontSize: 12)),
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
