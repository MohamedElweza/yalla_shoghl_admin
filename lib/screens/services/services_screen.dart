// import 'package:flutter/material.dart';
// import 'package:yalla_shogl_admin/screens/services/widgets/grid_services.dart';
//
// import '../../core/constants/app_constants.dart';
// import '../../core/utils/app_colors.dart';
//
// @immutable
// class ServicesScreen extends StatelessWidget {
//   const ServicesScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.lightGreyBackground,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           AppConstants.servicesSectionTitle,
//           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//             fontWeight: FontWeight.bold,
//             color: AppColors.darkText,
//           ),
//         ),
//         leading: Container(),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.arrow_forward),
//             onPressed: () {
//               // Navigate to add user screen
//               Navigator.pop(context );
//             },
//           ),
//         ],
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: const Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 50),
//         child: ServicesGrid(), // Reuses the existing services grid
//       ),
//     );
//   }
// }
