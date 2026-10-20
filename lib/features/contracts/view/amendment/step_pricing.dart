import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/services/amendment_service.dart';
import '../../viewmodel/amendment_viewmodel.dart';

class StepPricing extends StatelessWidget {
  const StepPricing({super.key, required this.vm});
  final AmendmentViewModel vm;

  @override
  Widget build(BuildContext context) {
    final a = vm.inputs;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      PfSelectField<String>(label: 'Schedule impact', value: a.timelineMode, options: kTimelineModes, helper: 'Compressing the schedule adds a rush premium', onSelected: (v) => vm.update((x) => x.timelineMode = v)),
      const FieldGap(),
      PfSelectField<String>(label: 'How is the extra fee paid?', value: a.milestoneHandling, options: kMilestoneHandling, onSelected: (v) => vm.update((x) => x.milestoneHandling = v)),
      const FormSectionLabel('Pricing'),
      PfCard(
        color: context.cs.surfaceContainer,
        child: Row(children: [
          Icon(Icons.auto_awesome, color: context.cs.primary),
          const SizedBox(width: 12),
          Expanded(child: Text('By default the price comes from your similar past projects plus the technical factors from the previous step. You will see the full breakdown on the next screen.', style: context.tt.bodySmall?.copyWith(height: 1.4))),
        ]),
      ),
      const SizedBox(height: 14),
      PfSwitchRow(title: 'Enter the price manually', subtitle: 'Override the estimate with your own figures', value: a.manualPricing, onChanged: (v) => vm.update((x) => x.manualPricing = v)),
      if (a.manualPricing) ...[
        const SizedBox(height: 14),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: PfField(label: 'Additional fee', prefixText: '₹ ', decimal: true, initial: a.manualCost, error: vm.errors['manualCost'], onChanged: (v) => vm.update((x) => x.manualCost = v))),
          const SizedBox(width: 12),
          Expanded(child: PfField(label: 'Additional hours', decimal: true, initial: a.manualHours, onChanged: (v) => vm.update((x) => x.manualHours = v))),
        ]),
      ],
    ]);
  }
}
