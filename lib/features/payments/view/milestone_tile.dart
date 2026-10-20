import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/models.dart';

class MilestoneTile extends StatelessWidget {
  const MilestoneTile({super.key, required this.milestone, required this.projectName, required this.onPay, this.reminder});
  final Milestone milestone;
  final String projectName;
  final VoidCallback onPay;
  final String? reminder;

  @override
  Widget build(BuildContext context) {
    final m = milestone;
    final st = m.statusAt(DateTime.now());
    final color = switch (st) {
      MilestoneStatus.paid => context.pf.success,
      MilestoneStatus.overdue => context.pf.danger,
      MilestoneStatus.pending => context.pf.warning,
    };
    final label = switch (st) { MilestoneStatus.paid => 'Paid', MilestoneStatus.overdue => 'Overdue', MilestoneStatus.pending => 'Pending' };
    return PfCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(st == MilestoneStatus.paid ? Icons.check : (st == MilestoneStatus.overdue ? Icons.priority_high : Icons.schedule), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.title, style: context.tt.titleMedium),
              Text('$projectName${m.clause.isEmpty ? '' : '  ·  Clause ${m.clause}'}', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(inr(m.amount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 4),
            PfChip(label, color: color, dot: true),
          ]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.event_outlined, size: 15, color: context.cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              m.paidOn != null ? 'Paid ${fmtDate(m.paidOn!)}${m.paidLateDays > 0 ? ' (${m.paidLateDays} days late)' : ''}' : 'Due ${fmtDate(m.due)} (${relDays(m.due)})',
              style: context.tt.bodySmall,
            ),
          ),
          if (st != MilestoneStatus.paid) ...[
            if (reminder != null)
              TextButton.icon(
                onPressed: () => _showReminder(context),
                icon: const Icon(Icons.notifications_active_outlined, size: 16),
                label: const Text('Remind'),
              ),
            FilledButton(onPressed: onPay, style: FilledButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 16)), child: const Text('Mark paid')),
          ],
        ]),
      ]),
    );
  }

  void _showReminder(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment reminder draft'),
        content: SingleChildScrollView(child: SelectableText(reminder!)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          FilledButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: reminder!));
              Navigator.pop(ctx);
              toast(context, 'Reminder copied.');
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}
