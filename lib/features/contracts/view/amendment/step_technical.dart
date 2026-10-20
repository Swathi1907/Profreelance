import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/catalog/catalog.dart';
import '../../../../domain/services/amendment_service.dart';
import '../../viewmodel/amendment_viewmodel.dart';

class StepTechnical extends StatelessWidget {
  const StepTechnical({super.key, required this.vm});
  final AmendmentViewModel vm;

  @override
  Widget build(BuildContext context) {
    final a = vm.inputs;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const FieldLabel('Components affected'),
      ChipMultiSelect(options: vm.componentOptions, selected: a.components, onToggle: (v) => vm.toggle(a.components, v)),
      const FieldGap(),
      PfField(label: 'New technologies or services needed', initial: a.newTech, helper: 'Comma separated, for example: Stripe, Redis', onChanged: (v) => vm.update((x) => x.newTech = v)),
      const FieldLabel('Complexity of the change'),
      ChoiceRow(options: kComplexity.keys.toList(), value: complexityLabel(a.complexity), onChanged: (v) => vm.update((x) => x.complexity = kComplexity[v] ?? 3)),
      const SizedBox(height: 16),
      PfSwitchRow(title: 'Third-party integration', subtitle: 'Needs credentials, sandbox testing and error handling', value: a.thirdParty, onChanged: (v) => vm.update((x) => x.thirdParty = v)),
      const SizedBox(height: 10),
      PfSwitchRow(title: 'Data migration', subtitle: 'Existing data must be moved or reshaped', value: a.dataMigration, onChanged: (v) => vm.update((x) => x.dataMigration = v)),
      const SizedBox(height: 10),
      PfSwitchRow(title: 'Security impact', subtitle: 'Touches authentication, payments or personal data', value: a.securityImpact, onChanged: (v) => vm.update((x) => x.securityImpact = v)),
      const SizedBox(height: 10),
      PfSwitchRow(title: 'New infrastructure', subtitle: 'New environment, queue, storage or CI step', value: a.newInfra, onChanged: (v) => vm.update((x) => x.newInfra = v)),
      const FormSectionLabel('Effect on delivered work'),
      Row(children: [
        const Expanded(child: Text('Share of delivered work that is changed', style: TextStyle(fontWeight: FontWeight.w700))),
        Text('${a.reworkPct.round()}%', style: monoStyle(context, size: 12)),
      ]),
      Slider(value: a.reworkPct, min: 0, max: 50, divisions: 10, onChanged: (v) => vm.update((x) => x.reworkPct = v)),
      const FieldGap(),
      PfSelectField<String>(label: 'Re-testing scope', value: a.retest, options: kRetestScopes, onSelected: (v) => vm.update((x) => x.retest = v)),
      const FieldGap(),
      PfField(label: 'Acceptance criteria for the change', initial: a.acceptance, minLines: 3, maxLines: 6, helper: 'Measurable: how will the client confirm it is done?', onChanged: (v) => vm.update((x) => x.acceptance = v)),
    ]);
  }
}
