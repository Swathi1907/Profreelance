import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../viewmodel/insights_viewmodel.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(insightsViewModelProvider);
    final s = vm.s;
    if (!vm.hasHistory) {
      return const EmptyState(icon: Icons.insights_outlined, title: 'No finished projects yet', body: 'Complete a project and your performance analytics will appear here.');
    }
    return PageBody(children: [
      const PageHeader(title: 'Performance insights', subtitle: 'How accurate, fast and profitable your work has been.'),
      Reveal(
        child: HeroCard(
          child: Row(children: [
            ScoreRing(score: s.estimationAccuracy, size: 100, color: Pf.gold, caption: 'ACCURACY'),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ESTIMATION ACCURACY', style: monoStyle(context, size: 10.5, color: Pf.gold)),
                const SizedBox(height: 6),
                Text('Across ${s.completed.length} finished projects', style: const TextStyle(color: Pf.cream, fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(vm.biasNote, style: TextStyle(color: Pf.cream.withValues(alpha: 0.8), height: 1.4)),
              ]),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      Reveal(
        delay: 80,
        child: TileGrid(minWidth: 190, children: [
          KpiTile(label: 'Avg duration', icon: Icons.timelapse, value: CountUp(value: s.avgDurationDays, format: (v) => '${v.round()} days', style: context.tt.headlineSmall)),
          KpiTile(label: 'Avg earnings', icon: Icons.payments_outlined, value: CountUp(value: s.avgEarnings, format: inrShort, style: context.tt.headlineSmall), hint: 'per project'),
          KpiTile(label: 'On-time delivery', icon: Icons.flag_outlined, color: scoreColor(context, s.onTimeRate), value: CountUp(value: s.onTimeRate, format: (v) => '${v.round()}%', style: context.tt.headlineSmall)),
          KpiTile(label: 'Total earned', icon: Icons.savings_outlined, color: context.pf.success, value: CountUp(value: s.totalEarned, format: inrShort, style: context.tt.headlineSmall), hint: '${inrShort(s.outstanding)} outstanding'),
        ]),
      ),
      const SizedBox(height: 24),
      TwoCol(
        left: [
          const SectionTitle('Estimated vs actual hours', subtitle: 'Per finished project'),
          PfCard(child: PairedBarChart(groups: vm.estimateVsActual, aLabel: 'Estimated', bLabel: 'Actual', money: false)),
          const SizedBox(height: 24),
          const SectionTitle('Cash flow', subtitle: 'Paid and expected by month'),
          PfCard(child: PairedBarChart(groups: [for (final m in s.cashflow) BarGroup(m.label, m.paid, m.pending)], aLabel: 'Paid', bLabel: 'Expected')),
        ],
        right: [
          const SectionTitle('Most used technologies'),
          PfCard(child: HBarList(entries: vm.topTech)),
          const SizedBox(height: 24),
          const SectionTitle('Domains you work in'),
          PfCard(child: HBarList(entries: vm.topDomains, color: context.pf.warning)),
        ],
      ),
    ]);
  }
}
