import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../viewmodel/dashboard_viewmodel.dart';
import 'client_experience_card.dart';
import 'dashboard_lists.dart';
import 'portfolio_progress_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(dashboardViewModelProvider);
    final overdue = vm.overdue.fold<double>(0, (s, m) => s + m.amount);

    return PageBody(children: [
      PageHeader(
        title: '${greeting()}, ${vm.userName.split(' ').first}',
        subtitle: 'Here is where your freelance business stands today.',
        actions: [
          if (isWide(context)) FilledButton.icon(onPressed: () => context.push('/projects/new'), icon: const Icon(Icons.add), label: const Text('New project')),
        ],
      ),
      Reveal(child: PortfolioProgressCard(vm: vm)),
      const SizedBox(height: 16),
      Reveal(
        delay: 80,
        child: TileGrid(minWidth: 190, children: [
          KpiTile(label: 'Live projects', icon: Icons.folder_outlined, value: CountUp(value: vm.live.length.toDouble(), format: (v) => v.round().toString(), style: context.tt.headlineSmall), hint: '${vm.inProgress.length} in progress'),
          KpiTile(label: 'Outstanding', icon: Icons.hourglass_bottom, value: CountUp(value: vm.outstanding, format: inrShort, style: context.tt.headlineSmall), hint: 'unpaid milestones'),
          KpiTile(
            label: 'Overdue',
            icon: Icons.error_outline,
            color: vm.overdue.isEmpty ? context.pf.success : context.pf.danger,
            value: CountUp(value: overdue, format: inrShort, style: context.tt.headlineSmall),
            hint: '${vm.overdue.length} payments',
          ),
          KpiTile(label: 'Alerts', icon: Icons.notifications_active_outlined, color: context.pf.warning, value: CountUp(value: vm.alertCount.toDouble(), format: (v) => v.round().toString(), style: context.tt.headlineSmall), hint: 'need attention'),
        ]),
      ),
      const SizedBox(height: 16),
      Reveal(
        delay: 140,
        child: Wrap(spacing: 10, runSpacing: 10, children: [
          _Action(Icons.add_circle_outline, 'New project', () => context.push('/projects/new')),
          _Action(Icons.description_outlined, 'Generate contract', () => context.push('/contracts/new')),
          _Action(Icons.document_scanner_outlined, 'Analyse a contract', () => context.push('/contracts/analyze')),
          _Action(Icons.forum_outlined, 'Negotiation assistant', () => context.go('/negotiate')),
        ]),
      ),
      const SizedBox(height: 24),
      TwoCol(
        left: [
          SectionTitle('Your projects', subtitle: 'Tap one to open its workspace', trailing: TextButton(onPressed: () => context.go('/projects'), child: const Text('See all'))),
          Reveal(delay: 200, child: ActiveProjectsList(vm: vm)),
          const SizedBox(height: 24),
          const SectionTitle('Cash flow', subtitle: 'Paid and expected, by month'),
          Reveal(
            delay: 260,
            child: PfCard(child: PairedBarChart(groups: [for (final m in vm.cashflow) BarGroup(m.label, m.paid, m.pending)], aLabel: 'Paid', bLabel: 'Pending')),
          ),
        ],
        right: [
          const SectionTitle('Client experience', subtitle: 'Reliability across all clients'),
          Reveal(delay: 200, child: ClientExperienceCard(vm: vm)),
          const SizedBox(height: 24),
          const SectionTitle('Next deadlines'),
          Reveal(delay: 260, child: DeadlinesCard(vm: vm)),
          const SizedBox(height: 24),
          const SectionTitle('Priority alerts'),
          Reveal(delay: 320, child: PriorityAlerts(vm: vm)),
        ],
      ),
    ]);
  }
}

class _Action extends StatelessWidget {
  const _Action(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(backgroundColor: context.cs.surfaceContainerLowest, side: BorderSide(color: context.pf.cardLine)),
      );
}
