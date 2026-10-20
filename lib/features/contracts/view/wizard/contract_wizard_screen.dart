import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/models/models.dart';
import '../../viewmodel/contract_wizard_viewmodel.dart';
import '../wizard_scaffold.dart';
import 'step_commercial.dart';
import 'step_legal.dart';
import 'step_parties.dart';
import 'step_review.dart';
import 'step_scope.dart';

class ContractWizardScreen extends ConsumerWidget {
  const ContractWizardScreen({super.key, this.projectId});
  final String? projectId;

  void _save(BuildContext context, ContractWizardViewModel vm, ContractStatus status) {
    final id = vm.save(status);
    if (id == null) return;
    toast(context, status == ContractStatus.draft ? 'Draft saved.' : 'Contract saved and marked as sent.');
    context.go('/contracts');
    context.push('/contracts/$id');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(contractWizardViewModelProvider(projectId ?? ''));
    final last = vm.step == ContractWizardViewModel.steps.length - 1;
    final Widget body = switch (vm.step) {
      0 => StepParties(vm: vm),
      1 => StepScope(vm: vm),
      2 => StepCommercial(vm: vm),
      3 => StepLegal(vm: vm),
      _ => StepReview(vm: vm),
    };
    return WizardScaffold(
      title: 'Generate contract',
      steps: ContractWizardViewModel.steps,
      step: vm.step,
      bodyKey: '${vm.projectId}-${vm.step}',
      body: body,
      onBack: vm.back,
      onNext: last ? () => _save(context, vm, ContractStatus.sent) : vm.next,
      nextLabel: last ? 'Save and mark as sent' : 'Continue',
      extra: last ? OutlinedButton(onPressed: () => _save(context, vm, ContractStatus.draft), child: const Text('Save draft')) : null,
    );
  }
}
