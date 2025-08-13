import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';

class AdsScreen extends StatelessWidget {
  const AdsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعلانات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAdDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ads').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ أثناء تحميل البيانات'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('لا توجد إعلانات حالياً'));
          }

          final adsDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: adsDocs.length,
            itemBuilder: (context, index) {
              final doc = adsDocs[index];
              final data = doc.data() as Map<String, dynamic>;
              final imageGroups = List<Map<String, dynamic>>.from(data['imageUrls'] ?? []);

              return Column(
                children: imageGroups.map((group) {
                  final externalUrl = group['externalUrl'] ?? '';
                  final id = group['id'] ?? '';
                  final images = List<String>.from(group['imgUrl'] ?? []);

                  return Card(
                    margin: const EdgeInsets.all(12),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text('ID: $id')),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteAd(context, doc.id),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {}, // يمكن فتحه في WebView أو المتصفح
                            child: Text(
                              'Link: $externalUrl',
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: images.length,
                            itemBuilder: (context, imgIndex) {
                              final imgUrl = images[imgIndex];
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      imgUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return Shimmer.fromColors(
                                          baseColor: Colors.grey.shade300,
                                          highlightColor: Colors.grey.shade100,
                                          child: Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.broken_image, color: Colors.red),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: GestureDetector(
                                      onTap: () => _deleteImage(context, doc.id, imageGroups, group, imgIndex),
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
                            onPressed: () => _showAddImageDialog(context, doc.id, imageGroups, group),
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة صورة'),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddAdDialog(BuildContext context) {
    final idController = TextEditingController();
    final linkController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة إعلان جديد'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'ID الإعلان'),
              ),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(labelText: 'رابط الإعلان'),
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'رابط الصورة الأولى'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final id = idController.text.trim();
              final link = linkController.text.trim();
              final img = imageController.text.trim();

              if (id.isEmpty || link.isEmpty || img.isEmpty) return;

              final newAd = {
                'imageUrls': [
                  {
                    'id': id,
                    'externalUrl': link,
                    'imgUrl': [img],
                  }
                ]
              };

              await FirebaseFirestore.instance.collection('ads').add(newAd);
              Navigator.pop(ctx);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _deleteAd(BuildContext context, String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الإعلان بالكامل؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف')),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance.collection('ads').doc(docId).delete();
    }
  }

  void _showAddImageDialog(BuildContext context, String docId, List<Map<String, dynamic>> imageGroups, Map<String, dynamic> targetGroup) {
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
                final updatedGroup = Map<String, dynamic>.from(targetGroup);
                final updatedImages = List<String>.from(updatedGroup['imgUrl'] ?? [])..add(newImage);
                updatedGroup['imgUrl'] = updatedImages;

                final updatedGroups = imageGroups.map((g) => g == targetGroup ? updatedGroup : g).toList();
                await FirebaseFirestore.instance.collection('ads').doc(docId).update({'imageUrls': updatedGroups});
              }
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _deleteImage(BuildContext context, String docId, List<Map<String, dynamic>> imageGroups, Map<String, dynamic> targetGroup, int indexToRemove) async {
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
      final updatedGroup = Map<String, dynamic>.from(targetGroup);
      final updatedImages = List<String>.from(updatedGroup['imgUrl'] ?? [])..removeAt(indexToRemove);
      updatedGroup['imgUrl'] = updatedImages;

      final updatedGroups = imageGroups.map((g) => g == targetGroup ? updatedGroup : g).toList();
      await FirebaseFirestore.instance.collection('ads').doc(docId).update({'imageUrls': updatedGroups});
    }
  }
}

