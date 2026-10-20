import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/format.dart';
import '../../../../core/widgets/widgets.dart';
import '../../viewmodel/amendment_viewmodel.dart';

class StepAmendReview extends StatelessWidget {
  const StepAmendReview({super.key, required this.vm});
  final AmendmentViewModel vm;

  @override
  Widget build(BuildContext context) {
    final e = vm.estimate;
    final p = vm.project!;
    if (e == null) return const SizedBox();
    Widget stat(String l, String v, String sub) => Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l, style: monoStyle(context, size: 10, color: Pf.gold)),
            const SizedBox(height: 4),
            Text(v, style: const TextStyle(color: Pf.cream, fontSize: 20, fontWeight: FontWeight.w800)),
            Text(sub, style: TextStyle(color: Pf.cream.withValues(alpha: 0.7), fontSize: 11.5)),
          ]),
        );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      HeroCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('IMPACT OF THIS CHANGE', style: monoStyle(context, size: 10.5, color: Pf.gold)),
          const SizedBox(height: 12),
          Row(children: [
            stat('ADDITIONAL FEE', inr(e.cost), 'now ${inr(p.budget)} → ${inr(e.newBudget)}'),
            stat('EFFORT', '${e.totalHours.round()}h', 'at ${inr(e.rate)}/h'),
            stat('TIME', '+${e.extraDays}d', 'due ${fmtDate(e.newDue)}'),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      PfCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('How the estimate was built', style: context.tt.titleMedium),
          const SizedBox(height: 10),
          for (final l in e.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.label, style: const TextStyle(fontWeight: FontWeight.w700)),
                    Text(l.note, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
                  ]),
                ),
                Text('${l.hours.toStringAsFixed(1)}h', style: monoStyle(context, size: 12)),
              ]),
            ),
          const Divider(height: 20),
          Row(children: [
            const Expanded(child: Text('Total effort', style: TextStyle(fontWeight: FontWeight.w800))),
            Text('${e.totalHours.round()}h', style: monoStyle(context, size: 13)),
          ]),
          if (e.multiplier != 1)
            Padding(padding: const EdgeInsets.only(top: 6), child: Text('Price multiplier ${e.multiplier.toStringAsFixed(2)} for priority and schedule.', style: context.tt.bodySmall)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: AnimatedBar(value: e.confidence, color: scoreColor(context, e.confidence * 100))),
            const SizedBox(width: 10),
            Text('${(e.confidence * 100).round()}% confidence', style: monoStyle(context, size: 10.5)),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      PfCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Based on similar projects', style: context.tt.titleMedium),
          const SizedBox(height: 8),
          if (e.fallback)
            const Text('No similar finished project in this domain yet, so a generic curve was used. Finish more projects to sharpen this.')
          else
            for (final n in e.neighbors)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Expanded(child: Text('${n.project.name}  ·  ${n.project.domain}', maxLines: 1, overflow: TextOverflow.ellipsis)),
                  SizedBox(width: 90, child: AnimatedBar(value: n.similarity, height: 6)),
                  const SizedBox(width: 8),
                  Text('${(n.similarity * 100).round()}%', style: monoStyle(context, size: 10.5)),
                ]),
              ),
        ]),
      ),
      const SizedBox(height: 20),
      SectionTitle('Amendment No. ${vm.amendmentNumber}', subtitle: 'This text is saved as a new contract version'),
      for (final c in vm.clauses)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: PfCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Text(c.body, style: const TextStyle(height: 1.45, fontSize: 13.5)),
            ]),
          ),
        ),
    ]);
  }
}
