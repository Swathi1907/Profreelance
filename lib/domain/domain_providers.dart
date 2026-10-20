import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import '../data/repositories/portfolio_provider.dart';
import '../data/repositories/preferences_repository.dart';
import 'services/alert_engine.dart';
import 'services/analytics.dart';
import 'services/client_scoring.dart';

/// Reliability score for every client, recomputed whenever payments, projects
/// or reviews change.
final scoresProvider = Provider<Map<String, ClientScore>>((ref) {
  final p = ref.watch(portfolioProvider);
  return {for (final c in p.clients) c.id: ClientScoring.score(c, p.milestones, p.projects)};
});

final analyticsProvider = Provider<AnalyticsSummary>((ref) => Analytics.compute(ref.watch(portfolioProvider)));

final alertsProvider = Provider<List<AppAlert>>((ref) {
  final prefs = ref.watch(preferencesProvider);
  return AlertEngine.generate(
    ref.watch(portfolioProvider),
    leadDays: prefs.alertLeadDays,
    dismissed: prefs.dismissedAlerts,
  );
});
