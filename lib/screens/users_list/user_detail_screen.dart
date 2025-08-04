import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_colors.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;
  final bool isWorker;

  const UserDetailScreen({
    super.key,
    required this.userId,
    required this.isWorker,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final Map<String, TextEditingController> controllers = {};
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isProcessing = false; // ✅ For update/delete loading indicator

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection(widget.isWorker ? 'workers' : 'users')
        .doc(widget.userId)
        .get();

    userData = doc.data() ?? {};
    _initializeControllers(userData!);

    setState(() {
      isLoading = false;
    });
  }

  void _initializeControllers(Map<String, dynamic> data) {
    controllers['name'] = TextEditingController(text: data['name'] ?? '');
    controllers['email'] = TextEditingController(text: data['email'] ?? '');
    controllers['phone'] = TextEditingController(text: data['phone'] ?? '');
    controllers['bio'] = TextEditingController(text: data['bio'] ?? '');
    controllers['cityName'] = TextEditingController(text: data['cityName'] ?? '');
    controllers['governorateName'] = TextEditingController(text: data['governorateName'] ?? '');
    controllers['service'] = TextEditingController(
      text: (data['services'] is List && data['services'].isNotEmpty)
          ? (data['services'][0]['name'] ?? '')
          : '',
    );
    controllers['rating'] = TextEditingController(
      text: (data['rating'] ?? 0).toString(),
    );
  }

  Future<void> _updateUser() async {
    setState(() => isProcessing = true);

    try {
      final updatedData = {
        'name': controllers['name']?.text.trim(),
        'email': controllers['email']?.text.trim(),
        'phone': controllers['phone']?.text.trim(),
      };

      if (widget.isWorker) {
        updatedData['bio'] = controllers['bio']?.text.trim();
        updatedData['cityName'] = controllers['cityName']?.text.trim();
        updatedData['governorateName'] = controllers['governorateName']?.text.trim();
        updatedData['rating'] = (double.tryParse(controllers['rating']?.text ?? '0') ?? 0).toString();

        if (userData?['services'] is List && userData!['services'].isNotEmpty) {
          final services = List<Map<String, dynamic>>.from(userData!['services']);
          services[0]['name'] = controllers['service']?.text.trim();
          updatedData['services'] = jsonEncode(services);
        }
      }

      await FirebaseFirestore.instance
          .collection(widget.isWorker ? 'workers' : 'users')
          .doc(widget.userId)
          .update(updatedData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم تحديث البيانات بنجاح')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ فشل التحديث: $e')),
      );
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  Future<void> _deleteUser() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا المستخدم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => isProcessing = true);

    try {
      await FirebaseFirestore.instance
          .collection(widget.isWorker ? 'workers' : 'users')
          .doc(widget.userId)
          .delete();

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ تم حذف المستخدم')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ فشل الحذف: $e')),
      );
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        title: Text(widget.isWorker ? 'تفاصيل العامل' : 'تفاصيل العميل'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: isProcessing ? null : _deleteUser,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTextField('name', 'الاسم'),
                const SizedBox(height: 12),
                _buildTextField('email', 'البريد الإلكتروني'),
                const SizedBox(height: 12),
                _buildTextField('phone', 'رقم الهاتف', keyboardType: TextInputType.phone),
                const SizedBox(height: 12),
                if (widget.isWorker) ...[
                  _buildTextField('bio', 'الوصف / النبذة'),
                  const SizedBox(height: 12),
                  _buildTextField('cityName', 'المدينة'),
                  const SizedBox(height: 12),
                  _buildTextField('governorateName', 'المحافظة'),
                  const SizedBox(height: 12),
                  _buildTextField('service', 'اسم الخدمة'),
                  const SizedBox(height: 12),
                  _buildTextField('rating', 'التقييم', keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                ],
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: isProcessing ? null : _updateUser,
                  icon: const Icon(Icons.save),
                  label: const Text('تحديث البيانات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ),
          ),
          if (isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(String key, String label, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controllers[key],
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
