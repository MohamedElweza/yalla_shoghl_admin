import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final normalized = status.isEmpty ? 'unknown' : status.toLowerCase();
    IconData icon = Icons.help_outline;
    String text = normalized;
    Color? color;

    switch (normalized) {
      case 'pending':
        icon = Icons.hourglass_bottom;
        color = Colors.orange;
        text = 'قيد المراجعة';
        break;
      case 'active':
        icon = Icons.check_circle;
        color = Colors.green;
        text = 'مفعل';
        break;
      case 'rejected':
        icon = Icons.cancel;
        color = Colors.red;
        text = 'مرفوض';
        break;
      case 'inactive':
        icon = Icons.pause_circle_filled;
        color = Colors.grey;
        text = 'غير مفعل';
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.blueGrey;
        text = 'غير معروف';
    }

    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(text, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
