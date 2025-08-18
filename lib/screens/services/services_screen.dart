import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:yalla_shogl_admin/screens/services/widgets/service_icon.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_colors.dart';

@immutable
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  final List<IconData> iconOptions = const [
    Icons.car_repair,
    Icons.shopping_bag,
    Icons.home_repair_service,
    Icons.cleaning_services,
    Icons.restaurant,
    Icons.design_services,
    Icons.plumbing,
    Icons.electrical_services,
    Icons.pets,
    Icons.local_grocery_store,
    Icons.medical_services,
    Icons.school,
    Icons.computer,
    Icons.build,
    Icons.handyman,
    Icons.directions_car,
    Icons.house,
    Icons.security,
    Icons.air,
    Icons.ac_unit,
  ];

  final Map<String, Color> colorOptions = const {
    'أحمر': Colors.red,
    'أزرق': Colors.blue,
    'أخضر': Colors.green,
    'برتقالي': Colors.orange,
    'أرجواني': Colors.purple,
    'رمادي': Colors.grey,
    'أسود': Colors.black,
    'أصفر': Colors.yellow,
    'وردي': Colors.pink,
    'سماوي': Colors.cyan,
    'بني': Colors.brown,
    'أزرق داكن': Colors.indigo,
    'أخضر فاتح': Colors.lightGreen,
    'برتقالي فاتح': Colors.deepOrange,
  };

  Future<bool> _checkInternet(BuildContext context) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لا يوجد اتصال بالإنترنت')));
      return false;
    }
    return true;
  }

  void _showAddServiceDialog(BuildContext context) {
    final labelController = TextEditingController();
    IconData selectedIcon = iconOptions.first;
    Color selectedColor = colorOptions.values.first;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('إضافة خدمة جديدة'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: labelController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الخدمة',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<IconData>(
                      value: selectedIcon,
                      items: iconOptions.map((icon) {
                        return DropdownMenuItem(
                          value: icon,
                          child: Row(
                            children: [
                              Icon(icon),
                              const SizedBox(width: 8),
                              Text(icon.codePoint.toString()),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (icon) {
                        if (icon != null) setState(() => selectedIcon = icon);
                      },
                      decoration: const InputDecoration(
                        labelText: 'اختر الأيقونة',
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Color>(
                      value: selectedColor,
                      items: colorOptions.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.value,
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                color: entry.value,
                              ),
                              const SizedBox(width: 8),
                              Text(entry.key),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (color) {
                        if (color != null)
                          setState(() => selectedColor = color);
                      },
                      decoration: const InputDecoration(
                        labelText: 'اختر اللون',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (!await _checkInternet(context)) return;

                          final label = labelController.text.trim();
                          if (label.isEmpty) return;

                          setState(() => isLoading = true);

                          final data = {
                            'label': label,
                            'iconCodePoint': selectedIcon.codePoint,
                            'colorValue': selectedColor.value,
                          };

                          await FirebaseFirestore.instance
                              .collection('services')
                              .add(data);

                          setState(() => isLoading = false);
                          Navigator.pop(context);
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
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

  void _showDeleteDialog(BuildContext context, DocumentSnapshot doc) {
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: const Text('هل أنت متأكد من حذف هذه الخدمة؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: isDeleting
                    ? null
                    : () async {
                        if (!await _checkInternet(context)) return;

                        setState(() => isDeleting = true);
                        await doc.reference.delete();
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'حذف',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGreyBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          AppConstants.servicesSectionTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddServiceDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('services').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Center(child: Text('حدث خطأ'));
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            final services = snapshot.data!.docs;

            return GridView.builder(
              itemCount: services.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final doc = services[index];
                final data = doc.data() as Map<String, dynamic>;

                final icon = IconData(
                  data['iconCodePoint'] ?? Icons.settings.codePoint,
                  fontFamily: 'MaterialIcons',
                );

                final color = Color(data['colorValue'] ?? Colors.grey.value);
                final label = data['label'] ?? 'بدون اسم';

                return Stack(
                  children: [
                    ServiceIcon(
                      icon: icon,
                      label: label,
                      color: color,
                      onTap: () {},
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _showDeleteDialog(context, doc),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
