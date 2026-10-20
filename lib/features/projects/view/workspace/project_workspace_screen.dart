import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/models.dart';
import '../../viewmodel/workspace_viewmodel.dart';
import 'contract_tab.dart';
import 'files_tab.dart';
import 'negotiate_tab.dart';
import 'overview_tab.dart';
import 'payments_tab.dart';

/// Everything for one project in one place. Opened from the Projects list.
class ProjectWorkspaceScreen extends ConsumerWidget {
  const ProjectWorkspaceScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(workspaceViewModelProvider(id));
    final p = vm.project;
    if (p == null) {
      return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.search_off, title: 'Project not found', body: 'It may have been removed.'));
    }
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.canPop() ? context.pop() : context.go('/projects')),
          title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(children: [
              Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 12), child: _Header(vm: vm, p: p)),
              const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [Tab(text: 'Overview'), Tab(text: 'Contract'), Tab(text: 'Payments'), Tab(text: 'Files'), Tab(text: 'Negotiate')],
              ),
              Expanded(
                child: TabBarView(children: [
                  OverviewTab(projectId: id),
                  ContractTab(projectId: id),
                  PaymentsTab(projectId: id),
                  FilesTab(projectId: id),
                  NegotiateTab(projectId: id),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.vm, required this.p});
  final WorkspaceViewModel vm;
  final Project p;

  @override
  Widget build(BuildContext context) {
    final cream = Pf.cream.withValues(alpha: 0.75);
    Widget stat(String l, String v) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.toUpperCase(), style: monoStyle(context, size: 9.5, color: Pf.gold)),
            const SizedBox(height: 2),
            Text(v, style: const TextStyle(color: Pf.cream, fontWeight: FontWeight.w800, fontSize: 15)),
          ]),
        );
    return HeroCard(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${vm.client?.name ?? 'Client'}  ·  ${p.domain}', style: TextStyle(color: cream, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 6, children: [
                PfChip(p.status.label, color: Pf.gold, dot: true),
                if (p.isDraft) const PfChip('DRAFT', color: Pf.gold),
                if (vm.score != null) PfChip('Client: ${vm.score!.tier}', color: Pf.cream),
              ]),
            ]),
          ),
          ScoreRing(score: vm.progress * 100, size: 74, stroke: 7, color: Pf.gold, caption: 'PAID'),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          stat('Budget', inrShort(p.budget)),
          stat('Hours', '${p.actualHours.round()} / ${p.estimatedHours.round()}h'),
          stat('Due', fmtDay(p.dueDate)),
        ]),
        if (p.status != ProjectStatus.completed) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: p.status == ProjectStatus.notStarted
                  ? () {
                      vm.start();
                      toast(context, 'Project started.');
                    }
                  : () {
                      vm.complete();
                      toast(context, 'Marked as completed. It now feeds your estimates.');
                    },
              style: FilledButton.styleFrom(backgroundColor: Pf.gold, foregroundColor: Pf.ink, minimumSize: const Size.fromHeight(44)),
              icon: Icon(p.status == ProjectStatus.notStarted ? Icons.play_arrow : Icons.check_circle_outline),
              label: Text(p.status == ProjectStatus.notStarted ? 'Start project' : 'Mark as completed'),
            ),
          ),
        ],
      ]),
    );
  }
}
