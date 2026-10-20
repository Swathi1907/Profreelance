import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../viewmodel/contract_wizard_viewmodel.dart';

class StepReview extends StatelessWidget {
  const StepReview({super.key, required this.vm});
  final ContractWizardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final h = vm.health;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (h != null)
        HeroCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              ScoreRing(score: 100 - h.risk.toDouble(), size: 92, color: Pf.gold, caption: 'HEALTH'),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('CONTRACT HEALTH CHECK', style: monoStyle(context, size: 10.5, color: Pf.gold)),
                  const SizedBox(height: 6),
                  Text(h.risk < 20 ? 'Well protected' : h.level, style: const TextStyle(color: Pf.cream, fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                    'The draft was run through the same analyser used on client contracts: ${h.flags.length} risky clauses, ${h.missing.length} missing terms.',
                    style: TextStyle(color: Pf.cream.withValues(alpha: 0.8), height: 1.4, fontSize: 13),
                  ),
                ]),
              ),
            ]),
            if (h.flags.isNotEmpty || h.missing.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final f in h.flags) Text('• ${f.title}: ${f.fix}', style: TextStyle(color: Pf.cream.withValues(alpha: 0.85), fontSize: 13)),
              for (final m in h.missing) Text('• Missing: ${m.title}', style: TextStyle(color: Pf.cream.withValues(alpha: 0.85), fontSize: 13)),
            ],
          ]),
        ),
      SectionTitle('Clauses', subtitle: '${vm.included.length} of ${vm.clauses.length} included. Turn off anything you do not want.'),
      for (final c in vm.clauses)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: PfCard(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800))),
                PfChip(c.source, color: c.source == 'Client risk model' ? context.pf.warning : context.cs.primary),
                Switch(value: !vm.excluded.contains(c.id), onChanged: (_) => vm.toggleClause(c.id)),
              ]),
              Text('Why: ${c.rationale}', style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant, height: 1.35)),
            ]),
          ),
        ),
      const SizedBox(height: 16),
      const SectionTitle('Preview'),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: context.cs.surfaceContainerLowest, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.pf.cardLine)),
        child: SelectableText(vm.preview, style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, height: 1.5)),
      ),
    ]);
  }
}
