import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../viewmodel/vault_viewmodel.dart';

IconData docIcon(String name) {
  final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
  return switch (ext) {
    'pdf' => Icons.picture_as_pdf_outlined,
    'fig' || 'png' || 'jpg' || 'svg' => Icons.palette_outlined,
    'xlsx' || 'csv' => Icons.table_chart_outlined,
    'zip' => Icons.folder_zip_outlined,
    'yaml' || 'json' => Icons.data_object,
    'docx' || 'doc' || 'txt' || 'md' => Icons.article_outlined,
    _ => Icons.insert_drive_file_outlined,
  };
}

class DocTile extends ConsumerWidget {
  const DocTile({super.key, required this.doc, required this.projectName});
  final VaultDoc doc;
  final String projectName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PfCard(
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: context.cs.surfaceContainer, borderRadius: BorderRadius.circular(12)),
          child: Icon(docIcon(doc.name), color: context.cs.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(doc.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('$projectName  ·  ${formatSize(doc.sizeKb)}  ·  ${fmtDay(doc.addedAt)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 4, children: [
              PfChip(doc.category.label, color: context.cs.primary),
              for (final t in doc.tags) PfChip('#$t', color: context.cs.onSurfaceVariant),
            ]),
          ]),
        ),
        PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'delete') {
              ref.read(vaultViewModelProvider).remove(doc.id);
              toast(context, 'Removed ${doc.name}.');
            } else {
              toast(context, 'Download starts from Supabase Storage in the connected app.');
            }
          },
          itemBuilder: (_) => const [PopupMenuItem(value: 'download', child: Text('Download')), PopupMenuItem(value: 'delete', child: Text('Delete'))],
        ),
      ]),
    );
  }
}
