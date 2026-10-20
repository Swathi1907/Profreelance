import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../viewmodel/projects_viewmodel.dart';
import 'project_card.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(projectsViewModelProvider);
    final list = vm.visible;
    final wide = MediaQuery.sizeOf(context).width >= 900;

    Widget cardOf(int i) => Reveal(
          delay: (i * 50).clamp(0, 400),
          child: ProjectCard(
            project: list[i],
            clientName: vm.clientName(list[i]),
            paid: vm.paidCount(list[i]),
            total: vm.milestones(list[i]).length,
            onOpen: () => context.push('/projects/${list[i].id}'),
            onStart: () {
              vm.start(list[i].id);
              toast(context, '${list[i].name} started.');
            },
          ),
        );

    return Stack(children: [
      PageBody(children: [
        const PageHeader(title: 'Projects Directory', subtitle: 'Choose a project to open its workspace: contract, payments, files and negotiation.'),
        Row(children: [
          Expanded(
            child: TextField(
              onChanged: vm.setQuery,
              decoration: const InputDecoration(hintText: 'Search by project, client or domain', prefixIcon: Icon(Icons.search)),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: context.isDark ? Pf.gold : Pf.maroon,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final s = await showOptionSheet<ProjectSort>(context, title: 'Sort by', options: ProjectSort.values, selected: vm.sort, labelOf: (x) => x.label);
                if (s != null) vm.setSort(s);
              },
              child: SizedBox(width: 54, height: 54, child: Icon(Icons.tune, color: context.isDark ? Pf.ink : Colors.white)),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            for (var i = 0; i < ProjectsViewModel.tabs.length; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: PfToggleChip(label: '${ProjectsViewModel.tabs[i]} (${vm.count(i)})', selected: vm.tab == i, onTap: () => vm.setTab(i)),
              ),
          ]),
        ),
        const SizedBox(height: 16),
        Text('${list.length} project${list.length == 1 ? '' : 's'}  ·  sorted by ${vm.sort.label.toLowerCase()}', style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
        const SizedBox(height: 12),
        if (list.isEmpty)
          EmptyState(
            icon: Icons.folder_open,
            title: 'No projects here',
            body: vm.query.isEmpty ? 'Create your first project to get started.' : 'Nothing matches "${vm.query}".',
            action: FilledButton(onPressed: () => context.push('/projects/new'), child: const Text('New project')),
          )
        else if (wide)
          LayoutBuilder(builder: (context, c) {
            final w = (c.maxWidth - 16) / 2;
            return Wrap(spacing: 16, runSpacing: 16, children: [for (var i = 0; i < list.length; i++) SizedBox(width: w, child: cardOf(i))]);
          })
        else
          Column(children: [for (var i = 0; i < list.length; i++) Padding(padding: const EdgeInsets.only(bottom: 14), child: cardOf(i))]),
      ]),
      Positioned(
        right: 20,
        bottom: 20,
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/projects/new'),
          backgroundColor: context.isDark ? Pf.gold : Pf.maroon,
          foregroundColor: context.isDark ? Pf.ink : Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('New Project', style: TextStyle(fontWeight: FontWeight.w800)),
        ),
      ),
    ]);
  }
}
