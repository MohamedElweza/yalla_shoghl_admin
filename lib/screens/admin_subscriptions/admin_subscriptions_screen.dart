import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/utils/app_colors.dart';

class AdminSubscriptionsScreen extends StatefulWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  State<AdminSubscriptionsScreen> createState() => _AdminSubscriptionsScreenState();
}

class _AdminSubscriptionsScreenState extends State<AdminSubscriptionsScreen> {
  final CollectionReference plansRef = FirebaseFirestore.instance.collection('plans');
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      setState(() {
        _isConnected = results.any((r) => r != ConnectivityResult.none);
      });
    });
  }

  Future<void> _checkInitialConnection() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _editSubscription(String docId, double newPrice) async {
    _showLoadingDialog();
    try {
      await plansRef.doc(docId).update({'price': newPrice});
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteSubscription(String docId) async {
    _showLoadingDialog();
    try {
      await plansRef.doc(docId).delete();
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> _addSubscription(String title, double price) async {
    final isAnnual = title.contains('سنوي');
    final monthlyPrice = 49.99;
    final discount = isAnnual ? monthlyPrice * 12 - price : 0.0;

    _showLoadingDialog();
    try {
      await plansRef.doc(title).set({
        'title': title,
        'price': price,
        'discount': discount,
      });
    } finally {
      Navigator.pop(context);
    }
  }

  void _showEditDialog(String docId, String title, double currentPrice) {
    final controller = TextEditingController(text: currentPrice.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('تعديل السعر - $title'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'السعر بالجنيه'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            onPressed: () async {
              final price = double.tryParse(controller.text);
              if (price != null) {
                Navigator.pop(context);
                await _editSubscription(docId, price);
                setState(() {});
              }
            },
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة اشتراك جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'الاسم')),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'السعر'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            onPressed: () async {
              final title = titleController.text.trim();
              final price = double.tryParse(priceController.text.trim());
              if (title.isNotEmpty && price != null) {
                Navigator.pop(context);
                await _addSubscription(title, price);
                setState(() {});
              }
            },
            child: const Text('إضافة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الاشتراكات', style: TextStyle(color: Colors.black)),
        elevation: 2,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: !_isConnected
          ? const Center(child: Text('⚠ لا يوجد اتصال بالإنترنت', style: TextStyle(fontSize: 16)))
          : StreamBuilder<QuerySnapshot>(
        stream: plansRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('لا توجد اشتراكات'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 3 / 4,
            ),
            itemBuilder: (_, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                color: AppColors.primaryPurple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.payments_rounded, size: 36, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              data['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${data['price']} جنيه', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        Column(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryPurple,
                                minimumSize: const Size.fromHeight(36),
                              ),
                              onPressed: () => _showEditDialog(doc.id, data['title'], data['price']),
                              icon: const Icon(Icons.edit),
                              label: const Text('تعديل'),
                            ),
                            const SizedBox(height: 6),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(36),
                              ),
                              onPressed: () async {
                                await _deleteSubscription(doc.id);
                                setState(() {});
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('حذف'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
