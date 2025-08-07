import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdsScreen extends StatelessWidget {
  const AdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعلانات')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ads').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('خطأ في تحميل البيانات'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final adsDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: adsDocs.length,
            itemBuilder: (context, index) {
              final doc = adsDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final imageUrls = List<String>.from(data['imgUrl'] ?? []);
              final externalUrl = data['externalUrl'] ?? '';
              final id = data['id'] ?? '';

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: $id'),
                      Text('Link: $externalUrl', style: const TextStyle(color: Colors.blue)),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: imageUrls.length,
                        itemBuilder: (context, imgIndex) {
                          final imgUrl = imageUrls[imgIndex];
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(imgUrl, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () => _deleteImage(context, doc.id, imageUrls, imgIndex),
                                  child: const CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () => _showAddImageDialog(context, doc.id, imageUrls),
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة صورة'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddImageDialog(BuildContext context, String docId, List<String> existingImages) {
    final imageUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة صورة'),
        content: TextField(
          controller: imageUrlController,
          decoration: const InputDecoration(hintText: 'أدخل رابط الصورة'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final newImage = imageUrlController.text.trim();
              if (newImage.isNotEmpty) {
                final updatedImages = [...existingImages, newImage];
                await FirebaseFirestore.instance.collection('ads').doc(docId).update({'imgUrl': updatedImages});
              }
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _deleteImage(BuildContext context, String docId, List<String> existingImages, int indexToRemove) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الصورة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );

    if (confirmed == true) {
      final updatedImages = [...existingImages]..removeAt(indexToRemove);
      await FirebaseFirestore.instance.collection('ads').doc(docId).update({'imgUrl': updatedImages});
    }
  }
}
