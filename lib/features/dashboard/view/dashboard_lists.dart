import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../viewmodel/dashboard_viewmodel.dart';

class ActiveProjectsList extends StatelessWidget {
  const ActiveProjectsList({super.key, required this.vm});
  final DashboardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final list = vm.live;
    if (list.isEmpty) {
      return const PfCard(child: EmptyState(icon: Icons.folder_open, title: 'No live projects', body: 'Create a project to see its progress here.'));
    }
    return PfCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        for (var i = 0; i < list.length; i++) ...[
          if (i > 0) const Divider(),
          InkWell(
            onTap: () => context.push('/projects/${list[i].id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(list[i].name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
                  PfChip(list[i].status.label, color: statusColor(context, list[i].status), dot: true),
                ]),
                const SizedBox(height: 4),
                Text('${vm.clientName(list[i].clientId)}  ·  due ${fmtDay(list[i].dueDate)}', style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: AnimatedBar(value: vm.projectProgress(list[i]), color: statusColor(context, list[i].status))),
                  const SizedBox(width: 10),
                  Text('${(vm.projectProgress(list[i]) * 100).round()}%', style: monoStyle(context, size: 11)),
                ]),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

class DeadlinesCard extends StatelessWidget {
  const DeadlinesCard({super.key, required this.vm});
  final DashboardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = vm.nextDeadlines;
    return PfCard(
      child: l.isEmpty
          ? const Text('No deadlines coming up.')
          : Column(children: [
              for (final p in l)
                InkWell(
                  onTap: () => context.push('/projects/${p.id}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      Container(
                        width: 46,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(color: context.cs.surfaceContainer, borderRadius: BorderRadius.circular(10)),
                        child: Column(children: [
                          Text('${p.dueDate.day}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                          Text(fmtDay(p.dueDate).split(' ').last.toUpperCase(), style: monoStyle(context, size: 9)),
                        ]),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(relDays(p.dueDate), style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
                      ])),
                    ]),
                  ),
                ),
            ]),
    );
  }
}

class PriorityAlerts extends StatelessWidget {
  const PriorityAlerts({super.key, required this.vm});
  final DashboardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = vm.topAlerts;
    return PfCard(
      child: l.isEmpty
          ? const Text('All clear. No alerts right now.')
          : Column(children: [
              for (final a in l)
                InkWell(
                  onTap: () => context.go(a.route.startsWith('/projects/') || a.route.startsWith('/contracts/') ? '/alerts' : a.route),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: 4, height: 38, decoration: BoxDecoration(color: severityColor(context, a.severity), borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 12),
                      Expanded(child: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5))),
                    ]),
                  ),
                ),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => context.go('/alerts'), child: Text('All ${vm.alertCount} alerts'))),
            ]),
    );
  }
}
