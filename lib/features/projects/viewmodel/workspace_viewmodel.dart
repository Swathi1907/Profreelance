import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../../data/repositories/portfolio_provider.dart';
import '../../../data/repositories/project_repository.dart';
import '../../../domain/domain_providers.dart';
import '../../../domain/services/client_scoring.dart';

/// Everything about one project, for its workspace screen and tabs.
class WorkspaceViewModel extends BaseViewModel {
  WorkspaceViewModel(super.ref, this.projectId) {
    watch(portfolioProvider);
    watch(scoresProvider);
  }

  final String projectId;

  Portfolio get _p => ref.read(portfolioProvider);
  Project? get project => _p.project(projectId);
  Client? get client => project == null ? null : _p.client(project!.clientId);
  ClientScore? get score => client == null ? null : ref.read(scoresProvider)[client!.id];

  List<Milestone> get milestones => _p.milestonesOf(projectId);
  List<Contract> get contracts => _p.contracts.where((c) => c.projectId == projectId).toList()..sort((a, b) => b.version.compareTo(a.version));
  List<VaultDoc> get docs => _p.docs.where((d) => d.projectId == projectId).toList();

  int get paidCount => milestones.where((m) => m.paidOn != null).length;
  double get progress => milestones.isEmpty ? 0 : paidCount / milestones.length;
  double get paidAmount => milestones.where((m) => m.paidOn != null).fold(0.0, (s, m) => s + m.amount);
  double get pendingAmount => milestones.where((m) => m.paidOn == null).fold(0.0, (s, m) => s + m.amount);
  double get overdueAmount {
    final now = DateTime.now();
    return milestones.where((m) => m.statusAt(now) == MilestoneStatus.overdue).fold(0.0, (s, m) => s + m.amount);
  }

  double get burn {
    final p = project;
    return p == null || p.estimatedHours == 0 ? 0 : p.actualHours / p.estimatedHours;
  }

  /// Hours at completion if the current pace continues (hours used / progress).
  double? get forecastHours {
    final p = project;
    if (p == null || p.actualHours == 0 || progress < 0.1) return null;
    return p.actualHours / progress;
  }

  void start() => ref.read(projectRepositoryProvider.notifier).start(projectId);
  void complete() => ref.read(projectRepositoryProvider.notifier).complete(projectId);
  void markPaid(String id) => ref.read(milestoneRepositoryProvider.notifier).markPaid(id, DateTime.now());
}

final workspaceViewModelProvider =
    ChangeNotifierProvider.autoDispose.family<WorkspaceViewModel, String>((ref, id) => WorkspaceViewModel(ref, id));
