import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../data/catalog/catalog.dart';
import '../../viewmodel/project_form_viewmodel.dart';

class EstimationSection extends StatelessWidget {
  const EstimationSection({super.key, required this.vm});
  final ProjectFormViewModel vm;

  @override
  Widget build(BuildContext context) {
    final k = vm.applied;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const FormSectionLabel('Estimation'),
      _AiEstimatePanel(vm: vm),
      const SizedBox(height: 16),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: PfField(key: ValueKey('dur$k'), label: 'Duration', digitsOnly: true, initial: vm.duration, error: vm.errors['duration'], onChanged: (v) => vm.update(() => vm.duration = v))),
        const SizedBox(width: 12),
        Expanded(child: PfSelectField<String>(key: ValueKey('unit$k'), label: 'Unit', value: vm.durationUnit, options: kDurationUnits, onSelected: (v) => vm.update(() => vm.durationUnit = v))),
      ]),
      const FieldGap(),
      PfField(key: ValueKey('hrs$k'), label: 'Expected Working Hours', icon: Icons.schedule, decimal: true, initial: vm.hours, error: vm.errors['hours'], onChanged: (v) => vm.update(() => vm.hours = v)),
      const FieldGap(),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 14, child: PfField(key: ValueKey('bud$k'), label: 'Project Budget', decimal: true, initial: vm.budget, error: vm.errors['budget'], onChanged: (v) => vm.update(() => vm.budget = v))),
        const SizedBox(width: 12),
        Expanded(flex: 10, child: PfSelectField<String>(label: 'Currency', value: vm.currency, options: kCurrencies, onSelected: (v) => vm.update(() => vm.currency = v))),
      ]),
    ]);
  }
}

/// Runs the kNN estimator over the freelancer's finished projects and shows
/// exactly which projects the number came from.
class _AiEstimatePanel extends StatelessWidget {
  const _AiEstimatePanel({required this.vm});
  final ProjectFormViewModel vm;

  @override
  Widget build(BuildContext context) {
    final e = vm.estimate;
    return PfCard(
      color: context.cs.surfaceContainer,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.auto_awesome, color: context.cs.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text('Estimate from your past projects', style: context.tt.titleMedium)),
        ]),
        const SizedBox(height: 6),
        Text('Uses your finished projects in the same domain and stack. Fill in the domain, technologies and complexity first.', style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: vm.estimating ? null : vm.runEstimate,
          icon: vm.estimating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.bolt, size: 18),
          label: Text(vm.estimating ? 'Finding similar projects...' : (e == null ? 'Estimate effort and cost' : 'Re-run estimate')),
        ),
        if (e != null) ...[
          const Divider(height: 28),
          Row(children: [
            Expanded(child: _Num('HOURS', '${e.hours.round()}h', '${e.hoursLow.round()}-${e.hoursHigh.round()}h range')),
            Expanded(child: _Num('COST', inrShort(e.cost), '${inr(e.ratePerHour)}/h realised')),
            Expanded(child: _Num('DURATION', '${e.days}d', 'working + buffer')),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: AnimatedBar(value: e.confidence, color: scoreColor(context, e.confidence * 100))),
            const SizedBox(width: 10),
            Text('${(e.confidence * 100).round()}% confidence', style: monoStyle(context, size: 10.5)),
          ]),
          const SizedBox(height: 14),
          if (e.usedFallback)
            Text('No similar finished project yet, so this uses a generic complexity curve. It improves as you complete projects.', style: context.tt.bodySmall)
          else ...[
            const MonoLabel('Based on'),
            const SizedBox(height: 6),
            for (final n in e.neighbors)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Expanded(child: Text('${n.project.name}  ·  ${n.project.actualHours.round()}h actual', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))),
                  SizedBox(width: 90, child: AnimatedBar(value: n.similarity, height: 6)),
                  const SizedBox(width: 8),
                  Text('${(n.similarity * 100).round()}%', style: monoStyle(context, size: 10.5)),
                ]),
              ),
          ],
          if (e.biasFactor > 1.05)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Your own estimates have run ${((e.biasFactor - 1) * 100).round()}% low on past projects. This figure uses real hours, so it already corrects for that.', style: context.tt.bodySmall?.copyWith(color: context.pf.warning)),
            ),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: vm.applyEstimate, icon: const Icon(Icons.check), label: const Text('Use these values')),
        ],
      ]),
    );
  }
}

class _Num extends StatelessWidget {
  const _Num(this.label, this.value, this.sub);
  final String label;
  final String value;
  final String sub;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        MonoLabel(label),
        Text(value, style: context.tt.headlineSmall),
        Text(sub, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant, fontSize: 11)),
      ]);
}
