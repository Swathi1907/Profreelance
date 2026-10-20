import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../viewmodel/clients_viewmodel.dart';

Color tierColor(BuildContext c, String tier) => switch (tier) {
      'Reliable' || 'Good' => c.pf.success,
      'Cautious' => c.pf.warning,
      'High risk' => c.pf.danger,
      _ => c.cs.onSurfaceVariant,
    };

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(clientsViewModelProvider);
    final x = vm.experience;
    final list = vm.visible;
    return PageBody(children: [
      const PageHeader(title: 'Clients', subtitle: 'Reliability and project experience, built from payments and your own ratings.'),
      Reveal(
        child: HeroCard(
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('OVERALL CLIENT EXPERIENCE', style: monoStyle(context, size: 10.5, color: Pf.gold)),
                const SizedBox(height: 8),
                Text(x.rated == 0 ? 'No ratings yet' : '${x.rated} clients rated', style: const TextStyle(color: Pf.cream, fontSize: 22, fontWeight: FontWeight.w800)),
                if (x.onTimeRate != null) Text('${(x.onTimeRate! * 100).round()}% of payments arrive on time', style: TextStyle(color: Pf.cream.withValues(alpha: 0.75))),
                const SizedBox(height: 12),
                Wrap(spacing: 6, runSpacing: 6, children: [for (final e in x.tiers.entries) PfChip('${e.value} ${e.key}', color: Pf.cream)]),
              ]),
            ),
            ScoreRing(score: x.average, size: 100, color: Pf.gold, caption: 'AVERAGE'),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          Padding(padding: const EdgeInsets.only(right: 8), child: PfToggleChip(label: 'All', selected: vm.tierFilter == null, onTap: () => vm.setTier(null))),
          for (final t in vm.tiers) Padding(padding: const EdgeInsets.only(right: 8), child: PfToggleChip(label: t, selected: vm.tierFilter == t, onTap: () => vm.setTier(t))),
        ]),
      ),
      const SizedBox(height: 16),
      const SectionTitle('Choose a client', subtitle: 'Open one to see their score, payments and history'),
      if (list.isEmpty)
        const EmptyState(icon: Icons.people_outline, title: 'No clients in this group', body: 'Try another filter.')
      else
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth >= 800 ? 2 : 1;
          final w = (c.maxWidth - (cols - 1) * 12) / cols;
          return Wrap(spacing: 12, runSpacing: 12, children: [
            for (final cl in list)
              SizedBox(
                width: w,
                child: PfCard(
                  onTap: () => context.push('/clients/${cl.id}'),
                  child: Row(children: [
                    CircleAvatar(radius: 22, backgroundColor: context.cs.surfaceContainer, foregroundColor: context.cs.primary, child: Text(initials(cl.name), style: const TextStyle(fontWeight: FontWeight.w800))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(cl.name, style: context.tt.titleMedium),
                        Text('${cl.industry}  ·  ${vm.projectCount(cl.id)} projects', style: context.tt.bodySmall),
                        const SizedBox(height: 6),
                        PfChip(vm.scores[cl.id]!.tier, color: tierColor(context, vm.scores[cl.id]!.tier), dot: true),
                      ]),
                    ),
                    ScoreRing(score: vm.scores[cl.id]!.overall, size: 62, stroke: 6),
                  ]),
                ),
              ),
          ]);
        }),
    ]);
  }
}
