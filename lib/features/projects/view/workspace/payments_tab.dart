import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/format.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../payments/view/add_milestone_sheet.dart';
import '../../../payments/view/milestone_tile.dart';
import '../../viewmodel/workspace_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';

class PaymentsTab extends ConsumerWidget {
  const PaymentsTab({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(workspaceViewModelProvider(projectId));
    final p = vm.project!;
    final ms = vm.milestones;
    return PageBody(children: [
      TileGrid(minWidth: 160, children: [
        KpiTile(label: 'Paid', icon: Icons.check_circle_outline, color: context.pf.success, value: Text(inrShort(vm.paidAmount), style: context.tt.headlineSmall)),
        KpiTile(label: 'Pending', icon: Icons.hourglass_bottom, value: Text(inrShort(vm.pendingAmount), style: context.tt.headlineSmall)),
        KpiTile(label: 'Overdue', icon: Icons.error_outline, color: context.pf.danger, value: Text(inrShort(vm.overdueAmount), style: context.tt.headlineSmall)),
      ]),
      const SizedBox(height: 20),
      SectionTitle('Milestones', subtitle: '${vm.paidCount} of ${ms.length} paid', trailing: TextButton.icon(onPressed: () => showAddMilestoneSheet(context, projectId: projectId), icon: const Icon(Icons.add), label: const Text('Add'))),
      if (ms.isEmpty)
        const PfCard(child: EmptyState(icon: Icons.flag_outlined, title: 'No milestones yet', body: 'Add the first payment milestone.'))
      else
        for (final m in ms)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: MilestoneTile(milestone: m, projectName: p.name, onPay: () => vm.markPaid(m.id)),
          ),
    ]);
  }
}
