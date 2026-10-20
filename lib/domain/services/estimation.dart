import 'dart:math';

import '../../data/models/models.dart';

class Neighbor {
  const Neighbor(this.project, this.similarity);
  final Project project;
  final double similarity;
}

class Estimate {
  const Estimate({
    required this.hours,
    required this.hoursLow,
    required this.hoursHigh,
    required this.cost,
    required this.days,
    required this.confidence,
    required this.neighbors,
    required this.ratePerHour,
    required this.biasFactor,
    required this.usedFallback,
  });

  final double hours;
  final double hoursLow;
  final double hoursHigh;
  final double cost;
  final int days;
  final double confidence;
  final List<Neighbor> neighbors;
  final double ratePerHour;

  /// Mean (actual hours / estimated hours) over the freelancer's finished projects.
  final double biasFactor;
  final bool usedFallback;
}

/// Personalised effort and cost estimator.
///
/// Method: k-nearest-neighbours over the freelancer's own finished projects.
/// Each project becomes a weighted bag-of-features vector (domain, sub-domain,
/// technologies, description keywords); similarity is cosine similarity.
/// The prediction is a similarity-squared weighted mean of neighbours' ACTUAL
/// hours, scaled by relative complexity. More finished projects means better
/// neighbours, which is why estimates improve as the freelancer uses the app.
///
/// To use a trained model instead, keep this method's signature and call your
/// FastAPI / on-device model inside it.
class EstimationService {
  EstimationService._();

  static const _stop = {
    'the', 'and', 'for', 'with', 'that', 'this', 'from', 'will', 'have', 'users', 'user', 'app',
    'application', 'should', 'able', 'into', 'their', 'such', 'also', 'which', 'when', 'your', 'over',
  };

  static Iterable<String> _tokens(String s) => s
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9+#]+'))
      .where((w) => w.length > 2 && !_stop.contains(w));

  static Map<String, double> vectorize({
    required String domain,
    required String subDomain,
    required List<String> tech,
    required String text,
  }) {
    final v = <String, double>{};
    void add(String k, double w) => v[k] = (v[k] ?? 0) + w;
    for (final t in _tokens(domain)) {
      add('d:$t', 2.0);
    }
    for (final t in _tokens(subDomain)) {
      add('s:$t', 1.5);
    }
    for (final t in tech) {
      final k = t.toLowerCase().trim();
      if (k.isNotEmpty) add('t:$k', 2.5);
    }
    for (final t in _tokens(text)) {
      add('w:$t', 0.6);
    }
    return v;
  }

  static double cosine(Map<String, double> a, Map<String, double> b) {
    double dot = 0, na = 0, nb = 0;
    a.forEach((k, x) {
      na += x * x;
      final y = b[k];
      if (y != null) dot += x * y;
    });
    for (final y in b.values) {
      nb += y * y;
    }
    if (na == 0 || nb == 0) return 0;
    return dot / (sqrt(na) * sqrt(nb));
  }

  static Estimate estimate({
    required String domain,
    required String subDomain,
    required List<String> tech,
    required String description,
    required int complexity,
    required List<Project> history,
    required double fallbackRate,
    int k = 3,
  }) {
    final q = vectorize(domain: domain, subDomain: subDomain, tech: tech, text: description);
    final done = history.where((p) => p.isCompleted && p.actualHours > 0).toList();

    final scored = [
      for (final p in done)
        Neighbor(
          p,
          cosine(
            q,
            vectorize(domain: p.domain, subDomain: p.subDomain, tech: p.techStack, text: '${p.name} ${p.description}'),
          ),
        ),
    ]..sort((a, b) => b.similarity.compareTo(a.similarity));
    final top = scored.where((n) => n.similarity > 0.05).take(k).toList();

    final bias = done.isEmpty
        ? 1.0
        : done.map((p) => p.actualHours / p.estimatedHours).reduce((a, b) => a + b) / done.length;

    double hours;
    double rate;
    double conf;
    var fallback = false;

    if (top.isEmpty) {
      fallback = true;
      hours = 25 * pow(complexity.clamp(1, 5), 1.6).toDouble();
      rate = fallbackRate;
      conf = 0.3;
    } else {
      double wsum = 0, hsum = 0, rsum = 0;
      for (final n in top) {
        final w = n.similarity * n.similarity;
        final adj = pow(complexity / max(1, n.project.complexity), 0.8).toDouble();
        hsum += w * n.project.actualHours * adj;
        rsum += w * (n.project.budget / n.project.actualHours);
        wsum += w;
      }
      hours = hsum / wsum;
      rate = rsum / wsum;
      final meanSim = top.map((n) => n.similarity).reduce((a, b) => a + b) / top.length;
      conf = (0.30 + 0.45 * meanSim + 0.06 * top.length).clamp(0.3, 0.95).toDouble();
    }

    final spread = (1 - conf) * 0.5 + 0.08;
    final days = (hours / 5.5 * 1.35).ceil();
    return Estimate(
      hours: hours.roundToDouble(),
      hoursLow: (hours * (1 - spread)).roundToDouble(),
      hoursHigh: (hours * (1 + spread * 1.3)).roundToDouble(),
      cost: (hours * rate / 500).round() * 500.0,
      days: days,
      confidence: conf,
      neighbors: top,
      ratePerHour: rate,
      biasFactor: bias,
      usedFallback: fallback,
    );
  }
}
