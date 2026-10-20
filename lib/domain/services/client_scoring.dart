import 'dart:math';

import '../../data/models/models.dart';

class ClientScore {
  const ClientScore({
    required this.overall,
    required this.punctuality,
    required this.stability,
    required this.communication,
    required this.experience,
    required this.samples,
    required this.tier,
    required this.onTimeRate,
    required this.avgDelayDays,
    required this.recommendation,
    required this.suggestedAdvance,
    required this.suggestedLateFee,
    required this.reasons,
  });

  final double overall;
  final double punctuality;
  final double stability;
  final double communication;
  final double experience;
  final int samples;
  final String tier;
  final double? onTimeRate;
  final double avgDelayDays;
  final String recommendation;
  final int suggestedAdvance;
  final double suggestedLateFee;
  final List<String> reasons;

  bool get isRisky => tier == 'High risk' || tier == 'Cautious';
}

/// Client reliability model.
///
/// Four sub-scores (payment punctuality 35%, requirement stability 25%,
/// communication 20%, overall experience 20%). Punctuality blends the
/// freelancer's rating with the measured on-time rate from real milestones.
/// Each sub-score is shrunk toward a prior of 70 using a Bayesian-style
/// weight, so a client with one good project is not instantly "perfect".
class ClientScoring {
  ClientScoring._();

  static const _prior = 70.0;
  static const _priorWeight = 2.0;

  static double _shrink(double x, double evidence) => (x * evidence + _prior * _priorWeight) / (evidence + _priorWeight);

  static ClientScore score(Client c, List<Milestone> milestones, List<Project> projects) {
    final ids = projects.where((p) => p.clientId == c.id).map((p) => p.id).toSet();
    final mine = milestones.where((m) => ids.contains(m.projectId)).toList();
    final now = DateTime.now();
    final paid = mine.where((m) => m.paidOn != null).toList();
    final overdue = mine.where((m) => m.paidOn == null && m.due.isBefore(now)).length;
    final settled = paid.length + overdue;
    final onTime = paid.where((m) => m.paidLateDays <= 2).length;
    final double? onTimeRate = settled == 0 ? null : onTime / settled;
    final avgDelay = paid.isEmpty ? 0.0 : paid.map((m) => m.paidLateDays).reduce((a, b) => a + b) / paid.length;

    final reviews = [...c.reviews]..sort((a, b) => b.date.compareTo(a.date));
    final n = reviews.length;

    // newest reviews count more (0.85 decay per step)
    double? wavg(int Function(ClientReview) f) {
      if (n == 0) return null;
      double s = 0, w = 0;
      for (var i = 0; i < n; i++) {
        final wi = pow(0.85, i).toDouble();
        s += f(reviews[i]) * 20 * wi;
        w += wi;
      }
      return s / w;
    }

    final pReview = wavg((r) => r.punctuality);
    final pAuto = onTimeRate == null ? null : max(0.0, onTimeRate * 100 - min(avgDelay * 1.2, 15));
    double punctRaw;
    if (pReview != null && pAuto != null) {
      punctRaw = 0.5 * pReview + 0.5 * pAuto;
    } else {
      punctRaw = pReview ?? pAuto ?? _prior;
    }

    final evidence = n + settled * 0.5;
    final punct = _shrink(punctRaw, evidence);
    final stab = _shrink(wavg((r) => r.stability) ?? _prior, n.toDouble());
    final comm = _shrink(wavg((r) => r.communication) ?? _prior, n.toDouble());
    final exp = _shrink(wavg((r) => r.overall) ?? _prior, n.toDouble());
    final overall = 0.35 * punct + 0.25 * stab + 0.20 * comm + 0.20 * exp;

    final isNew = n == 0 && settled == 0;
    final tier = isNew
        ? 'New client'
        : overall >= 80
            ? 'Reliable'
            : overall >= 65
                ? 'Good'
                : overall >= 50
                    ? 'Cautious'
                    : 'High risk';

    final advance = switch (tier) { 'Reliable' => 20, 'Good' => 30, 'Cautious' => 40, 'High risk' => 50, _ => 30 };
    final lateFee = switch (tier) { 'Reliable' => 1.0, 'Good' => 1.5, 'Cautious' => 2.0, 'High risk' => 3.0, _ => 1.5 };
    final rec = switch (tier) {
      'Reliable' => 'Safe to proceed on standard terms.',
      'Good' => 'Proceed. Keep milestone payments short and written change orders on.',
      'Cautious' => 'Proceed with a larger advance, shorter milestones and a strict change-request clause.',
      'High risk' => 'Think twice. If you accept, take 50% upfront and do not start the next milestone before the last is paid.',
      _ => 'No history yet. Start with a smaller first milestone to build a track record.',
    };

    final reasons = <String>[];
    if (onTimeRate != null) {
      reasons.add('$onTime of $settled settled milestones were paid on time (${(onTimeRate * 100).round()}%).');
    }
    if (avgDelay > 2) reasons.add('Payments arrive about ${avgDelay.toStringAsFixed(0)} days late on average.');
    if (n > 0 && stab < 60) reasons.add('Requirements changed often in past projects.');
    if (n > 0 && comm >= 80) reasons.add('Responsive and clear communication.');
    if (n > 0 && punct >= 85) reasons.add('Strong payment record.');
    if (reasons.isEmpty) reasons.add('Not enough history yet; the score leans on a neutral prior of 70.');

    return ClientScore(
      overall: overall,
      punctuality: punct,
      stability: stab,
      communication: comm,
      experience: exp,
      samples: n + settled,
      tier: tier,
      onTimeRate: onTimeRate,
      avgDelayDays: avgDelay,
      recommendation: rec,
      suggestedAdvance: advance,
      suggestedLateFee: lateFee,
      reasons: reasons,
    );
  }
}
