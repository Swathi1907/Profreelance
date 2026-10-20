import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../viewmodel/contracts_viewmodel.dart';
import 'contracts_screen.dart';

class ContractViewScreen extends ConsumerWidget {
  const ContractViewScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(contractViewModelProvider(id));
    final c = vm.contract;
    if (c == null) return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.search_off, title: 'Contract not found', body: ''));
    final h = vm.health;

    return Scaffold(
      appBar: AppBar(title: Text('Version ${c.version}'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.canPop() ? context.pop() : context.go('/contracts'))),
      body: PageBody(maxWidth: 860, children: [
        HeroCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(c.title.isEmpty ? 'Agreement' : c.title, style: const TextStyle(color: Pf.cream, fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('${vm.project?.name ?? ''}  ·  ${fmtDate(c.createdAt)}  ·  ${c.clauses.length} clauses', style: TextStyle(color: Pf.cream.withValues(alpha: 0.75))),
            if (c.summary.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(c.summary, style: const TextStyle(color: Pf.gold, fontWeight: FontWeight.w700))),
            const SizedBox(height: 12),
            PfChip(c.status.label, color: Pf.gold, dot: true),
          ]),
        ),
        const SizedBox(height: 16),
        Wrap(spacing: 10, runSpacing: 10, children: [
          if (c.status == ContractStatus.draft)
            FilledButton.icon(onPressed: () => vm.setStatus(ContractStatus.sent), icon: const Icon(Icons.send_outlined), label: const Text('Mark as sent')),
          if (c.status == ContractStatus.sent || c.status == ContractStatus.amendmentPending)
            FilledButton.icon(onPressed: () => vm.setStatus(ContractStatus.signed), icon: const Icon(Icons.draw_outlined), label: const Text('Mark as signed')),
          OutlinedButton.icon(
            onPressed: () async {
              await vm.copy();
              if (context.mounted) toast(context, 'Contract text copied.');
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy text'),
          ),
          OutlinedButton.icon(onPressed: vm.runHealthCheck, icon: const Icon(Icons.verified_outlined), label: const Text('Run risk check')),
          OutlinedButton.icon(onPressed: () => context.push('/projects/${c.projectId}/amend'), icon: const Icon(Icons.edit_note), label: const Text('Amend')),
        ]),
        if (h != null) ...[
          const SizedBox(height: 16),
          PfCard(
            child: Row(children: [
              ScoreRing(score: 100 - h.risk.toDouble(), size: 72, stroke: 7, caption: 'HEALTH'),
              const SizedBox(width: 14),
              Expanded(child: Text('${h.level}: ${h.flags.length} risky clauses, ${h.missing.length} missing terms.', style: const TextStyle(fontWeight: FontWeight.w700))),
            ]),
          ),
        ],
        const SizedBox(height: 24),
        const SectionTitle('Clauses'),
        for (var i = 0; i < c.clauses.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PfCard(
              padding: EdgeInsets.zero,
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text('${i + 1}. ${c.clauses[i].title}', style: const TextStyle(fontWeight: FontWeight.w700)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.clauses[i].body, style: const TextStyle(height: 1.5)),
                  if (c.clauses[i].rationale.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('Why: ${c.clauses[i].rationale}', style: context.tt.bodySmall?.copyWith(color: context.cs.primary, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
          ),
        if (vm.versions.length > 1) ...[
          const SizedBox(height: 16),
          const SectionTitle('Version history'),
          for (final v in vm.versions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PfCard(
                onTap: v.id == c.id ? null : () => context.pushReplacement('/contracts/${v.id}'),
                child: Row(children: [
                  Expanded(child: Text('Version ${v.version}  ·  ${fmtDate(v.createdAt)}${v.id == c.id ? '  (viewing)' : ''}', style: const TextStyle(fontWeight: FontWeight.w600))),
                  PfChip(v.status.label, color: contractStatusColor(context, v.status), dot: true),
                ]),
              ),
            ),
        ],
      ]),
    );
  }
}
