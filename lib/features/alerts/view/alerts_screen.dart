import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../viewmodel/alerts_viewmodel.dart';

IconData alertIcon(AlertType t) => switch (t) {
      AlertType.deadline => Icons.event_busy_outlined,
      AlertType.payment => Icons.account_balance_wallet_outlined,
      AlertType.contract => Icons.description_outlined,
      AlertType.scope => Icons.call_split,
      AlertType.estimation => Icons.speed,
    };

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(alertsViewModelProvider);
    final list = vm.visible;
    return PageBody(children: [
      PageHeader(title: 'Smart alerts', subtitle: 'Deadlines, payments, contract changes, scope creep and estimate drift, detected automatically.', actions: [
        if (vm.dismissedCount > 0) TextButton(onPressed: vm.restore, child: Text('Restore ${vm.dismissedCount} dismissed')),
      ]),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          Padding(padding: const EdgeInsets.only(right: 8), child: PfToggleChip(label: 'All (${vm.all.length})', selected: vm.type == null, onTap: () => vm.setType(null))),
          for (final t in AlertType.values)
            Padding(padding: const EdgeInsets.only(right: 8), child: PfToggleChip(label: '${AlertsViewModel.label(t)} (${vm.countOf(t)})', selected: vm.type == t, onTap: () => vm.setType(t))),
        ]),
      ),
      const SizedBox(height: 16),
      if (list.isEmpty)
        const EmptyState(icon: Icons.notifications_off_outlined, title: 'Nothing needs attention', body: 'New alerts appear when a deadline nears, a payment is late or the scope changes.')
      else
        for (var i = 0; i < list.length; i++)
          Reveal(
            delay: (i * 40).clamp(0, 300),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PfCard(
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 4, height: 64, decoration: BoxDecoration(color: severityColor(context, list[i].severity), borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 12),
                  Icon(alertIcon(list[i].type), color: severityColor(context, list[i].severity)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(list[i].title, style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(list[i].detail, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant, height: 1.35)),
                      const SizedBox(height: 8),
                      Row(children: [
                        PfChip(AlertsViewModel.label(list[i].type), color: context.cs.primary),
                        const Spacer(),
                        TextButton(onPressed: () => vm.dismiss(list[i].id), child: const Text('Dismiss')),
                        FilledButton(
                          onPressed: () => list[i].route.startsWith('/payments') ? context.go(list[i].route) : context.push(list[i].route),
                          style: FilledButton.styleFrom(minimumSize: const Size(0, 36), padding: const EdgeInsets.symmetric(horizontal: 16)),
                          child: const Text('Open'),
                        ),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
      const SizedBox(height: 20),
      const SectionTitle('Alert rules'),
      PfCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Deadline warning lead time', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(children: [
            for (final d in const [3, 7, 14]) Padding(padding: const EdgeInsets.only(right: 8), child: PfToggleChip(label: '$d days', selected: vm.leadDays == d, onTap: () => vm.setLeadDays(d))),
          ]),
          const SizedBox(height: 14),
          Text('Other rules: invoices due within 5 days or overdue; contract waiting for signature; 3 or more change requests; hours used above the estimate, or running ahead of milestone progress.', style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant, height: 1.4)),
        ]),
      ),
    ]);
  }
}
