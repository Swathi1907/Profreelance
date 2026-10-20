import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../viewmodel/vault_viewmodel.dart';
import 'add_doc_sheet.dart';
import 'doc_tile.dart';

class VaultScreen extends ConsumerWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(vaultViewModelProvider);
    final docs = vm.visible;
    return PageBody(children: [
      PageHeader(
        title: 'Document vault',
        subtitle: 'Requirements, proposals, invoices, briefs, designs and deliverables, linked to projects.',
        actions: [FilledButton.icon(onPressed: () => showAddDocSheet(context, projectId: vm.projectId), icon: const Icon(Icons.upload_file), label: const Text('Add file'))],
      ),
      PfCard(
        child: Row(children: [
          Icon(Icons.lock_outline, color: context.pf.success),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Encrypted at rest', style: TextStyle(fontWeight: FontWeight.w800)),
              Text('${formatSize(vm.usedKb)} of 5 GB used  ·  ${vm.all.length} files', style: context.tt.bodySmall),
              const SizedBox(height: 8),
              AnimatedBar(value: vm.usedFraction, height: 6),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      TextField(onChanged: vm.setQuery, decoration: const InputDecoration(hintText: 'Search files, tags or projects', prefixIcon: Icon(Icons.search))),
      const SizedBox(height: 12),
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
          Padding(padding: const EdgeInsets.only(right: 8), child: PfToggleChip(label: 'All', selected: vm.category == null, onTap: () => vm.setCategory(null))),
          for (final c in DocCategory.values)
            Padding(padding: const EdgeInsets.only(right: 8), child: PfToggleChip(label: '${c.label} (${vm.countIn(c)})', selected: vm.category == c, onTap: () => vm.setCategory(c))),
        ]),
      ),
      const SizedBox(height: 16),
      if (docs.isEmpty)
        const EmptyState(icon: Icons.inventory_2_outlined, title: 'No files found', body: 'Try another filter, or add a file.')
      else
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth >= 800 ? 2 : 1;
          final w = (c.maxWidth - (cols - 1) * 12) / cols;
          return Wrap(spacing: 12, runSpacing: 12, children: [for (final d in docs) SizedBox(width: w, child: DocTile(doc: d, projectName: vm.projectName(d.projectId)))]);
        }),
    ]);
  }
}
