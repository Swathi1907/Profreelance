import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../viewmodel/dashboard_viewmodel.dart';

/// Headline card: how much of the money across all live projects is collected.
class PortfolioProgressCard extends StatelessWidget {
  const PortfolioProgressCard({super.key, required this.vm});
  final DashboardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final cream = Pf.cream.withValues(alpha: 0.75);
    return HeroCard(
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('OVERALL PROGRESS', style: monoStyle(context, size: 10.5, color: Pf.gold)),
            const SizedBox(height: 8),
            CountUp(value: vm.collected, format: (v) => inr(v), style: const TextStyle(color: Pf.cream, fontSize: 30, fontWeight: FontWeight.w800)),
            Text('collected of ${inr(vm.contractValue)} across ${vm.live.length} live projects', style: TextStyle(color: cream, fontSize: 13)),
            const SizedBox(height: 16),
            Wrap(spacing: 18, runSpacing: 8, children: [
              _Stat('In progress', '${vm.inProgress.length}'),
              _Stat('Starting soon', '${vm.upcoming.length}'),
              _Stat('Completed', '${vm.completedCount}'),
              if (vm.draftCount > 0) _Stat('Drafts', '${vm.draftCount}'),
            ]),
          ]),
        ),
        const SizedBox(width: 16),
        ScoreRing(score: vm.progress * 100, size: 104, color: Pf.gold, caption: 'COLLECTED'),
      ]),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value);
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: const TextStyle(color: Pf.cream, fontSize: 20, fontWeight: FontWeight.w800)),
        Text(label, style: TextStyle(color: Pf.cream.withValues(alpha: 0.7), fontSize: 12)),
      ]);
}
