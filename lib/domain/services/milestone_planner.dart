import 'dart:math';

import '../../data/models/models.dart';

/// Turns a project's payment structure into a default milestone schedule.
class MilestonePlanner {
  MilestonePlanner._();

  static List<Milestone> plan(Project p, String Function() nextId) {
    final total = p.budget;
    final span = max(7, p.dueDate.difference(p.startDate).inDays);
    DateTime at(double f) => p.startDate.add(Duration(days: (span * f).round()));

    // (title, share of total, point in the timeline)
    List<(String, double, double)> rows;
    switch (p.paymentStructure) {
      case '50% advance, 50% on delivery':
        rows = [('Advance', 0.5, 0.0), ('Final delivery', 0.5, 1.0)];
      case 'Fixed price':
        final a = p.advancePct / 100;
        rows = [('Advance', a, 0.0), ('Final delivery', 1 - a, 1.0)];
      case 'Hourly (time and materials)':
      case 'Monthly retainer':
        final n = max(2, (span / 30).ceil());
        rows = [for (var i = 0; i < n; i++) ('Invoice ${i + 1}', 1 / n, (i + 1) / n)];
      default:
        final a = p.advancePct / 100;
        final rest = 1 - a;
        rows = [
          ('Advance', a, 0.0),
          ('Design and architecture', rest * 0.3, 0.3),
          ('Core development', rest * 0.4, 0.65),
          ('Testing and delivery', rest * 0.3, 1.0),
        ];
    }

    final out = <Milestone>[];
    var allocated = 0.0;
    for (var i = 0; i < rows.length; i++) {
      final isLast = i == rows.length - 1;
      final amt = isLast ? total - allocated : (total * rows[i].$2 / 100).round() * 100.0;
      allocated += amt;
      out.add(Milestone(
        id: nextId(),
        projectId: p.id,
        title: rows[i].$1,
        amount: amt,
        due: at(rows[i].$3),
        clause: '7.${i + 1}',
      ));
    }
    return out;
  }
}
