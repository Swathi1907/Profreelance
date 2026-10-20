import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../../data/catalog/catalog.dart';
import '../../viewmodel/project_form_viewmodel.dart';

class PreferencesSection extends StatelessWidget {
  const PreferencesSection({super.key, required this.vm});
  final ProjectFormViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const FormSectionLabel('Contract preferences'),
      PfSelectField<String>(label: 'Payment Structure', value: vm.paymentStructure, options: kPaymentStructures, onSelected: (v) => vm.update(() => vm.paymentStructure = v)),
      const FieldGap(),
      PfField(label: 'Advance Payment', decimal: true, suffixText: '%', initial: vm.advance, error: vm.errors['advance'], onChanged: (v) => vm.update(() => vm.advance = v)),
      const FieldGap(),
      PfField(label: 'Included Revisions', digitsOnly: true, initial: vm.revisions, error: vm.errors['revisions'], onChanged: (v) => vm.update(() => vm.revisions = v)),
      const FieldGap(),
      PfDateField(label: 'Final Delivery Date', value: vm.deliveryDate, helper: 'Leave empty to use start date plus duration', onChanged: (d) => vm.update(() => vm.deliveryDate = d)),
      const FieldGap(),
      PfSelectField<String>(label: 'Intellectual Property Ownership', value: vm.ip, options: kIpOptions, onSelected: (v) => vm.update(() => vm.ip = v)),
      const FieldGap(),
      PfField(label: 'Jurisdiction', initial: vm.jurisdiction, onChanged: (v) => vm.update(() => vm.jurisdiction = v)),
      const FieldGap(),
      PfSwitchRow(title: 'NDA / Confidentiality Required', value: vm.nda, onChanged: (v) => vm.update(() => vm.nda = v)),
    ]);
  }
}
