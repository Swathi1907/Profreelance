import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/widgets.dart';
import '../../viewmodel/amendment_viewmodel.dart';
import '../wizard_scaffold.dart';
import 'step_change.dart';
import 'step_pricing.dart';
import 'step_review.dart';
import 'step_technical.dart';

/// Contract amendment: collects the technical detail of a change, prices it
/// from similar past projects, and produces a numbered amendment.
class AmendmentScreen extends ConsumerWidget {
  const AmendmentScreen({super.key, required this.projectId});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(amendmentViewModelProvider(projectId));
    if (vm.project == null) return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.search_off, title: 'Project not found', body: ''));
    final last = vm.step == AmendmentViewModel.steps.length - 1;
    final Widget body = switch (vm.step) {
      0 => StepChange(vm: vm),
      1 => StepTechnical(vm: vm),
      2 => StepPricing(vm: vm),
      _ => StepAmendReview(vm: vm),
    };
    return WizardScaffold(
      title: 'Amend: ${vm.project!.name}',
      steps: AmendmentViewModel.steps,
      step: vm.step,
      body: body,
      busy: vm.estimating,
      onBack: vm.back,
      onNext: last
          ? () {
              final id = vm.save();
              if (id == null) return;
              toast(context, 'Amendment created. The project price, deadline and payments were updated.');
              context.go('/projects/$projectId');
              context.push('/contracts/$id');
            }
          : vm.next,
      nextLabel: last ? 'Create amendment' : (vm.step == 2 ? 'Estimate impact' : 'Continue'),
    );
  }
}
