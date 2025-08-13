import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


String _two(int n) => n.toString().padLeft(2, '0');

String formatDate(dynamic v) {
  try {
    if (v is Timestamp) {
      final dt = v.toDate();
      return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}';
    }
    if (v is String) {
      // Try parse ISO string
      final dt = DateTime.tryParse(v);
      if (dt != null) {
        return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}';
      }
    }
  } catch (_) {}
  return '-';
}