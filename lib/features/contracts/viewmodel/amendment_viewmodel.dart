import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/contract_repository.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../../data/repositories/portfolio_provider.dart';
import '../../../data/repositories/preferences_repository.dart';
import '../../../data/repositories/project_repository.dart';
import '../../../domain/services/amendment_service.dart';

/// Four-step change-request wizard: the change, its technical impact, schedule
/// and pricing, then a review with an explained estimate.
class AmendmentViewModel extends BaseViewModel {
  AmendmentViewModel(super.ref, this.projectId) {
    watch(portfolioProvider);
    inputs = AmendmentInputs(project!);
    inputs.complexity = project!.complexity;
  }

  static const steps = ['Change request', 'Technical impact', 'Schedule and pricing', 'Review'];

  final String projectId;
  late AmendmentInputs inputs;
  int step = 0;
  bool estimating = false;
  AmendmentEstimate? estimate;
  Map<String, String> errors = {};

  Project? get project => ref.read(portfolioProvider).project(projectId);
  Client? get client => project == null ? null : ref.read(portfolioProvider).client(project!.clientId);

  List<String> get componentOptions {
    final s = <String>{...?project?.technicalComponents, 'Authentication', 'Payments', 'Database', 'Third-party APIs', 'Real-time', 'Admin Dashboard', 'Analytics', 'Push Notifications', 'File Storage', 'Search'};
    return s.toList();
  }

  int get amendmentNumber => ref.read(contractRepositoryProvider.notifier).nextVersion(projectId) - 1;

  void update(void Function(AmendmentInputs i) change) {
    change(inputs);
    if (errors.isNotEmpty) _validate(step);
    refresh();
  }

  void toggle(Set<String> set, String v) => update((_) => set.contains(v) ? set.remove(v) : set.add(v));

  bool _validate(int s) {
    final e = <String, String>{};
    if (s == 0) {
      if (inputs.title.trim().isEmpty) e['title'] = 'Give the change a short title.';
      if (inputs.description.trim().length < 20) e['description'] = 'Describe the change in at least 20 characters.';
    }
    if (s == 2 && inputs.manualPricing && (double.tryParse(inputs.manualCost) ?? 0) <= 0) {
      e['manualCost'] = 'Enter the amount you want to charge.';
    }
    errors = e;
    return e.isEmpty;
  }

  Future<void> next() async {
    if (!_validate(step)) {
      refresh();
      return;
    }
    if (step == 2) {
      estimating = true;
      refresh();
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (isDisposed) return;
      estimate = AmendmentEstimator.estimate(
        a: inputs,
        history: ref.read(projectRepositoryProvider),
        fallbackRate: ref.read(preferencesProvider).hourlyRate,
      );
      estimating = false;
    }
    if (step < steps.length - 1) step++;
    refresh();
  }

  void back() {
    if (step > 0) step--;
    errors = {};
    refresh();
  }

  List<ContractClause> get clauses => estimate == null ? [] : AmendmentEstimator.document(inputs, estimate!, amendmentNumber);

  /// Creates the amendment, updates price and date, and adds the payment milestone.
  String? save() {
    final e = estimate;
    final p = project;
    if (e == null || p == null) return null;
    final repo = ref.read(contractRepositoryProvider.notifier);
    final contract = Contract(
      id: repo.nextId(),
      projectId: projectId,
      version: repo.nextVersion(projectId),
      status: ContractStatus.amendmentPending,
      createdAt: DateTime.now(),
      clauses: clauses,
      title: '${p.name} - Amendment No. $amendmentNumber',
      summary: '${inputs.title}: +${e.cost.round()} ${p.currency}, +${e.extraDays} days',
    );
    repo.add(contract);
    ref.read(projectRepositoryProvider.notifier).applyAmendment(projectId, extraCost: e.cost, extraHours: e.totalHours, extraDays: e.extraDays);
    if (inputs.milestoneHandling == kMilestoneHandling[0]) {
      final ms = ref.read(milestoneRepositoryProvider.notifier);
      ms.add(Milestone(
        id: ms.nextId(),
        projectId: projectId,
        title: 'Amendment: ${inputs.title}',
        amount: e.cost,
        due: inputs.effectiveDate.add(const Duration(days: 14)),
        clause: 'A$amendmentNumber',
      ));
    }
    return contract.id;
  }
}

final amendmentViewModelProvider =
    ChangeNotifierProvider.autoDispose.family<AmendmentViewModel, String>((ref, id) => AmendmentViewModel(ref, id));
