import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../domain/services/contract_analyzer.dart';
import '../../viewmodel/analyzer_viewmodel.dart';

class AnalysisResultView extends StatefulWidget {
  const AnalysisResultView({super.key, required this.vm});
  final AnalyzerViewModel vm;

  @override
  State<AnalysisResultView> createState() => _AnalysisResultViewState();
}

class _AnalysisResultViewState extends State<AnalysisResultView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final r = vm.result!;
    final color = r.risk >= 60 ? context.pf.danger : (r.risk >= 35 ? context.pf.warning : context.pf.success);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      HeroCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ScoreRing(score: r.risk.toDouble(), size: 96, color: Pf.gold, caption: 'RISK'),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(r.level, style: const TextStyle(color: Pf.cream, fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${r.clauses.length} clauses  ·  ${r.flags.length} risks  ·  ${r.missing.length} missing terms  ·  ${r.words} words', style: TextStyle(color: Pf.cream.withValues(alpha: 0.75), fontSize: 12.5)),
              ]),
            ),
          ]),
          if (vm.verdict != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Pf.cream.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.lightbulb_outline, color: Pf.gold, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(vm.verdict!, style: const TextStyle(color: Pf.cream, height: 1.4))),
              ]),
            ),
          ],
          if (vm.score != null) ...[
            const SizedBox(height: 10),
            Text('Client reliability: ${vm.client?.name}  ·  ${vm.score!.tier} (${vm.score!.overall.round()})', style: TextStyle(color: Pf.cream.withValues(alpha: 0.8), fontSize: 12.5)),
          ],
        ]),
      ),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [
        PfToggleChip(label: 'Risks (${r.flags.length})', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
        PfToggleChip(label: 'Missing terms (${r.missing.length})', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
        PfToggleChip(label: 'Clauses (${r.clauses.length})', selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
      ]),
      const SizedBox(height: 14),
      if (_tab == 0) ...[
        if (r.flags.isEmpty) const PfCard(child: Text('No risky clauses detected.')),
        for (final f in r.flags) _FlagCard(f: f),
      ],
      if (_tab == 1) ...[
        if (r.missing.isEmpty) const PfCard(child: Text('All the key protections are present.')),
        for (final m in r.missing) _MissingCard(m: m),
      ],
      if (_tab == 2)
        for (final c in r.clauses)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PfCard(
              padding: EdgeInsets.zero,
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text('${c.number}. ${c.title}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Padding(padding: const EdgeInsets.only(top: 4), child: Align(alignment: Alignment.centerLeft, child: PfChip(c.category, color: color == context.pf.danger ? context.cs.primary : context.cs.primary))),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('In plain English: ${c.plain}', style: TextStyle(color: context.cs.primary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(c.text, style: const TextStyle(height: 1.45)),
                ],
              ),
            ),
          ),
      const SizedBox(height: 16),
      Wrap(spacing: 10, runSpacing: 10, children: [
        FilledButton.icon(
          onPressed: () async {
            await vm.copyCounter();
            if (context.mounted) toast(context, 'Counter-proposal copied.');
          },
          icon: const Icon(Icons.copy),
          label: const Text('Copy counter-proposal'),
        ),
        OutlinedButton.icon(
          onPressed: () {
            vm.saveReport();
            toast(context, 'Report saved to the vault.');
          },
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('Save report to vault'),
        ),
        TextButton(onPressed: vm.reset, child: const Text('Analyse another')),
      ]),
    ]);
  }
}

class _FlagCard extends StatelessWidget {
  const _FlagCard({required this.f});
  final RiskFlag f;

  @override
  Widget build(BuildContext context) {
    final c = severityColor(context, f.severity);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PfCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            PfChip(f.severity.name.toUpperCase(), color: c, dot: true),
            const SizedBox(width: 10),
            Expanded(child: Text(f.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
          ]),
          const SizedBox(height: 4),
          Text('Found in ${f.clauseTitle}', style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: c.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10), border: Border(left: BorderSide(color: c, width: 3))),
            child: Text(f.quote, style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, height: 1.4)),
          ),
          const SizedBox(height: 10),
          Text('In plain English: ${f.plain}', style: const TextStyle(height: 1.4)),
          const SizedBox(height: 6),
          Text('Suggested fix: ${f.fix}', style: TextStyle(color: context.cs.primary, fontWeight: FontWeight.w700, height: 1.4)),
        ]),
      ),
    );
  }
}

class _MissingCard extends StatelessWidget {
  const _MissingCard({required this.m});
  final MissingTerm m;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: PfCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              PfChip(m.important ? 'IMPORTANT' : 'NICE TO HAVE', color: m.important ? context.pf.warning : context.cs.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(child: Text(m.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
            ]),
            const SizedBox(height: 8),
            Text(m.why, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 8),
            Text('Suggested wording: ${m.wording}', style: TextStyle(color: context.cs.primary, fontWeight: FontWeight.w600, height: 1.4)),
          ]),
        ),
      );
}
