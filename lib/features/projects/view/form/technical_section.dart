import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/catalog/catalog.dart';
import '../../viewmodel/project_form_viewmodel.dart';

class TechnicalSection extends StatelessWidget {
  const TechnicalSection({super.key, required this.vm});
  final ProjectFormViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const FormSectionLabel('Technical context'),
      const FieldLabel('Technologies / Tools'),
      PfField(label: 'e.g., Kotlin, Python, TensorFlow', initial: vm.tech, maxLines: 3, minLines: 1, onChanged: (v) => vm.update(() => vm.tech = v)),
      const FieldLabel('Project Complexity'),
      ChoiceRow(
        options: kComplexity.keys.toList(),
        value: complexityLabel(vm.complexity),
        onChanged: (v) => vm.update(() => vm.complexity = kComplexity[v] ?? 3),
      ),
      const FieldLabel('Technical Components'),
      ChipMultiSelect(options: kTechComponents, selected: vm.components, onToggle: (v) => vm.toggle(vm.components, v)),
      const FieldLabel('External Dependencies'),
      ChipMultiSelect(options: kExternalDeps, selected: vm.deps, onToggle: (v) => vm.toggle(vm.deps, v)),
    ]);
  }
}
