import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../viewmodel/payments_viewmodel.dart';
import 'add_milestone_sheet.dart';
import 'milestone_tile.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(paymentsViewModelProvider);
    final groups = vm.grouped;
    const filters = <(String, MilestoneStatus?)>[('All', null), ('Pending', MilestoneStatus.pending), ('Overdue', MilestoneStatus.overdue), ('Paid', MilestoneStatus.paid)];

    return PageBody(children: [
      PageHeader(
        title: 'Payments',
        subtitle: 'Milestones, invoices and what is still owed, linked to contract clauses.',
        actions: [FilledButton.icon(onPressed: () => showAddMilestoneSheet(context, projectId: vm.projectId), icon: const Icon(Icons.add), label: const Text('Milestone'))],
      ),
      Reveal(
        child: TileGrid(minWidth: 190, children: [
          KpiTile(label: 'Received', icon: Icons.check_circle_outline, color: context.pf.success, value: CountUp(value: vm.received, format: inrShort, style: context.tt.headlineSmall)),
          KpiTile(label: 'Pending', icon: Icons.hourglass_bottom, value: CountUp(value: vm.pending, format: inrShort, style: context.tt.headlineSmall), hint: '${inrShort(vm.dueNext30)} due in 30 days'),
          KpiTile(label: 'Overdue', icon: Icons.error_outline, color: context.pf.danger, value: CountUp(value: vm.overdue, format: inrShort, style: context.tt.headlineSmall)),
          KpiTile(label: 'Collection rate', icon: Icons.percent, color: scoreColor(context, vm.collectionRate), value: CountUp(value: vm.collectionRate, format: (v) => '${v.round()}%', style: context.tt.headlineSmall)),
        ]),
      ),
      const SizedBox(height: 20),
      Reveal(
        delay: 80,
        child: PfCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Cash flow', style: context.tt.titleMedium),
            const SizedBox(height: 12),
            PairedBarChart(groups: [for (final m in vm.cashflow) BarGroup(m.label, m.paid, m.pending)], aLabel: 'Paid', bLabel: 'Expected'),
          ]),
        ),
      ),
      const SizedBox(height: 20),
      PfSelectField<String>(
        label: 'Project',
        value: vm.projectId ?? '',
        options: ['', for (final p in vm.projects) p.id],
        labelOf: (v) => v.isEmpty ? 'All projects' : vm.projectName(v),
        icon: Icons.folder_outlined,
        onSelected: (v) => vm.setProject(v.isEmpty ? null : v),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          for (final f in filters) Padding(padding: const EdgeInsets.only(right: 8), child: PfToggleChip(label: f.$1, selected: vm.status == f.$2, onTap: () => vm.setStatus(f.$2))),
        ]),
      ),
      const SizedBox(height: 16),
      if (groups.isEmpty)
        const EmptyState(icon: Icons.account_balance_wallet_outlined, title: 'No milestones match', body: 'Change the filters or add a milestone.')
      else
        for (final e in groups.entries) ...[
          Padding(padding: const EdgeInsets.only(top: 8, bottom: 10), child: Text(e.key, style: context.tt.titleMedium)),
          for (final m in e.value)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MilestoneTile(milestone: m, projectName: e.key, onPay: () => vm.markPaid(m.id), reminder: vm.reminderText(m)),
            ),
        ],
    ]);
  }
}
