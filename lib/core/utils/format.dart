import 'package:intl/intl.dart';

final _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

/// ₹1,25,000 with Indian digit grouping.
String inr(num v) => _inr.format(v);

/// ₹1.25L, ₹2.4Cr, ₹45K for tight spaces.
String inrShort(num v) {
  final a = v.abs();
  final sign = v < 0 ? '-' : '';
  if (a >= 10000000) return '$sign₹${(a / 10000000).toStringAsFixed(1)}Cr';
  if (a >= 100000) return '$sign₹${(a / 100000).toStringAsFixed(a >= 1000000 ? 1 : 2)}L';
  if (a >= 1000) return '$sign₹${(a / 1000).toStringAsFixed(a >= 10000 ? 0 : 1)}K';
  return '$sign₹${a.toStringAsFixed(0)}';
}

String fmtDate(DateTime d) => DateFormat('MMM d, y').format(d);
String fmtDay(DateTime d) => DateFormat('d MMM').format(d);

String relDays(DateTime d, [DateTime? now]) {
  final n = now ?? DateTime.now();
  final diff = DateTime(d.year, d.month, d.day).difference(DateTime(n.year, n.month, n.day)).inDays;
  if (diff == 0) return 'today';
  if (diff == 1) return 'tomorrow';
  if (diff == -1) return 'yesterday';
  if (diff > 0) return 'in $diff days';
  return '${-diff} days ago';
}

String greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

String initials(String name) {
  final p = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (p.isEmpty) return '?';
  if (p.length == 1) return p.first[0].toUpperCase();
  return (p.first[0] + p.last[0]).toUpperCase();
}
