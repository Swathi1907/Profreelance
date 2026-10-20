import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../vault/view/add_doc_sheet.dart';
import '../../../vault/view/doc_tile.dart';
import '../../viewmodel/workspace_viewmodel.dart';

class FilesTab extends ConsumerWidget {
  const FilesTab({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(workspaceViewModelProvider(projectId));
    final docs = vm.docs;
    return PageBody(children: [
      SectionTitle('Project files', subtitle: '${docs.length} stored in the vault', trailing: FilledButton.icon(onPressed: () => showAddDocSheet(context, projectId: projectId), icon: const Icon(Icons.upload_file), label: const Text('Add file'))),
      if (docs.isEmpty)
        const PfCard(child: EmptyState(icon: Icons.inventory_2_outlined, title: 'No files yet', body: 'Store requirements, invoices, designs and deliverables here.'))
      else
        for (final d in docs) Padding(padding: const EdgeInsets.only(bottom: 10), child: DocTile(doc: d, projectName: vm.project!.name)),
    ]);
  }
}
