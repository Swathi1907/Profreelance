import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/models.dart';

/// Card matching the Kotlin app's project item: icon tile, name, mono labels
/// (CLIENT / DATE / STATUS), milestone progress and a start button.
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.clientName,
    required this.paid,
    required this.total,
    required this.onOpen,
    required this.onStart,
  });

  final Project project;
  final String clientName;
  final int paid;
  final int total;
  final VoidCallback onOpen;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final color = statusColor(context, project.status);
    final pct = total == 0 ? 0.0 : paid / total;
    Widget col(String label, Widget value) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [MonoLabel(label), const SizedBox(height: 4), value]),
        );
    return PfCard(
      onTap: onOpen,
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: context.cs.surfaceContainer, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.folder_outlined, color: context.cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(project.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.titleMedium),
              Text(project.domain, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
            ]),
          ),
          if (project.isDraft) PfChip('DRAFT', color: context.pf.warning) else Icon(Icons.chevron_right, color: context.cs.onSurfaceVariant),
        ]),
        const SizedBox(height: 16),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          col('Client', Text(clientName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
          col('Due', Text(fmtDate(project.dueDate), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
          col(
            'Status',
            Row(children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Flexible(child: Text(project.status.label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11))),
            ]),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: AnimatedBar(value: pct, color: color)),
          const SizedBox(width: 12),
          Text('${(pct * 100).round()}%', style: monoStyle(context, size: 11)),
        ]),
        const SizedBox(height: 6),
        Text('$paid of $total milestones paid', style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
        if (project.status == ProjectStatus.notStarted) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: onStart, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)), child: const Text('Start Project')),
          ),
        ],
      ]),
    );
  }
}
