import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/catalog/catalog.dart';
import '../../../../domain/services/contract_inputs.dart';
import '../../viewmodel/contract_wizard_viewmodel.dart';

class StepLegal extends StatelessWidget {
  const StepLegal({super.key, required this.vm});
  final ContractWizardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final i = vm.inputs!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const FormSectionLabel('Revisions and change control'),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: PfField(label: 'Included revision rounds', initial: '${i.revisions}', digitsOnly: true, onChanged: (v) => vm.update((x) => x.revisions = int.tryParse(v) ?? 0))),
        const SizedBox(width: 12),
        Expanded(child: PfField(label: 'Change estimate within', initial: '${i.changeSlaDays}', digitsOnly: true, suffixText: 'days', onChanged: (v) => vm.update((x) => x.changeSlaDays = int.tryParse(v) ?? 3))),
      ]),
      const FieldGap(),
      PfField(label: 'What counts as a revision?', initial: i.revisionDefinition, minLines: 2, maxLines: 5, onChanged: (v) => vm.update((x) => x.revisionDefinition = v)),
      const FieldGap(),
      PfField(label: 'Rate for extra work (per hour)', initial: i.changeRate.round().toString(), decimal: true, prefixText: '₹ ', onChanged: (v) => vm.update((x) => x.changeRate = double.tryParse(v) ?? 0)),
      const FormSectionLabel('Ownership and confidentiality'),
      PfSelectField<String>(label: 'IP ownership', value: i.ipModel, options: kIpOptions, onSelected: (v) => vm.update((x) => x.ipModel = v)),
      const FieldGap(),
      PfSwitchRow(title: 'Portfolio rights', subtitle: 'You may show non-confidential work', value: i.portfolioRights, onChanged: (v) => vm.update((x) => x.portfolioRights = v)),
      const FieldGap(),
      PfSwitchRow(title: 'Separate NDA', subtitle: 'Sign a standalone non-disclosure agreement', value: i.nda, onChanged: (v) => vm.update((x) => x.nda = v)),
      const FieldGap(),
      PfField(label: 'Confidentiality period', initial: '${i.confidentialityYears}', digitsOnly: true, suffixText: 'years', onChanged: (v) => vm.update((x) => x.confidentialityYears = int.tryParse(v) ?? 2)),
      const FormSectionLabel('Warranty, liability and exit'),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: PfField(label: 'Warranty', initial: '${i.warrantyDays}', digitsOnly: true, suffixText: 'days', onChanged: (v) => vm.update((x) => x.warrantyDays = int.tryParse(v) ?? 30))),
        const SizedBox(width: 12),
        Expanded(child: PfField(label: 'Notice to terminate', initial: '${i.noticeDays}', digitsOnly: true, suffixText: 'days', onChanged: (v) => vm.update((x) => x.noticeDays = int.tryParse(v) ?? 14))),
      ]),
      const FieldGap(),
      PfField(label: 'Support after warranty', initial: i.maintenance, minLines: 1, maxLines: 3, onChanged: (v) => vm.update((x) => x.maintenance = v)),
      const FieldGap(),
      PfSelectField<String>(label: 'Liability cap', value: i.liabilityCap, options: kLiabilityCaps, onSelected: (v) => vm.update((x) => x.liabilityCap = v)),
      const FieldGap(),
      PfSelectField<String>(label: 'Subcontracting', value: i.subcontracting, options: kSubcontracting, onSelected: (v) => vm.update((x) => x.subcontracting = v)),
      const FieldGap(),
      PfField(label: 'Mutual non-solicitation (0 = none)', initial: '${i.nonSolicitMonths}', digitsOnly: true, suffixText: 'months', onChanged: (v) => vm.update((x) => x.nonSolicitMonths = int.tryParse(v) ?? 0)),
      const FieldGap(),
      PfSwitchRow(title: 'Force majeure clause', value: i.forceMajeure, onChanged: (v) => vm.update((x) => x.forceMajeure = v)),
      const FieldGap(),
      PfSwitchRow(title: 'Data protection (DPDP Act, 2023)', subtitle: 'Turn on if the project handles personal data', value: i.dpdp, onChanged: (v) => vm.update((x) => x.dpdp = v)),
    ]);
  }
}
