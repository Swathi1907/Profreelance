import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/widgets.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/project_repository.dart';
import 'negotiation_panel.dart';

final selectedNegotiationProjectProvider = StateProvider<String?>((ref) => null);

/// Negotiation assistant: choose the project first, then talk it through.
class NegotiationScreen extends ConsumerWidget {
  const NegotiationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectRepositoryProvider).where((p) => !p.isDraft).toList();
    final selected = ref.watch(selectedNegotiationProjectProvider) ?? (projects.isEmpty ? null : projects.first.id);
    if (projects.isEmpty) {
      return const EmptyState(icon: Icons.forum_outlined, title: 'No projects yet', body: 'Create a project first, then negotiate its terms here.');
    }
    String nameOf(String id) => projects.firstWhere((p) => p.id == id, orElse: () => projects.first).name;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: PfSelectField<String>(
              label: 'Negotiating for project',
              icon: Icons.folder_outlined,
              value: selected,
              options: [for (final Project p in projects) p.id],
              labelOf: nameOf,
              onSelected: (id) => ref.read(selectedNegotiationProjectProvider.notifier).state = id,
            ),
          ),
          Expanded(child: NegotiationPanel(key: ValueKey(selected), projectId: selected!)),
        ]),
      ),
    );
  }
}
