import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import 'package:yalla_shogl_admin/screens/waiting_list/widgets/chip_label.dart';
import 'package:yalla_shogl_admin/screens/waiting_list/widgets/empty_state.dart';
import 'package:yalla_shogl_admin/screens/waiting_list/widgets/form_date.dart';
import 'package:yalla_shogl_admin/screens/waiting_list/widgets/glass_card.dart';
import 'package:yalla_shogl_admin/screens/waiting_list/widgets/initial_form_name.dart';
import 'package:yalla_shogl_admin/screens/waiting_list/widgets/status_badge.dart';

import 'details_screen.dart';

class PendingRequestsPage extends StatefulWidget {
  const PendingRequestsPage({super.key});

  @override
  State<PendingRequestsPage> createState() => _PendingRequestsPageState();
}

class _PendingRequestsPageState extends State<PendingRequestsPage> {
  String _query = '';
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _startConnectivityCheck();
  }

  void _startConnectivityCheck() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
          setState(() {
            _isConnected = result != ConnectivityResult.none;
          });
        });

    // Initial check
    Connectivity().checkConnectivity().then((result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلبات التسجيل المعلّقة'),
          actions: const [SizedBox(width: 8)],
        ),
        body: Column(
          children: [
            if (!_isConnected)
              Container(
                width: double.infinity,
                color: Colors.red,
                padding: const EdgeInsets.all(8),
                child: const Text(
                  '⚠ لا يوجد اتصال بالإنترنت',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'ابحث بالاسم أو الإيميل أو الهاتف…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onChanged: (v) =>
                    setState(() => _query = v.trim().toLowerCase()),
              ),
            ),
            Expanded(
              child: _isConnected
                  ? StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('workers')
                    .where('subscription.status', isEqualTo: 'pending')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (snap.hasError) {
                    return Center(
                        child: Text('حدث خطأ: ${snap.error}'));
                  }
                  final docs = snap.data?.docs ?? [];

                  // Local filtering by _query
                  final filtered = docs.where((d) {
                    final data = d.data();
                    final name =
                    (data['name'] ?? '').toString().toLowerCase();
                    final email =
                    (data['email'] ?? '').toString().toLowerCase();
                    final phone =
                    (data['phone'] ?? '').toString().toLowerCase();
                    return _query.isEmpty ||
                        name.contains(_query) ||
                        email.contains(_query) ||
                        phone.contains(_query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const EmptyState();
                  }

                  return ListView.separated(
                    padding:
                    const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final doc = filtered[i];
                      final data = doc.data();
                      final avatarUrl = (data['profileImageUrl'] ??
                          data['imageUrl'] ??
                          '')
                          .toString();
                      final name =
                      (data['name'] ?? 'بدون اسم').toString();
                      final email =
                      (data['email'] ?? '').toString();
                      final phone =
                      (data['phone'] ?? '').toString();

                      return GlassCard(
                        child: ListTile(
                          leading:
                          _Avatar(url: avatarUrl, name: name),
                          title: Text(
                            name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              if (email.isNotEmpty) Text(email),
                              if (phone.isNotEmpty) Text(phone),
                              const SizedBox(height: 6),
                              const Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  StatusBadge(status: 'pending'),
                                ],
                              ),
                            ],
                          ),
                          trailing:
                          const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RequestDetailsPage(
                                  docRef: doc.reference),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              )
                  : const Center(
                child: Text(
                  '📡 يرجى الاتصال بالإنترنت لعرض الطلبات',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.name});
  final String url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = initialsFromName(name);
    return CircleAvatar(
      radius: 24,
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty ? Text(initials) : null,
    );
  }
}
