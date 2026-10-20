import 'package:flutter/material.dart';
import '../../../data/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/services/client_scoring.dart';
import '../viewmodel/clients_viewmodel.dart';
import 'clients_screen.dart';
import 'review_sheet.dart';

class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(clientDetailViewModelProvider(id));
    final c = vm.client;
    final s = vm.score;
    if (c == null || s == null) return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.search_off, title: 'Client not found', body: ''));
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: Text(c.name), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.canPop() ? context.pop() : context.go('/clients'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showReviewSheet(context, vm),
        backgroundColor: context.isDark ? Pf.gold : Pf.maroon,
        foregroundColor: context.isDark ? Pf.ink : Colors.white,
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Record experience'),
      ),
      body: PageBody(children: [
        HeroCard(
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.industry.toUpperCase(), style: monoStyle(context, size: 10.5, color: Pf.gold)),
                const SizedBox(height: 6),
                Text(c.name, style: const TextStyle(color: Pf.cream, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                PfChip(s.tier, color: Pf.gold, dot: true),
                const SizedBox(height: 10),
                Text(s.recommendation, style: TextStyle(color: Pf.cream.withValues(alpha: 0.8), height: 1.4)),
              ]),
            ),
            const SizedBox(width: 12),
            ScoreRing(score: s.overall, size: 104, color: Pf.gold, caption: 'RELIABILITY'),
          ]),
        ),
        const SizedBox(height: 20),
        TwoCol(
          left: [
            const SectionTitle('Score breakdown', subtitle: 'Weighted: payments 35%, stability 25%, communication 20%, experience 20%'),
            PfCard(
              child: Column(children: [
                _Sub('Payment punctuality', s.punctuality),
                _Sub('Requirement stability', s.stability),
                _Sub('Communication', s.communication),
                _Sub('Overall experience', s.experience),
                const Divider(height: 24),
                Align(alignment: Alignment.centerLeft, child: Text('Why this score', style: context.tt.titleMedium)),
                const SizedBox(height: 8),
                for (final r in s.reasons) Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.circle, size: 6), const SizedBox(width: 10), Expanded(child: Text(r))])),
              ]),
            ),
            const SizedBox(height: 20),
            const SectionTitle('Suggested terms for the next project'),
            _Terms(score: s),
          ],
          right: [
            const SectionTitle('Projects'),
            if (vm.projects.isEmpty)
              const PfCard(child: Text('No projects with this client yet.'))
            else
              for (final p in vm.projects)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PfCard(
                    onTap: () => context.push('/projects/${p.id}'),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)), Text('${inr(p.budget)}  ·  ${p.status.label}', style: context.tt.bodySmall)])),
                      const Icon(Icons.chevron_right),
                    ]),
                  ),
                ),
            const SizedBox(height: 20),
            const SectionTitle('Payment record'),
            PfCard(
              padding: EdgeInsets.zero,
              child: Column(children: [
                for (final m in vm.payments.take(8))
                  ListTile(
                    dense: true,
                    title: Text(m.title),
                    subtitle: Text(m.paidOn != null ? 'Paid ${fmtDay(m.paidOn!)}${m.paidLateDays > 0 ? ' · ${m.paidLateDays}d late' : ' · on time'}' : 'Due ${fmtDay(m.due)}'),
                    trailing: Text(inrShort(m.amount), style: TextStyle(fontWeight: FontWeight.w800, color: m.paidOn != null ? context.pf.success : (m.due.isBefore(now) ? context.pf.danger : null))),
                  ),
              ]),
            ),
            const SizedBox(height: 20),
            const SectionTitle('Your ratings'),
            if (vm.reviews.isEmpty)
              const PfCard(child: Text('No ratings yet. Record your experience after each project.'))
            else
              for (final r in vm.reviews)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PfCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Expanded(child: Text(r.projectName.isEmpty ? 'General' : r.projectName, style: const TextStyle(fontWeight: FontWeight.w700))), Text(fmtDay(r.date), style: context.tt.bodySmall)]),
                      const SizedBox(height: 6),
                      Text('Payments ${r.punctuality}/5  ·  Scope ${r.stability}/5  ·  Comms ${r.communication}/5  ·  Overall ${r.overall}/5', style: monoStyle(context, size: 10.5)),
                      if (r.note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(r.note)),
                    ]),
                  ),
                ),
          ],
        ),
      ]),
    );
  }
}

class _Sub extends StatelessWidget {
  const _Sub(this.label, this.value);
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))), Text('${value.round()}', style: monoStyle(context, size: 12))]),
          const SizedBox(height: 6),
          AnimatedBar(value: value / 100, color: scoreColor(context, value), height: 8),
        ]),
      );
}

class _Terms extends StatelessWidget {
  const _Terms({required this.score});
  final ClientScore score;
  @override
  Widget build(BuildContext context) => PfCard(
        child: Row(children: [
          Expanded(child: _Term('ADVANCE', '${score.suggestedAdvance}%')),
          Expanded(child: _Term('LATE FEE', '${score.suggestedLateFee}% / month')),
          Expanded(child: _Term('SAMPLES', '${score.samples}')),
        ]),
      );
}

class _Term extends StatelessWidget {
  const _Term(this.l, this.v);
  final String l;
  final String v;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [MonoLabel(l), const SizedBox(height: 4), Text(v, style: context.tt.titleMedium)]);
}
