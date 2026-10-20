import 'dart:math';

import 'package:flutter/material.dart' show IconData, Icons;

import '../../core/utils/format.dart';
import '../../data/models/models.dart';
import 'client_scoring.dart';

enum Tone { friendly, firm, formal }

class Strategy {
  const Strategy({
    required this.option,
    required this.title,
    required this.summary,
    required this.math,
    required this.value,
    required this.margin,
    required this.icon,
    this.applicable = true,
  });

  final int option;
  final String title;
  final String summary;
  final String math;
  final double value; // rupees conceded or earned
  final String margin;
  final IconData icon;
  final bool applicable;
}

class NegotiationReply {
  const NegotiationReply({required this.text, this.strategies = const [], this.warning, this.floor, this.package, this.draft});
  final String text;
  final List<Strategy> strategies;
  final String? warning;
  final double? floor;
  final String? package;
  final String? draft;
}

/// Negotiation assistant.
///
/// Pipeline: intent detection (discount / rush / extra scope / delayed payment)
/// → numbers from the actual project (budget, estimated hours, effective rate,
/// revisions, client reliability) → ranked counter-offers → a ready-to-send
/// draft in the chosen tone. The arithmetic is deterministic, so every
/// suggested concession can be defended with numbers.
///
/// To add an LLM: keep [respond] for the numbers, and let the model only
/// rewrite `draft` (wording), never the figures.
class NegotiationEngine {
  NegotiationEngine._();

  static double? _pct(String m) {
    final r = RegExp(r'(\d{1,2}(?:\.\d+)?)\s*(%|percent|per\s*cent)').firstMatch(m);
    return r == null ? null : double.tryParse(r.group(1)!);
  }

  static String _wrap(Tone t, String client, String body) => switch (t) {
        Tone.friendly =>
          'Hi $client team,\n\nThanks for being upfront about the budget. $body\n\nHappy to hop on a quick call if that helps. I really want to make this work for both of us!\n',
        Tone.firm =>
          'Hello,\n\n$body\n\nThese options keep the quality and timeline we agreed. Tell me which one you prefer and I will update the contract.\n',
        Tone.formal =>
          'Dear $client,\n\nThank you for your message regarding the proposed terms. $body\n\nPlease confirm your preferred option and I will issue a revised agreement.\n\nKind regards',
      };

  static String draftFor(Strategy s, Tone tone, String client) =>
      _wrap(tone, client, 'I can offer the following: ${s.title.toLowerCase()}. ${s.summary} ${s.math}');

  static NegotiationReply respond({
    required String message,
    required Project? project,
    required Client? client,
    required ClientScore? score,
    required double hourlyRate,
    Tone tone = Tone.friendly,
  }) {
    final m = message.toLowerCase();
    final budget = project?.budget ?? 100000.0;
    final hours = (project?.estimatedHours ?? 100).toDouble();
    final rate = (project?.effectiveRate ?? 0) > 0 ? project!.effectiveRate : hourlyRate;
    final revisions = project?.revisions ?? 3;
    final cname = client?.name ?? 'the client';

    final pct = _pct(m);
    final wantsDiscount = pct != null ||
        RegExp(r'discount|cheaper|lower (the )?(price|cost|fee)|reduce.*(price|cost|fee|budget)|budget (is|has)|too (high|expensive)|negotiat').hasMatch(m);
    final wantsSpeed = RegExp(r'urgent|faster|asap|rush|earlier|sooner|tight deadline|compress|bring forward').hasMatch(m);
    final wantsMore = RegExp(r'(also|one more|another|extra|additional)\s+(add|feature|module|screen|page)|add (a|an|another)\s').hasMatch(m) &&
        RegExp(r'free|same (price|budget)|no extra|without (extra|additional)|included').hasMatch(m);
    final wantsLater = RegExp(r'pay (later|after)|net ?(30|45|60)|after delivery|delay(ed)? payment|payment (later|after)').hasMatch(m);

    final riskNote = (score != null && score.isRisky)
        ? 'Client reliability is ${score.overall.round()} (${score.tier}). Avoid unconditional concessions and keep the advance at ${score.suggestedAdvance}% or more.'
        : null;

    if (wantsDiscount) {
      final d = pct ?? 10.0;
      final conc = budget * d / 100;
      final cutH = conc / rate;
      final s1 = Strategy(
        option: 1,
        title: 'Reduce features',
        summary: 'Move the lowest-priority deliverables to a later phase.',
        math: 'About ${cutH.round()}h (${(cutH / hours * 100).round()}% of the ${hours.round()}h estimate) comes out; new price ${inr(budget - conc)}.',
        value: conc,
        margin: 'No margin loss: less work for less money.',
        icon: Icons.content_cut,
      );
      final d2 = min(d, 8.0);
      final weeks = (d2 / 4).ceil() * 2;
      final s2 = Strategy(
        option: 2,
        title: 'Increase deadline',
        summary: 'A flexible date lets you fit this between other jobs.',
        math: 'Extend delivery by $weeks weeks and give ${d2.toStringAsFixed(0)}% (${inr(budget * d2 / 100)}) off.',
        value: budget * d2 / 100,
        margin: 'Low loss: better scheduling recovers part of the discount.',
        icon: Icons.event_available_outlined,
      );
      final cut = max(0, min(revisions - 1, 2));
      final d3 = min(d, cut * 4.0);
      final s3 = Strategy(
        option: 3,
        title: 'Reduce revisions',
        summary: cut == 0 ? 'Only one revision round is included, so there is nothing to trade here.' : 'Fewer included revision rounds cut effort you would otherwise absorb.',
        math: cut == 0
            ? 'Not applicable.'
            : 'Revisions $revisions → ${revisions - cut} saves about ${(hours * 0.04 * cut).round()}h; offer ${d3.toStringAsFixed(0)}% (${inr(budget * d3 / 100)}).',
        value: budget * d3 / 100,
        margin: 'Low loss: you only drop work you would have done.',
        icon: Icons.rate_review_outlined,
        applicable: cut > 0,
      );
      final d4 = min(d, 6.0);
      final s4 = Strategy(
        option: 4,
        title: 'Offer milestone-based discount',
        summary: 'The discount is earned, not given.',
        math: '${d4.toStringAsFixed(0)}% (${inr(budget * d4 / 100)}) is credited on the final milestone only if every milestone is paid within 3 days of its due date.',
        value: budget * d4 / 100,
        margin: 'Contingent: it costs you only when the client pays on time.',
        icon: Icons.flag_outlined,
      );

      var remaining = d;
      final picks = <String>[];
      for (final s in [s4, s2, s3, s1]) {
        if (!s.applicable || remaining <= 0) continue;
        final pctOf = s.value / budget * 100;
        final take = min(pctOf, remaining);
        picks.add('Option ${s.option} (${take.toStringAsFixed(1)}%)');
        remaining -= take;
      }
      final floor = budget * 0.85;
      String? warning;
      if (d > 15) {
        warning = 'A ${d.toStringAsFixed(0)}% cut breaks your 15% floor (${inr(floor)}). Pair it with a matching scope reduction (Option 1).';
      }
      final drafts = [s4, s2, s3, s1].where((s) => s.applicable).take(3).map((s) => '• ${s.title}: ${s.math}').join('\n');
      return NegotiationReply(
        text:
            'A ${d.toStringAsFixed(0)}% request on ${inr(budget)} is ${inr(conc)}.${pct == null ? ' (No figure was given, so I assumed 10%.)' : ''} I would not simply accept it. Here are four ways to trade value instead of just cutting the price.',
        strategies: [s1, s2, s3, s4],
        warning: [warning, riskNote].whereType<String>().join('\n'),
        floor: floor,
        package: 'Suggested combination: ${picks.join(' + ')}.',
        draft: _wrap(tone, cname, 'I would like to find a way to fit your budget without hurting the outcome. Here are some options:\n$drafts'),
      );
    }

    if (wantsSpeed) {
      final s = [
        Strategy(
          option: 1,
          title: 'Phased delivery',
          summary: 'Ship the core flow first, the rest in a second drop.',
          math: 'Core in about ${(hours * 0.6 / 5.5 * 1.35).ceil()} days; remaining scope follows on the original date.',
          value: 0,
          margin: 'No extra cost to you.',
          icon: Icons.layers_outlined,
        ),
        Strategy(
          option: 2,
          title: 'Rush fee',
          summary: 'Compressing the timeline means rearranging other work.',
          math: '+20% (${inr(budget * 0.2)}) for a compressed date; total ${inr(budget * 1.2)}.',
          value: budget * 0.2,
          margin: 'Positive: you are paid for the disruption.',
          icon: Icons.bolt,
        ),
        Strategy(
          option: 3,
          title: 'Tighten the feedback loop',
          summary: 'Limit revisions to one round and require feedback within 24 hours.',
          math: 'Saves about ${(hours * 0.04 * 2).round()}h of waiting and rework.',
          value: 0,
          margin: 'No cost: it protects the new date.',
          icon: Icons.timer_outlined,
        ),
      ];
      return NegotiationReply(
        text: 'Faster delivery is possible, but it should not be free. Pick what you want to trade.',
        strategies: s,
        warning: riskNote,
        draft: _wrap(tone, cname, 'I can bring the date forward in one of these ways:\n${s.map((e) => '• ${e.title}: ${e.math}').join('\n')}'),
      );
    }

    if (wantsMore) {
      final s = [
        const Strategy(
          option: 1,
          title: 'Change order',
          summary: 'Price the addition separately through the amendment flow.',
          math: 'Open Amend contract on the project to get an estimate from similar past work.',
          value: 0,
          margin: 'Fully protected.',
          icon: Icons.edit_note,
        ),
        Strategy(
          option: 2,
          title: 'Swap, do not stack',
          summary: 'Replace a lower-priority feature of similar effort with the new one.',
          math: 'Budget and timeline stay at ${inr(budget)}.',
          value: 0,
          margin: 'Neutral.',
          icon: Icons.swap_horiz,
        ),
        const Strategy(
          option: 3,
          title: 'Phase 2 with a loyalty rate',
          summary: 'Move it to a second project with a small discount.',
          math: '5% off the next phase if it is signed before this one ends.',
          value: 0,
          margin: 'Wins repeat business.',
          icon: Icons.upcoming_outlined,
        ),
      ];
      return NegotiationReply(
        text: 'New scope at the same price is the start of scope creep. Offer one of these instead.',
        strategies: s,
        warning: riskNote,
        draft: _wrap(tone, cname, 'The new feature is a good idea. To keep the quality and date, I can do it in one of these ways:\n${s.map((e) => '• ${e.title}: ${e.summary}').join('\n')}'),
      );
    }

    if (wantsLater) {
      final adv = score?.suggestedAdvance ?? 30;
      final s = [
        Strategy(
          option: 1,
          title: 'Net-30 with a late fee',
          summary: 'Accept longer terms only with a larger advance.',
          math: '$adv% advance (${inr(budget * adv / 100)}), balance net-30, ${score?.suggestedLateFee ?? 1.5}% monthly late fee.',
          value: 0,
          margin: 'Cash-flow cost only.',
          icon: Icons.schedule,
        ),
        const Strategy(
          option: 2,
          title: 'Staged release',
          summary: 'Hand over the work in stages as each part is paid.',
          math: '50% on delivery of the build, 50% within 30 days; source files released on final payment.',
          value: 0,
          margin: 'Keeps leverage until paid.',
          icon: Icons.lock_open_outlined,
        ),
        Strategy(
          option: 3,
          title: 'Early-payment discount',
          summary: 'Reward fast payment instead of tolerating slow payment.',
          math: '2% (${inr(budget * 0.02)}) off if paid within 7 days.',
          value: budget * 0.02,
          margin: 'Small cost, faster cash.',
          icon: Icons.savings_outlined,
        ),
      ];
      return NegotiationReply(
        text: 'Delayed payment is a financing request. Charge for it, or secure it.',
        strategies: s,
        warning: riskNote,
        draft: _wrap(tone, cname, 'Regarding payment timing, I can work with:\n${s.map((e) => '• ${e.title}: ${e.math}').join('\n')}'),
      );
    }

    return const NegotiationReply(
      text:
          'I can help with price discounts, rush deadlines, free extra features and delayed payments. Try: "The client wants a 20% discount" or "They want it a week earlier".',
    );
  }
}
