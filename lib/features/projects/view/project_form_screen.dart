import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../viewmodel/project_form_viewmodel.dart';
import 'form/basics_section.dart';
import 'form/estimation_section.dart';
import 'form/preferences_section.dart';
import 'form/scope_section.dart';
import 'form/technical_section.dart';

/// "Create New Project", laid out like the Kotlin screen: brand header with a
/// close button, five labelled sections, a review card and two actions.
class ProjectFormScreen extends ConsumerWidget {
  const ProjectFormScreen({super.key});

  void _finish(BuildContext context, ProjectFormViewModel vm, {required bool draft}) {
    final id = vm.save(draft: draft);
    if (id == null) {
      toast(context, 'Please fix the highlighted fields.');
      return;
    }
    toast(context, draft ? 'Draft saved.' : 'Project created.');
    context.go('/projects');
    context.push('/projects/$id');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(projectFormViewModelProvider);
    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
              children: [
                Row(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/logo.jpg', width: 34, height: 34)),
                  const SizedBox(width: 10),
                  Expanded(child: Text('FreelancePro', style: context.tt.titleLarge)),
                  IconButton(onPressed: () => context.pop(), icon: Icon(Icons.close, color: context.cs.primary)),
                ]),
                const SizedBox(height: 28),
                Text('Create New Project', style: context.tt.displaySmall?.copyWith(fontSize: 34)),
                const SizedBox(height: 8),
                Text('Set up the project details required for contracts, estimation, and AI analysis.',
                    style: context.tt.bodyLarge?.copyWith(color: context.cs.primary, height: 1.4)),
                BasicsSection(vm: vm),
                ScopeSection(vm: vm),
                EstimationSection(vm: vm),
                PreferencesSection(vm: vm),
                TechnicalSection(vm: vm),
                const SizedBox(height: 30),
                _ReviewCard(vm: vm),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => _finish(context, vm, draft: false),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  child: const Text('Create Project', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 4),
                TextButton(onPressed: () => _finish(context, vm, draft: true), child: const Text('Save as Draft')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.vm});
  final ProjectFormViewModel vm;

  @override
  Widget build(BuildContext context) {
    return PfCard(
      padding: const EdgeInsets.all(18),
      color: context.isDark ? context.cs.surfaceContainerLowest : const Color(0xFFFFF9F3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Before you create', style: context.tt.titleMedium),
        const SizedBox(height: 6),
        Text('Your project information will be used to generate contract terms and provide AI-based project analysis.',
            style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant, height: 1.4)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Text(vm.title.isEmpty ? 'Project' : vm.title, maxLines: 2, overflow: TextOverflow.ellipsis)),
          Text(vm.reviewBudget, style: TextStyle(color: context.cs.primary, fontWeight: FontWeight.w800)),
        ]),
      ]),
    );
  }
}
