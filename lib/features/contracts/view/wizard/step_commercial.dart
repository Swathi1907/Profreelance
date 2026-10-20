import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/services/contract_inputs.dart';
import '../../viewmodel/contract_wizard_viewmodel.dart';

class StepCommercial extends StatelessWidget {
  const StepCommercial({super.key, required this.vm});
  final ContractWizardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final i = vm.inputs!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const FormSectionLabel('Fee'),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 3, child: PfField(label: 'Total fee (${i.currency})', initial: i.totalFee.round().toString(), decimal: true, error: vm.errors['fee'], onChanged: (v) => vm.update((x) => x.totalFee = double.tryParse(v) ?? 0))),
        const SizedBox(width: 12),
        Expanded(flex: 2, child: PfField(label: 'Advance', initial: i.advancePct.round().toString(), decimal: true, suffixText: '%', error: vm.errors['advance'], onChanged: (v) => vm.update((x) => x.advancePct = double.tryParse(v) ?? 0))),
      ]),
      const FieldGap(),
      PfSelectField<String>(label: 'Tax treatment', value: i.taxMode, options: kTaxModes, onSelected: (v) => vm.update((x) => x.taxMode = v)),
      const FieldGap(),
      PfSwitchRow(title: 'Client may deduct TDS', subtitle: 'The client provides the TDS certificate', value: i.tds, onChanged: (v) => vm.update((x) => x.tds = v)),
      const FieldGap(),
      PfSelectField<String>(label: 'Payment method', value: i.paymentMethod, options: kPaymentMethods, onSelected: (v) => vm.update((x) => x.paymentMethod = v)),
      const FieldGap(),
      PfField(label: 'Expenses policy', initial: i.expenses, onChanged: (v) => vm.update((x) => x.expenses = v)),
      const FormSectionLabel('Invoicing and late payment'),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: PfField(label: 'Invoice due in', initial: '${i.invoiceDueDays}', digitsOnly: true, suffixText: 'days', onChanged: (v) => vm.update((x) => x.invoiceDueDays = int.tryParse(v) ?? 7))),
        const SizedBox(width: 12),
        Expanded(child: PfField(label: 'Late fee per month', initial: i.lateFeePct.toString(), decimal: true, suffixText: '%', onChanged: (v) => vm.update((x) => x.lateFeePct = double.tryParse(v) ?? 0))),
      ]),
      const FieldGap(),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: PfField(label: 'Pause work after', initial: '${i.pauseAfterDays}', digitsOnly: true, suffixText: 'days overdue', onChanged: (v) => vm.update((x) => x.pauseAfterDays = int.tryParse(v) ?? 7))),
        const SizedBox(width: 12),
        Expanded(child: PfField(label: 'Kill fee', initial: i.killFeePct.round().toString(), decimal: true, suffixText: '%', helper: 'of the remaining fee', onChanged: (v) => vm.update((x) => x.killFeePct = double.tryParse(v) ?? 0))),
      ]),
      const FormSectionLabel('Milestone schedule'),
      Text('Taken from the project. Edit milestones in the project\'s Payments tab; they are copied into Schedule A.', style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
      const SizedBox(height: 10),
      PfCard(
        padding: EdgeInsets.zero,
        child: i.milestones.isEmpty
            ? const Padding(padding: EdgeInsets.all(16), child: Text('This project has no milestones yet.'))
            : Column(children: [
                for (var k = 0; k < i.milestones.length; k++)
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(radius: 14, backgroundColor: context.cs.surfaceContainer, foregroundColor: context.cs.primary, child: Text('${k + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
                    title: Text(i.milestones[k].title),
                    subtitle: Text('Due ${fmtDate(i.milestones[k].due)}'),
                    trailing: Text(inr(i.milestones[k].amount), style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
              ]),
      ),
    ]);
  }
}
