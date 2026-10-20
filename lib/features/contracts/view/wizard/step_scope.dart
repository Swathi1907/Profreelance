import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../domain/services/contract_inputs.dart';
import '../../viewmodel/contract_wizard_viewmodel.dart';

class StepScope extends StatelessWidget {
  const StepScope({super.key, required this.vm});
  final ContractWizardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final i = vm.inputs!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const FormSectionLabel('Deliverables'),
      PfField(label: 'Deliverables', initial: i.deliverables, minLines: 4, maxLines: 8, helper: 'One per line', error: vm.errors['deliverables'], onChanged: (v) => vm.update((x) => x.deliverables = v)),
      const FieldGap(),
      PfField(
        label: 'Acceptance criteria',
        initial: i.acceptanceCriteria,
        minLines: 3,
        maxLines: 6,
        helper: 'Measurable: for example "all 42 test cases pass on Android 9 and above"',
        error: vm.errors['acceptance'],
        onChanged: (v) => vm.update((x) => x.acceptanceCriteria = v),
      ),
      const FieldGap(),
      PfField(label: 'Out of scope', initial: i.outOfScope, minLines: 2, maxLines: 5, onChanged: (v) => vm.update((x) => x.outOfScope = v)),
      const FieldGap(),
      PfField(label: 'Assumptions', initial: i.assumptions, minLines: 2, maxLines: 5, helper: 'For example: client provides the final copy by week 2', onChanged: (v) => vm.update((x) => x.assumptions = v)),
      const FieldLabel('Client responsibilities'),
      ChipMultiSelect(options: kClientDuties, selected: i.clientDuties, onToggle: (v) => vm.toggle(i.clientDuties, v)),
      const FormSectionLabel('Technical specification'),
      PfField(label: 'Technology stack', initial: i.techStack, onChanged: (v) => vm.update((x) => x.techStack = v)),
      const FieldLabel('Environments delivered'),
      ChipMultiSelect(options: kEnvironments, selected: i.environments, onToggle: (v) => vm.toggle(i.environments, v)),
      const FieldGap(),
      PfField(label: 'Supported platforms and versions', initial: i.platforms, helper: 'For example: Android 9+, Chrome and Safari latest 2 versions', onChanged: (v) => vm.update((x) => x.platforms = v)),
      const FieldGap(),
      PfField(label: 'Performance targets', initial: i.performanceTargets, helper: 'For example: screens load in under 2 s on 4G', onChanged: (v) => vm.update((x) => x.performanceTargets = v)),
      const FieldLabel('Security requirements'),
      ChipMultiSelect(options: kSecurityOptions, selected: i.security, onToggle: (v) => vm.toggle(i.security, v)),
      const FieldLabel('Testing scope'),
      ChipMultiSelect(options: kTestingOptions, selected: i.testing, onToggle: (v) => vm.toggle(i.testing, v)),
      const FieldLabel('Documentation delivered'),
      ChipMultiSelect(options: kDocOptions, selected: i.documentation, onToggle: (v) => vm.toggle(i.documentation, v)),
      const FieldGap(),
      PfSelectField<String>(label: 'Hosting', value: i.hosting, options: kHostingOptions, onSelected: (v) => vm.update((x) => x.hosting = v)),
      const FieldGap(),
      PfSelectField<String>(label: 'Third-party service costs', value: i.thirdPartyCosts, options: kThirdPartyCosts, onSelected: (v) => vm.update((x) => x.thirdPartyCosts = v)),
      const FieldGap(),
      PfSelectField<String>(label: 'Source code delivery', value: i.sourceDelivery, options: kSourceDelivery, onSelected: (v) => vm.update((x) => x.sourceDelivery = v)),
    ]);
  }
}
