import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../domain/services/amendment_service.dart';
import '../../viewmodel/amendment_viewmodel.dart';

class StepChange extends StatelessWidget {
  const StepChange({super.key, required this.vm});
  final AmendmentViewModel vm;

  @override
  Widget build(BuildContext context) {
    final a = vm.inputs;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PfField(label: 'Short title of the change', initial: a.title, icon: Icons.edit_note, error: vm.errors['title'], onChanged: (v) => vm.update((x) => x.title = v)),
      const FieldGap(),
      PfSelectField<String>(label: 'Type of change', value: a.changeType, options: kChangeTypes, onSelected: (v) => vm.update((x) => x.changeType = v)),
      const FieldGap(),
      PfField(
        label: 'Describe the change in detail',
        initial: a.description,
        minLines: 5,
        maxLines: 9,
        helper: 'What should it do, for whom, and what should stay the same?',
        error: vm.errors['description'],
        onChanged: (v) => vm.update((x) => x.description = v),
      ),
      const FormSectionLabel('Where it came from'),
      PfField(label: 'Requested by (name and role)', initial: a.requestedBy, onChanged: (v) => vm.update((x) => x.requestedBy = v)),
      const FieldGap(),
      PfField(label: 'Approval reference', initial: a.approvalRef, helper: 'For example: email dated 14 Oct, or ticket CR-12', onChanged: (v) => vm.update((x) => x.approvalRef = v)),
      const FieldGap(),
      PfDateField(label: 'Effective date', value: a.effectiveDate, onChanged: (d) => vm.update((x) => x.effectiveDate = d)),
      const FieldLabel('Priority'),
      ChoiceRow(options: kPriorities, value: a.priority, onChanged: (v) => vm.update((x) => x.priority = v)),
    ]);
  }
}
