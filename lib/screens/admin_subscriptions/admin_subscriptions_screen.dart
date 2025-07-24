import 'package:flutter/material.dart';
import '../../core/utils/app_colors.dart';

class AdminSubscriptionsScreen extends StatefulWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  State<AdminSubscriptionsScreen> createState() => _AdminSubscriptionsScreenState();
}

class _AdminSubscriptionsScreenState extends State<AdminSubscriptionsScreen> {
  final List<Map<String, dynamic>> subscriptions = [
    {
      'title': 'اشتراك شهري',
      'icon': Icons.calendar_view_month,
      'color': Colors.teal,
      'price': 49.99,
      'editable': true,
    },
    {
      'title': 'اشتراك سنوي',
      'icon': Icons.calendar_today,
      'color': Colors.deepPurple,
      'price': 299.99,
      'editable': true,
    },
    {
      'title': 'اشتراك مجاني',
      'icon': Icons.card_giftcard,
      'color': Colors.grey,
      'price': 0.0,
      'editable': false,
    },
  ];

  void _editPrice(int index) {
    final controller = TextEditingController(
      text: subscriptions[index]['price'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تعديل السعر - ${subscriptions[index]['title']}'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'السعر بالجنيه'),
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
              onPressed: () {
                final double? value = double.tryParse(controller.text);
                if (value != null) {
                  setState(() {
                    subscriptions[index]['price'] = value;
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addSubscription() {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    IconData? selectedIcon;
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إضافة اشتراك جديد'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'اسم الاشتراك'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'السعر بالجنيه'),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
              child: const Text('إضافة', style: TextStyle(color: Colors.white)),
              onPressed: () {
                final title = titleController.text.trim();
                final price = double.tryParse(priceController.text.trim()) ?? 0.0;

                if (title.isNotEmpty && selectedIcon != null) {
                  setState(() {
                    subscriptions.add({
                      'title': title,
                      'icon': selectedIcon,
                      'color': selectedColor,
                      'price': price,
                      'editable': true,
                    });
                  });
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _removeSubscription(int index) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف ${subscriptions[index]['title']}؟'),
          actions: [
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف', style: TextStyle(color: Colors.white)),
              onPressed: () {
                setState(() {
                  subscriptions.removeAt(index);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(int index) {
    final sub = subscriptions[index];
    return Card(
      color: sub['color'],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(sub['icon'], size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              sub['title'],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${sub['price']} جنيه',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 12),
            if (sub['editable']) ...[
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: sub['color']),
                icon: const Icon(Icons.edit),
                label: const Text('تعديل'),
                onPressed: () => _editPrice(index),
              ),
              const SizedBox(height: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                icon: const Icon(Icons.delete),
                label: const Text('حذف', ),
                onPressed: () => _removeSubscription(index),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primaryPurple,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
            onPressed: _addSubscription,
          ),
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('إدارة الاشتراكات', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white) ),
            backgroundColor: AppColors.primaryPurple,
          ),

        
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(
                  subscriptions.length,
                      (index) => SizedBox(
                    width: MediaQuery.of(context).size.width / 2 - 24,
                    child: _buildSubscriptionCard(index),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
