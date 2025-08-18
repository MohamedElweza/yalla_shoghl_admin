import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'package:yalla_shogl_admin/screens/admin_subscriptions/admin_subscriptions_screen.dart';
import 'package:yalla_shogl_admin/screens/users_list/users_list_screen.dart';
import '../../core/utils/app_colors.dart';
import '../ads/ads_screen.dart';
import '../services/services_screen.dart';
import '../waiting_list/waiting_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;

  /// Function to check internet before navigating
  Future<bool> _hasInternet(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetMessage(context);
      return false;
    }

    bool hasInternet = await InternetConnectionChecker.instance.hasConnection;
    if (!hasInternet) {
      _showNoInternetMessage(context);
    }

    return hasInternet;
  }

  /// Show snackbar warning
  void _showNoInternetMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚠ لا يوجد اتصال بالإنترنت'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Navigate only if internet is available
  Future<void> _navigateTo(BuildContext context, Widget screen) async {
    setState(() => _isLoading = true);

    if (await _hasInternet(context)) {
      setState(() => _isLoading = false);
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                'لوحة تحكم المدير',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              backgroundColor: AppColors.primaryPurple,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _AdminOptionCard(
                    title: 'عمال',
                    icon: Icons.engineering,
                    color: Colors.teal,
                    onTap: () {
                      _navigateTo(
                        context,
                        const UsersListScreen(showWorkers: true),
                      );
                    },
                  ),
                  _AdminOptionCard(
                    title: 'العملاء (البريد الشخصي)',
                    icon: Icons.person_outline,
                    color: Colors.deepPurple,
                    onTap: () {
                      _navigateTo(
                        context,
                        const UsersListScreen(showWorkers: false),
                      );
                    },
                  ),
                  _AdminOptionCard(
                    title: 'الاشتراكات',
                    icon: Icons.campaign,
                    color: Colors.orangeAccent,
                    onTap: () {
                      _navigateTo(context, const AdminSubscriptionsScreen());
                    },
                  ),
                  _AdminOptionCard(
                    title: 'الإعلانات',
                    icon: Icons.people,
                    color: Colors.green,
                    onTap: () {
                      _navigateTo(context, AdsScreen());
                    },
                  ),
                  _AdminOptionCard(
                    title: 'الخدمات',
                    icon: Icons.design_services,
                    color: Colors.blue,
                    onTap: () {
                      _navigateTo(context, ServicesScreen());
                    },
                  ),
                  _AdminOptionCard(
                    title: 'الطلبات المنتظرة',
                    icon: Icons.pending_actions,
                    color: Colors.brown,
                    onTap: () {
                      _navigateTo(context, PendingRequestsPage());
                    },
                  ),
                ],
              ),
            ),
          ),

          /// Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class _AdminOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AdminOptionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
