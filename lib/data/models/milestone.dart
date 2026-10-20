import 'dart:math';
import 'models.dart';

class Milestone {
  const Milestone({
    required this.id,
    required this.projectId,
    required this.title,
    required this.amount,
    required this.due,
    this.paidOn,
    this.clause = '',
  });

  final String id;
  final String projectId;
  final String title;
  final double amount;
  final DateTime due;
  final DateTime? paidOn;

  /// Contract clause this payment is tied to, e.g. "3.2".
  final String clause;

  MilestoneStatus statusAt(DateTime now) => paidOn != null
      ? MilestoneStatus.paid
      : (due.isBefore(DateTime(now.year, now.month, now.day)) ? MilestoneStatus.overdue : MilestoneStatus.pending);

  int get paidLateDays => paidOn == null ? 0 : max(0, paidOn!.difference(due).inDays);

  Milestone markPaid(DateTime on) => Milestone(
        id: id,
        projectId: projectId,
        title: title,
        amount: amount,
        due: due,
        paidOn: on,
        clause: clause,
      );
}
