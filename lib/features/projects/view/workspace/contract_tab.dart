import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/format.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/models.dart';
import '../../viewmodel/workspace_viewmodel.dart';
import '../../../../core/theme/app_colors.dart';

class ContractTab extends ConsumerWidget {
  const ContractTab({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(workspaceViewModelProvider(projectId));
    final list = vm.contracts;
    return PageBody(children: [
      Wrap(spacing: 10, runSpacing: 10, children: [
        FilledButton.icon(onPressed: () => context.push('/contracts/new?project=$projectId'), icon: const Icon(Icons.description_outlined), label: const Text('Generate contract')),
        OutlinedButton.icon(
          onPressed: list.isEmpty ? () => toast(context, 'Generate or import a contract first.') : () => context.push('/projects/$projectId/amend'),
          icon: const Icon(Icons.edit_note),
          label: const Text('Amend contract'),
        ),
        OutlinedButton.icon(onPressed: () => context.push('/contracts/analyze?project=$projectId'), icon: const Icon(Icons.document_scanner_outlined), label: const Text('Analyse client contract')),
      ]),
      const SizedBox(height: 20),
      const SectionTitle('Contract versions'),
      if (list.isEmpty)
        const PfCard(child: EmptyState(icon: Icons.description_outlined, title: 'No contract yet', body: 'Generate one from this project\'s details, or analyse the one your client sent.'))
      else
        for (final c in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PfCard(
              onTap: () => context.push('/contracts/${c.id}'),
              child: Row(children: [
                const Icon(Icons.description_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Version ${c.version}', style: context.tt.titleMedium),
                    Text('${fmtDate(c.createdAt)}${c.summary.isEmpty ? '' : '  ·  ${c.summary}'}', maxLines: 2, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall),
                  ]),
                ),
                PfChip(c.status.label, color: _color(context, c.status), dot: true),
              ]),
            ),
          ),
    ]);
  }

  Color _color(BuildContext c, ContractStatus s) => switch (s) {
        ContractStatus.signed => c.pf.success,
        ContractStatus.amendmentPending => c.pf.warning,
        ContractStatus.sent => c.cs.primary,
        ContractStatus.draft => c.cs.onSurfaceVariant,
      };
}
