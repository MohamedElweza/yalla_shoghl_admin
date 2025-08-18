import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yalla_shogl_admin/screens/waiting_list/widgets/chip_label.dart';
import 'package:yalla_shogl_admin/screens/waiting_list/widgets/form_date.dart';
import 'package:yalla_shogl_admin/screens/waiting_list/widgets/glass_card.dart';
import 'package:yalla_shogl_admin/screens/waiting_list/widgets/info_row.dart';
import 'package:yalla_shogl_admin/screens/waiting_list/widgets/initial_form_name.dart';
import 'package:yalla_shogl_admin/screens/waiting_list/widgets/section_tile.dart';
import 'package:yalla_shogl_admin/screens/waiting_list/widgets/status_badge.dart';

class RequestDetailsPage extends StatefulWidget {
  const RequestDetailsPage({super.key, required this.docRef});
  final DocumentReference<Map<String, dynamic>> docRef;

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  bool isUpdating = false;
  final TextEditingController reasonController = TextEditingController();
  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: widget.docRef.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snap.hasData || !snap.data!.exists) {
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('الطلب غير موجود')),
            ),
          );
        }

        final data = snap.data!.data()!;
        final name = (data['name'] ?? 'بدون اسم').toString();
        final email = (data['email'] ?? '').toString();
        final phone = (data['phone'] ?? '').toString();
        final bio = (data['bio'] ?? '').toString();
        final city = (data['city'] ?? data['cityName'] ?? '').toString();
        final state = (data['state'] ?? data['governorateName'] ?? '')
            .toString();
        final country = (data['country'] ?? '').toString();
        final type = (data['type'] ?? '').toString();
        final plan = (data['subscription']?['plan'] ?? '').toString();
        final status = (data['subscription']?['status'] ?? '').toString();
        final isFirstTime = data['subscription']?['isFirstTime'];
        final avatarUrl = (data['profileImageUrl'] ?? data['imageUrl'] ?? '')
            .toString();
        final createdAt = data['createdAt'];
        final receiptImageUrl = (data['subscription']?['receiptImageUrl'] ?? '')
            .toString();

        return SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('تفاصيل الطلب'),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(child: StatusBadge(status: status)),
                ),
              ],
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: isUpdating
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.close),
                            label: const Text('رفض'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () =>
                                _showRejectionDialog(widget.docRef),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            icon: const Icon(Icons.check),
                            label: const Text('قبول'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () =>
                                _updateStatus(widget.docRef, 'active'),
                          ),
                        ),
                      ],
                    ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BigAvatar(url: avatarUrl, name: name),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ChipLabel(
                                    icon: Icons.person_outline,
                                    label: type == 'technician'
                                        ? 'عامل'
                                        : 'مستخدم',
                                  ),
                                  ChipLabel(
                                    icon: Icons.workspace_premium,
                                    label: plan.isEmpty
                                        ? 'خطة غير معروفة'
                                        : plan,
                                  ),
                                  if (isFirstTime is bool)
                                    ChipLabel(
                                      icon: Icons.fiber_new,
                                      label: isFirstTime
                                          ? 'أول مرة'
                                          : 'ليس أول مرة',
                                    ),
                                  if (createdAt != null)
                                    ChipLabel(
                                      icon: Icons.event,
                                      label: formatDate(createdAt),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (bio.isNotEmpty)
                                Text(
                                  bio,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionTitle('بيانات التواصل'),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoRow(
                          icon: Icons.email,
                          label: 'الإيميل',
                          value: email,
                        ),
                        InfoRow(
                          icon: Icons.phone,
                          label: 'الهاتف',
                          value: phone,
                        ),
                        InfoRow(
                          icon: Icons.location_city,
                          label: 'المدينة',
                          value: city,
                        ),
                        InfoRow(
                          icon: Icons.map,
                          label: 'المحافظة / الولاية',
                          value: state,
                        ),
                        InfoRow(
                          icon: Icons.flag,
                          label: 'الدولة',
                          value: country,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionTitle('صورة الايصال'),
                  if (receiptImageUrl.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            child: InteractiveViewer(
                              child: Image.network(
                                receiptImageUrl,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          receiptImageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    const Text('لا توجد صورة إيصال'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRejectionDialog(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سبب الرفض'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(hintText: 'أدخل سبب الرفض هنا'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إرسال', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final reason = reasonController.text.trim();
    await _updateStatus(ref, 'rejected', reason: reason);
  }

  Future<void> _updateStatus(
    DocumentReference<Map<String, dynamic>> ref,
    String newStatus, {
    String? reason,
  }) async {
    if (reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('فشل في الارسال يجب ملئ الحقل '),
        ),
      );
      return;
    }

    setState(() => isUpdating = true);
    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) return;
        final data = snap.data() as Map<String, dynamic>;
        final sub = Map<String, dynamic>.from(
          (data['subscription'] ?? {}) as Map,
        );
        sub['status'] = newStatus;
        if (newStatus == 'active' && sub['startDate'] == null) {
          sub['startDate'] = Timestamp.now();
        }
        if (reason != null && reason.isNotEmpty) {
          sub['rejectionReason'] = reason;
        }
        tx.update(ref, {'subscription': sub});
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'active' ? 'تم قبول الطلب' : 'تم رفض الطلب',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تعذر تحديث الحالة: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }
}

class _BigAvatar extends StatelessWidget {
  const _BigAvatar({required this.url, required this.name});
  final String url;
  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = initialsFromName(name);
    return CircleAvatar(
      radius: 36,
      backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
      child: url.isEmpty
          ? Text(
              initials,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }
}
