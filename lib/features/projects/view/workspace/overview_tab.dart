import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../viewmodel/workspace_viewmodel.dart';

class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(workspaceViewModelProvider(projectId));
    final p = vm.project!;
    final fh = vm.forecastHours;

    Widget kv(String k, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 130, child: MonoLabel(k)),
            Expanded(child: Text(v.isEmpty ? '-' : v, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
          ]),
        );

    return PageBody(children: [
      TwoCol(
        left: [
          PfCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Project details', style: context.tt.titleMedium),
              const SizedBox(height: 8),
              kv('Domain', '${p.domain}${p.subDomain.isEmpty ? '' : '  ·  ${p.subDomain}'}'),
              kv('Objective', p.objective),
              kv('Description', p.description),
              kv('Deliverables', p.deliverables),
              kv('Not included', p.exclusions),
              kv('Duration', p.durationValue > 0 ? '${p.durationValue} ${p.durationUnit.toLowerCase()}' : '${p.dueDate.difference(p.startDate).inDays} days'),
              kv('Complexity', complexityLabelOf(p.complexity)),
              if (p.techStack.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, children: [for (final t in p.techStack) PfChip(t, color: context.cs.primary)]),
              ],
              if (p.technicalComponents.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(spacing: 6, runSpacing: 6, children: [for (final t in p.technicalComponents) PfChip(t, color: context.cs.onSurfaceVariant)]),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          PfCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Contract terms', style: context.tt.titleMedium),
              const SizedBox(height: 8),
              kv('Payment', p.paymentStructure),
              kv('Advance', '${p.advancePct.toStringAsFixed(0)}%'),
              kv('Revisions', '${p.revisions} rounds'),
              kv('IP ownership', p.ipOwnership),
              kv('Jurisdiction', p.jurisdiction),
              kv('NDA', p.nda ? 'Required' : 'Not required'),
              kv('Change requests', '${p.changeRequests} so far'),
            ]),
          ),
        ],
        right: [
          PfCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Effort', style: context.tt.titleMedium),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: AnimatedBar(value: vm.burn.clamp(0, 1), color: vm.burn > 1 ? context.pf.danger : context.cs.primary, height: 10)),
                const SizedBox(width: 10),
                Text('${(vm.burn * 100).round()}%', style: monoStyle(context, size: 11)),
              ]),
              const SizedBox(height: 8),
              Text('${p.actualHours.round()}h used of ${p.estimatedHours.round()}h estimated', style: context.tt.bodySmall),
              if (fh != null) ...[
                const SizedBox(height: 10),
                Text(
                  'At the current pace this finishes around ${fh.round()}h (${fh > p.estimatedHours ? '+' : ''}${((fh / p.estimatedHours - 1) * 100).round()}% vs estimate).',
                  style: context.tt.bodySmall?.copyWith(color: fh > p.estimatedHours * 1.1 ? context.pf.warning : context.pf.success, fontWeight: FontWeight.w600),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          if (vm.client != null && vm.score != null)
            PfCard(
              onTap: () => context.push('/clients/${vm.client!.id}'),
              child: Row(children: [
                ScoreRing(score: vm.score!.overall, size: 70, stroke: 7),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(vm.client!.name, style: context.tt.titleMedium),
                    Text('${vm.score!.tier} client', style: context.tt.bodySmall),
                    const SizedBox(height: 4),
                    Text(vm.score!.recommendation, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
                  ]),
                ),
                const Icon(Icons.chevron_right),
              ]),
            ),
        ],
      ),
    ]);
  }

  String complexityLabelOf(int c) => c <= 2 ? 'Basic' : (c <= 3 ? 'Intermediate' : 'Advanced');
}
