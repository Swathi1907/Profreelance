import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../viewmodel/contracts_viewmodel.dart';

Color contractStatusColor(BuildContext c, ContractStatus s) => switch (s) {
      ContractStatus.signed => c.pf.success,
      ContractStatus.amendmentPending => c.pf.warning,
      ContractStatus.sent => c.cs.primary,
      ContractStatus.draft => c.cs.onSurfaceVariant,
    };

class ContractsScreen extends ConsumerWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(contractsViewModelProvider);
    final list = vm.visible;

    Widget action(IconData icon, String title, String body, String path) => PfCard(
          onTap: () => context.push(path),
          padding: const EdgeInsets.all(18),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: context.cs.surfaceContainer, borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: context.cs.primary)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: context.tt.titleMedium),
                Text(body, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant, height: 1.35)),
              ]),
            ),
            const Icon(Icons.arrow_forward),
          ]),
        );

    return PageBody(children: [
      const PageHeader(title: 'Contracts', subtitle: 'Generate, analyse and amend agreements, with every version kept.'),
      Reveal(
        child: TileGrid(minWidth: 380, children: [
          action(Icons.auto_awesome, 'Generate a contract', 'Answer technical, commercial and legal questions. Get a full agreement with reasons for each clause.', '/contracts/new'),
          action(Icons.document_scanner_outlined, 'Analyse a client contract', 'Extract clauses, flag risks and missing terms, and explain them in plain English.', '/contracts/analyze'),
        ]),
      ),
      const SizedBox(height: 12),
      Text('To amend a contract, open the project and use Amend contract.', style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
      const SizedBox(height: 24),
      PfSelectField<String>(
        label: 'Project',
        icon: Icons.folder_outlined,
        value: vm.projectId ?? '',
        options: ['', for (final p in vm.projects) p.id],
        labelOf: (id) => id.isEmpty ? 'All projects' : vm.projectName(id),
        onSelected: (id) => vm.setProject(id.isEmpty ? null : id),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          Padding(padding: const EdgeInsets.only(right: 8), child: PfToggleChip(label: 'All', selected: vm.status == null, onTap: () => vm.setStatus(null))),
          for (final s in ContractStatus.values)
            Padding(padding: const EdgeInsets.only(right: 8), child: PfToggleChip(label: '${s.label} (${vm.count(s)})', selected: vm.status == s, onTap: () => vm.setStatus(s))),
        ]),
      ),
      const SizedBox(height: 16),
      if (list.isEmpty)
        const EmptyState(icon: Icons.description_outlined, title: 'No contracts here', body: 'Generate your first contract above.')
      else
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth >= 800 ? 2 : 1;
          final w = (c.maxWidth - (cols - 1) * 12) / cols;
          return Wrap(spacing: 12, runSpacing: 12, children: [
            for (final k in list)
              SizedBox(
                width: w,
                child: PfCard(
                  onTap: () => context.push('/contracts/${k.id}'),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(vm.projectName(k.projectId), maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleMedium)),
                      PfChip(k.status.label, color: contractStatusColor(context, k.status), dot: true),
                    ]),
                    const SizedBox(height: 4),
                    Text('${vm.clientName(k.projectId)}  ·  v${k.version}  ·  ${fmtDate(k.createdAt)}', style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
                    if (k.summary.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(k.summary, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                    const SizedBox(height: 8),
                    Text('${k.clauses.length} clauses', style: monoStyle(context, size: 10.5)),
                  ]),
                ),
              ),
          ]);
        }),
    ]);
  }
}
