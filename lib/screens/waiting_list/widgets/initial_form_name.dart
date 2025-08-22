
String initialsFromName(String name) {
  final parts = name.trim().split(RegExp(r"\s+"));
  if (parts.isEmpty) return '?';
  final first = parts.first.isNotEmpty ? parts.first[0] : '';
  final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
  final init = (first + last).toUpperCase();
  return init.isEmpty ? '?' : init;
}
