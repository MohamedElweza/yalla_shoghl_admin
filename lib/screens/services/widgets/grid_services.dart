
import 'package:flutter/material.dart';
import 'package:yalla_shogl_admin/screens/users_list/users_list_screen.dart';

import 'service_icon.dart';

@immutable
class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});


  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio:
            0.8, // Adjust based on how much height ServiceIcon takes
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Important!
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceIcon(
          icon: service['icon'] as IconData,
          label: service['label'] as String,
          color: service['color'] as Color,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  UsersScreen()
            ),
          )
        );
      },
    );
  }
}

const List<Map<String, dynamic>> services = [
  {
    'icon': Icons.carpenter,
    'label': 'نجارة',
    'title': 'أعمال النجارة',
    'color': Colors.brown,
  },
  {
    'icon': Icons.electrical_services,
    'label': 'كهرباء',
    'title': 'أعمال الكهرباء',
    'color': Colors.amber,
  },
  {
    'icon': Icons.plumbing,
    'label': 'سباكة',
    'title': 'أعمال السباكة',
    'color': Colors.blue,
  },
  {
    'icon': Icons.format_paint,
    'label': 'دهانات',
    'title': 'أعمال الدهانات',
    'color': Colors.orange,
  },
  {
    'icon': Icons.window,
    'label': 'ألمنيوم وزجاج',
    'title': 'أعمال الألمنيوم والزجاج',
    'color': Colors.cyan,
  },
  {
    'icon': Icons.texture,
    'label': 'محارة وجبس بورد',
    'title': 'أعمال المحارة والجبس بورد',
    'color': Colors.grey,
  },
  {
    'icon': Icons.construction,
    'label': 'مقاولات وبناء',
    'title': 'مقاولات وبناء',
    'color': Colors.teal,
  },
  {
    'icon': Icons.kitchen,
    'label': 'صيانة أجهزة',
    'title': 'صيانة الأجهزة الكهربائية',
    'color': Colors.red,
  },
  {
    'icon': Icons.cleaning_services,
    'label': 'تنظيف منازل',
    'title': 'خدمات تنظيف المنازل',
    'color': Colors.lightGreen,
  },
  {
    'icon': Icons.pest_control,
    'label': 'مكافحة حشرات',
    'title': 'مكافحة الحشرات',
    'color': Colors.lime,
  },
  {
    'icon': Icons.pool,
    'label': 'صيانة مسابح',
    'title': 'صيانة المسابح',
    'color': Colors.blueAccent,
  },
  {
    'icon': Icons.local_florist,
    'label': 'حدائق وزراعة',
    'title': 'تنسيق الحدائق والزراعة',
    'color': Colors.green,
  },
  {
    'icon': Icons.camera_alt,
    'label': 'كاميرات مراقبة',
    'title': 'تركيب كاميرات المراقبة',
    'color': Colors.blueGrey,
  },
  {
    'icon': Icons.ac_unit,
    'label': 'تكييف وتبريد',
    'title': 'تركيب وصيانة التكييفات',
    'color': Colors.indigo,
  },
  {
    'icon': Icons.solar_power,
    'label': 'طاقة شمسية',
    'title': 'أنظمة الطاقة الشمسية',
    'color': Colors.amber,
  },
  {
    'icon': Icons.home_repair_service,
    'label': 'صيانة عامة',
    'title': 'صيانة عامة للمنازل',
    'color': Colors.deepPurple,
  },
  {
    'icon': Icons.elevator,
    'label': 'مصاعد',
    'title': 'صيانة وإصلاح المصاعد',
    'color': Colors.purple,
  },
  {
    'icon': Icons.local_shipping,
    'label': 'نقل أثاث',
    'title': 'خدمات نقل الأثاث',
    'color': Colors.pink,
  },
  {
    'icon': Icons.sanitizer,
    'label': 'تعقيم وتطهير',
    'title': 'خدمات التعقيم والتطهير',
    'color': Colors.tealAccent,
  },
  {
    'icon': Icons.local_fire_department,
    'label': 'أنظمة حريق',
    'title': 'تركيب وصيانة أنظمة الحريق',
    'color': Colors.red,
  },
  {
    'icon': Icons.security,
    'label': 'أنظمة أمنية',
    'title': 'تركيب وصيانة الأنظمة الأمنية',
    'color': Colors.blueGrey,
  },
  {
    'icon': Icons.water_drop,
    'label': 'خزانات ومياه',
    'title': 'صيانة خزانات المياه',
    'color': Colors.lightBlue,
  },
  {
    'icon': Icons.design_services,
    'label': 'تصميم داخلي',
    'title': 'خدمات التصميم الداخلي',
    'color': Colors.deepOrange,
  },
  {
    'icon': Icons.wifi,
    'label': 'شبكات وسمارت هوم',
    'title': 'تركيب شبكات وأنظمة المنزل الذكي',
    'color': Colors.indigo,
  },
  {
    'icon': Icons.waterfall_chart,
    'label': 'نوافير وشلالات',
    'title': 'تركيب وصيانة النوافير والشلالات',
    'color': Colors.blueAccent,
  },
];