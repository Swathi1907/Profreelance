import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../core/utils/format.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../../data/repositories/portfolio_provider.dart';
import '../../../domain/domain_providers.dart';
import '../../../domain/services/analytics.dart';

class PaymentsViewModel extends BaseViewModel {
  PaymentsViewModel(super.ref) {
    watch(portfolioProvider);
  }

  String? projectId;
  MilestoneStatus? status;

  Portfolio get _p => ref.read(portfolioProvider);
  DateTime get _now => DateTime.now();

  List<Project> get projects => _p.projects.where((p) => !p.isDraft).toList();
  String projectName(String id) => _p.project(id)?.name ?? 'Project';
  String clientNameOf(String projectId) {
    final p = _p.project(projectId);
    return p == null ? 'Client' : (_p.client(p.clientId)?.name ?? 'Client');
  }

  void setProject(String? id) {
    projectId = id;
    refresh();
  }

  void setStatus(MilestoneStatus? s) {
    status = s;
    refresh();
  }

  List<Milestone> get visible {
    final l = _p.milestones.where((m) {
      if (projectId != null && m.projectId != projectId) return false;
      if (status != null && m.statusAt(_now) != status) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.due.compareTo(b.due));
    return l;
  }

  /// Visible milestones grouped by project name.
  Map<String, List<Milestone>> get grouped {
    final out = <String, List<Milestone>>{};
    for (final m in visible) {
      out.putIfAbsent(projectName(m.projectId), () => []).add(m);
    }
    return out;
  }

  double _sum(Iterable<Milestone> l) => l.fold(0.0, (s, m) => s + m.amount);
  Iterable<Milestone> get _scope => _p.milestones.where((m) => projectId == null || m.projectId == projectId);

  double get received => _sum(_scope.where((m) => m.paidOn != null));
  double get pending => _sum(_scope.where((m) => m.statusAt(_now) == MilestoneStatus.pending));
  double get overdue => _sum(_scope.where((m) => m.statusAt(_now) == MilestoneStatus.overdue));
  double get dueNext30 {
    final end = _now.add(const Duration(days: 30));
    return _sum(_scope.where((m) => m.paidOn == null && !m.due.isAfter(end)));
  }

  /// Share of invoiced money that has actually arrived.
  double get collectionRate {
    final total = received + pending + overdue;
    return total == 0 ? 0 : received / total * 100;
  }

  List<Month> get cashflow => ref.read(analyticsProvider).cashflow;

  void markPaid(String id) => ref.read(milestoneRepositoryProvider.notifier).markPaid(id, _now);

  void addMilestone({required String projectId, required String title, required double amount, required DateTime due, String clause = ''}) {
    final repo = ref.read(milestoneRepositoryProvider.notifier);
    repo.add(Milestone(id: repo.nextId(), projectId: projectId, title: title, amount: amount, due: due, clause: clause));
  }

  String reminderText(Milestone m) {
    final late = m.statusAt(_now) == MilestoneStatus.overdue;
    return 'Hi ${clientNameOf(m.projectId)} team,\n\n'
        '${late ? 'A gentle reminder that' : 'This is a note that'} the invoice for "${m.title}" on ${projectName(m.projectId)} '
        '(${inr(m.amount)}) ${late ? 'was due on' : 'falls due on'} ${fmtDate(m.due)}'
        '${m.clause.isEmpty ? '' : ', as per clause ${m.clause} of our agreement'}.\n\n'
        '${late ? 'Could you please confirm the payment date? Late payment interest applies after the grace period in the contract.' : 'Please let me know if you need anything from my side.'}\n\nThank you!';
  }
}

final paymentsViewModelProvider = ChangeNotifierProvider.autoDispose<PaymentsViewModel>((ref) => PaymentsViewModel(ref));
