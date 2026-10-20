import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/contract_repository.dart';
import '../../../data/repositories/portfolio_provider.dart';
import '../../../data/repositories/preferences_repository.dart';
import '../../../domain/domain_providers.dart';
import '../../../domain/services/contract_analyzer.dart';
import '../../../domain/services/contract_builder.dart';

/// Five-step contract generator: parties, scope and technical details,
/// payment and schedule, legal terms, then review with a risk self-check.
class ContractWizardViewModel extends BaseViewModel {
  ContractWizardViewModel(super.ref, String? projectId) {
    watch(portfolioProvider);
    if (projectId != null) selectProject(projectId);
  }

  static const steps = ['Project and parties', 'Scope and technical', 'Payment and schedule', 'Legal terms', 'Review'];

  int step = 0;
  ContractInputs? inputs;
  String? projectId;
  Map<String, String> errors = {};

  List<ContractClause> clauses = [];
  final Set<String> excluded = {};
  AnalysisResult? health;

  Portfolio get _p => ref.read(portfolioProvider);
  List<Project> get projects => _p.projects.where((p) => !p.isDraft).toList();
  String projectName(String id) => _p.project(id)?.name ?? 'Project';

  void selectProject(String id) {
    final p = _p.project(id);
    if (p == null) return;
    projectId = id;
    final client = _p.client(p.clientId);
    final prefs = ref.read(preferencesProvider);
    inputs = ContractInputs.defaults(
      p,
      client,
      _p.milestonesOf(id),
      score: client == null ? null : ref.read(scoresProvider)[client.id],
      freelancer: prefs.userName,
      rate: prefs.hourlyRate,
    )
      ..freelancerAddress = prefs.address
      ..freelancerGstin = prefs.gstin;
    errors = {};
    refresh();
  }

  void update(void Function(ContractInputs i) change) {
    if (inputs == null) return;
    change(inputs!);
    if (errors.isNotEmpty) _validate(step);
    refresh();
  }

  void toggle(Set<String> set, String v) => update((_) => set.contains(v) ? set.remove(v) : set.add(v));

  bool _validate(int s) {
    final e = <String, String>{};
    final i = inputs;
    if (s == 0) {
      if (i == null) e['project'] = 'Choose the project this contract is for.';
      if (i != null && i.clientLegalName.trim().isEmpty) e['clientName'] = 'Enter the client\'s legal name.';
    } else if (i != null && s == 1) {
      if (i.deliverables.trim().isEmpty) e['deliverables'] = 'List at least one deliverable.';
      if (i.acceptanceCriteria.trim().length < 10) e['acceptance'] = 'State how each deliverable will be accepted (for example "all test cases pass").';
    } else if (i != null && s == 2) {
      if (i.totalFee <= 0) e['fee'] = 'Enter the total fee.';
      if (i.advancePct < 0 || i.advancePct > 100) e['advance'] = 'Enter 0 to 100.';
    }
    errors = e;
    return e.isEmpty;
  }

  void next() {
    if (!_validate(step)) {
      refresh();
      return;
    }
    if (step < steps.length - 1) {
      step++;
      if (step == steps.length - 1) _build();
    }
    refresh();
  }

  void back() {
    if (step > 0) step--;
    errors = {};
    refresh();
  }

  void _build() {
    clauses = ContractBuilder.build(inputs!);
    excluded.clear();
    _check();
  }

  List<ContractClause> get included => clauses.where((c) => !excluded.contains(c.id)).toList();

  void _check() => health = ContractAnalyzer.analyze(preview);

  void toggleClause(String id) {
    excluded.contains(id) ? excluded.remove(id) : excluded.add(id);
    _check();
    refresh();
  }

  int get nextVersion => projectId == null ? 1 : ref.read(contractRepositoryProvider.notifier).nextVersion(projectId!);
  String get preview => inputs == null ? '' : ContractBuilder.render(inputs!, included, version: nextVersion);

  String? save(ContractStatus status) {
    final i = inputs;
    if (i == null) return null;
    final repo = ref.read(contractRepositoryProvider.notifier);
    final c = Contract(
      id: repo.nextId(),
      projectId: i.project.id,
      version: nextVersion,
      status: status,
      createdAt: DateTime.now(),
      clauses: included,
      title: '${i.project.name} - Services Agreement',
    );
    repo.add(c);
    return c.id;
  }
}

final contractWizardViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<ContractWizardViewModel, String>((ref, pid) => ContractWizardViewModel(ref, pid.isEmpty ? null : pid));
