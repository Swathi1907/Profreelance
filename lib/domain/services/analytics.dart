import 'dart:math';

import 'package:intl/intl.dart';

import '../../data/models/models.dart';

typedef Month = ({String label, double paid, double pending});

class AnalyticsSummary {
  const AnalyticsSummary({
    required this.completed,
    required this.estimationAccuracy,
    required this.bias,
    required this.avgDurationDays,
    required this.avgEarnings,
    required this.onTimeRate,
    required this.totalEarned,
    required this.outstanding,
    required this.techFreq,
    required this.domainFreq,
    required this.cashflow,
  });

  final List<Project> completed;
  final double estimationAccuracy;
  final double bias; // mean actual/estimated
  final double avgDurationDays;
  final double avgEarnings;
  final double onTimeRate;
  final double totalEarned;
  final double outstanding;
  final List<MapEntry<String, int>> techFreq;
  final List<MapEntry<String, int>> domainFreq;
  final List<Month> cashflow;
}

class Analytics {
  Analytics._();

  static List<MapEntry<String, int>> _freq(Iterable<String> items) {
    final m = <String, int>{};
    for (final i in items) {
      m[i] = (m[i] ?? 0) + 1;
    }
    return m.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  static AnalyticsSummary compute(Portfolio d, [DateTime? at]) {
    final now = at ?? DateTime.now();
    final done = d.projects.where((p) => p.isCompleted && p.actualHours > 0).toList();

    double accuracy = 0, bias = 1;
    if (done.isNotEmpty) {
      accuracy = done.map((p) => max(0.0, 1 - (p.actualHours - p.estimatedHours).abs() / p.estimatedHours)).reduce((a, b) => a + b) / done.length * 100;
      bias = done.map((p) => p.actualHours / p.estimatedHours).reduce((a, b) => a + b) / done.length;
    }
    final withEnd = done.where((p) => p.endDate != null).toList();
    final avgDur = withEnd.isEmpty ? 0.0 : withEnd.map((p) => p.endDate!.difference(p.startDate).inDays).reduce((a, b) => a + b) / withEnd.length;
    final avgEarn = done.isEmpty ? 0.0 : done.map((p) => p.budget).reduce((a, b) => a + b) / done.length;
    final onTime = withEnd.isEmpty ? 0.0 : withEnd.where((p) => !p.endDate!.isAfter(p.dueDate)).length / withEnd.length * 100;

    final earned = d.milestones.where((m) => m.paidOn != null).fold<double>(0, (s, m) => s + m.amount);
    final out = d.milestones.where((m) => m.paidOn == null).fold<double>(0, (s, m) => s + m.amount);

    final months = <Month>[];
    for (var i = -3; i <= 2; i++) {
      final first = DateTime(now.year, now.month + i, 1);
      final next = DateTime(now.year, now.month + i + 1, 1);
      bool inMonth(DateTime x) => !x.isBefore(first) && x.isBefore(next);
      final paid = d.milestones.where((m) => m.paidOn != null && inMonth(m.paidOn!)).fold<double>(0, (s, m) => s + m.amount);
      final pend = d.milestones.where((m) => m.paidOn == null && inMonth(m.due)).fold<double>(0, (s, m) => s + m.amount);
      months.add((label: DateFormat('MMM').format(first), paid: paid, pending: pend));
    }

    return AnalyticsSummary(
      completed: done,
      estimationAccuracy: accuracy,
      bias: bias,
      avgDurationDays: avgDur,
      avgEarnings: avgEarn,
      onTimeRate: onTime,
      totalEarned: earned,
      outstanding: out,
      techFreq: _freq(d.projects.expand((p) => p.techStack)),
      domainFreq: _freq(d.projects.map((p) => p.domain)),
      cashflow: months,
    );
  }
}
