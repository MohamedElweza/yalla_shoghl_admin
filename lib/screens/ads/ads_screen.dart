import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  bool _isConnected = true;
  bool _isAdding = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  void _checkInternetConnection() {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      setState(() {
        _isConnected = !results.contains(ConnectivityResult.none);
      });
    });
  }

  /// Uploads image to Supabase Storage and returns the public URL
  Future<String?> _uploadImageToSupabase(File file, String folderName) async {
    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final filePath = "$folderName/$fileName";

      await supabase.storage.from("yalla.shogl").upload(filePath, file);

      final publicUrl = supabase.storage.from("yalla.shogl").getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      debugPrint("Upload error: $e");
      return null;
    }
  }

  /// Get receipt image from Supabase using document ID
  Future<String?> _getReceiptImageUrl(String docId) async {
    try {
      final filePath = "receipt/$docId.jpg";
      return supabase.storage.from("yalla.shogl").getPublicUrl(filePath);
    } catch (e) {
      debugPrint("Error getting receipt: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return Scaffold(
        appBar: AppBar(title: const Text('الإعلانات')),
        body: const Center(
          child: Text(
            'لا يوجد اتصال بالإنترنت',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

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
                            onTap: () {}, // open in browser
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
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
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


    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('إضافة إعلان جديد'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: idController,
                    decoration: const InputDecoration(labelText: 'اسم الإعلان'),
                  ),
                  TextField(
                    controller: linkController,
                    decoration: const InputDecoration(labelText: 'رابط الإعلان'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: _isAdding
                      ? null
                      : () async {
                    if (idController.text.isEmpty || linkController.text.isEmpty) return;

                    setState(() => _isAdding = true);

                    final newAd = {
                      'imageUrls': [
                        {
                          'id': idController.text.trim(),
                          'externalUrl': linkController.text.trim(),
                          'imgUrl': []
                        }
                      ]
                    };

                    await FirebaseFirestore.instance.collection('ads').add(newAd);

                    setState(() => _isAdding = false);
                    Navigator.pop(ctx);
                  },
                  child: _isAdding
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _showAddImageDialog(BuildContext context, String docId, List<Map<String, dynamic>> imageGroups, Map<String, dynamic> targetGroup) {
    final linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة صورة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.photo),
              label: const Text("اختيار من الجهاز"),
              onPressed: () async {
                final picker = ImagePicker();
                final picked = await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  final file = File(picked.path);
                  final url = await _uploadImageToSupabase(file, "ads");
                  if (url != null) {
                    _saveImageUrlToFirestore(docId, imageGroups, targetGroup, url);
                  }
                }
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: linkController,
              decoration: const InputDecoration(hintText: 'أدخل رابط الصورة'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (linkController.text.isNotEmpty) {
                _saveImageUrlToFirestore(docId, imageGroups, targetGroup, linkController.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _saveImageUrlToFirestore(String docId, List<Map<String, dynamic>> imageGroups, Map<String, dynamic> targetGroup, String url) async {
    final updatedGroup = Map<String, dynamic>.from(targetGroup);
    final updatedImages = List<String>.from(updatedGroup['imgUrl'] ?? [])..add(url);
    updatedGroup['imgUrl'] = updatedImages;

    final updatedGroups = imageGroups.map((g) => g == targetGroup ? updatedGroup : g).toList();
    await FirebaseFirestore.instance.collection('ads').doc(docId).update({'imageUrls': updatedGroups});
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
