import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/portfolio_provider.dart';
import '../../../data/repositories/preferences_repository.dart';
import '../../../domain/domain_providers.dart';
import '../../../domain/services/analytics.dart';
import '../../../domain/services/client_scoring.dart';

class ClientExperience {
  const ClientExperience({required this.average, required this.tiers, required this.onTimeRate, required this.best, required this.needsAttention, required this.rated});
  final double average;
  final Map<String, int> tiers;
  final double? onTimeRate;
  final Client? best;
  final Client? needsAttention;
  final int rated;

  static ClientExperience compute(List<Client> clients, Map<String, ClientScore> scores) {
    final rated = clients.where((c) => scores[c.id]!.samples > 0).toList();
    if (rated.isEmpty) {
      return const ClientExperience(average: 0, tiers: {}, onTimeRate: null, best: null, needsAttention: null, rated: 0);
    }
    final avg = rated.map((c) => scores[c.id]!.overall).reduce((a, b) => a + b) / rated.length;
    final tiers = <String, int>{};
    for (final c in rated) {
      tiers[scores[c.id]!.tier] = (tiers[scores[c.id]!.tier] ?? 0) + 1;
    }
    final onTimes = rated.map((c) => scores[c.id]!.onTimeRate).whereType<double>().toList();
    final sorted = [...rated]..sort((a, b) => scores[b.id]!.overall.compareTo(scores[a.id]!.overall));
    return ClientExperience(
      average: avg,
      tiers: tiers,
      onTimeRate: onTimes.isEmpty ? null : onTimes.reduce((a, b) => a + b) / onTimes.length,
      best: sorted.first,
      needsAttention: sorted.last,
      rated: rated.length,
    );
  }
}

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel(super.ref) {
    watch(portfolioProvider);
    watch(scoresProvider);
    watch(alertsProvider);
    watch(preferencesProvider);
  }

  Portfolio get _p => ref.read(portfolioProvider);
  String get userName => ref.read(preferencesProvider).userName;

  List<Project> get inProgress => _p.projects.where((x) => x.status == ProjectStatus.inProgress).toList();
  List<Project> get upcoming => _p.projects.where((x) => x.status == ProjectStatus.notStarted && !x.isDraft).toList();
  int get completedCount => _p.projects.where((x) => x.isCompleted).length;
  int get draftCount => _p.projects.where((x) => x.isDraft).length;
  List<Project> get live => [...inProgress, ...upcoming];

  Iterable<Milestone> get _liveMilestones {
    final ids = live.map((p) => p.id).toSet();
    return _p.milestones.where((m) => ids.contains(m.projectId));
  }

  double get contractValue => _liveMilestones.fold(0.0, (s, m) => s + m.amount);
  double get collected => _liveMilestones.where((m) => m.paidOn != null).fold(0.0, (s, m) => s + m.amount);
  double get progress => contractValue == 0 ? 0 : collected / contractValue;
  double get outstanding => _p.milestones.where((m) => m.paidOn == null).fold(0.0, (s, m) => s + m.amount);

  List<Milestone> get overdue {
    final now = DateTime.now();
    return _p.milestones.where((m) => m.statusAt(now) == MilestoneStatus.overdue).toList();
  }

  double projectProgress(Project p) {
    final ms = _p.milestonesOf(p.id);
    return ms.isEmpty ? 0 : ms.where((m) => m.paidOn != null).length / ms.length;
  }

  String clientName(String id) => _p.client(id)?.name ?? 'Client';

  List<Project> get nextDeadlines {
    final l = [...inProgress]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return l.take(4).toList();
  }

  List<AppAlert> get topAlerts => ref.read(alertsProvider).take(3).toList();
  int get alertCount => ref.read(alertsProvider).length;
  List<Month> get cashflow => ref.read(analyticsProvider).cashflow;

  ClientExperience get clientExperience => ClientExperience.compute(_p.clients, ref.read(scoresProvider));

  ClientScore? scoreOf(String clientId) => ref.read(scoresProvider)[clientId];
}

final dashboardViewModelProvider = ChangeNotifierProvider.autoDispose<DashboardViewModel>((ref) => DashboardViewModel(ref));
