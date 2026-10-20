import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../viewmodel/project_form_viewmodel.dart';

class ScopeSection extends StatelessWidget {
  const ScopeSection({super.key, required this.vm});
  final ProjectFormViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const FormSectionLabel('Scope of work'),
      PfField(label: 'Deliverables', initial: vm.deliverables, minLines: 5, maxLines: 8, helper: 'Add one deliverable per line', onChanged: (v) => vm.update(() => vm.deliverables = v)),
      const FieldGap(),
      PfField(label: 'What is explicitly not included?', initial: vm.exclusions, minLines: 3, maxLines: 6, onChanged: (v) => vm.update(() => vm.exclusions = v)),
    ]);
  }
}
