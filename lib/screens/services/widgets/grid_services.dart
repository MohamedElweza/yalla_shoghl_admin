import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:yalla_shogl_admin/screens/services/widgets/service_icon.dart';

@immutable
class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('services').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('❌ خطأ في تحميل الخدمات'));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('🚫 لا توجد خدمات متاحة'));
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;

            final icon = IconData(
              data['iconCodePoint'] ?? Icons.settings.codePoint,
              fontFamily: 'MaterialIcons',
            );

            final color = Color(
              data['colorValue'] ?? 0xFF9E9E9E,
            ); // Default grey
            final label = data['label'] ?? 'بدون اسم';

            return ServiceIcon(
              icon: icon,
              label: label,
              color: color,
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => FilteredWorkersScreen(serviceName: label),
                //   ),
                // );
              },
            );
          },
        );
      },
    );
  }
}
