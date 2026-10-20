import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../data/catalog/catalog.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../../data/repositories/preferences_repository.dart';
import '../../../data/repositories/project_repository.dart';
import '../../../domain/services/estimation.dart';
import '../../../domain/services/milestone_planner.dart';

/// State, validation and saving for the "Create New Project" screen.
class ProjectFormViewModel extends BaseViewModel {
  ProjectFormViewModel(super.ref) {
    watch(preferencesProvider);
    watch(clientRepositoryProvider);
  }

  // basics
  String title = '';
  String clientName = '';
  String domain = '';
  String subDomain = '';
  String objective = '';
  String description = '';
  // scope
  String deliverables = '';
  String exclusions = '';
  // estimation
  String duration = '';
  String durationUnit = 'Weeks';
  String hours = '';
  String budget = '';
  String currency = 'INR';
  // contract preferences
  String paymentStructure = kPaymentStructures[0];
  String advance = '20';
  String revisions = '2';
  DateTime? deliveryDate;
  String ip = kIpOptions[0];
  String jurisdiction = 'Bengaluru';
  bool nda = false;
  // technical
  String tech = '';
  int complexity = 3;
  final Set<String> components = {};
  final Set<String> deps = {};

  // AI estimate
  Estimate? estimate;
  bool estimating = false;
  int applied = 0; // bumped to force numeric fields to show new values

  bool submitted = false;
  Map<String, String> errors = {};

  List<String> get customDomains => ref.read(preferencesProvider).customDomains;
  List<String> get clientSuggestions => ref.read(clientRepositoryProvider).where((c) => c.id != 'c7').map((c) => c.name).toList();
  List<String> get subDomainHints => kSubDomainHints[domain] ?? const [];
  String get reviewBudget => budget.isEmpty ? '₹0' : '${currency == 'INR' ? '₹' : '$currency '}$budget';

  void update(void Function() change) {
    change();
    if (submitted) _validate();
    refresh();
  }

  void toggle(Set<String> set, String v) => update(() => set.contains(v) ? set.remove(v) : set.add(v));

  void addCustomDomain(String d) => ref.read(preferencesProvider.notifier).addDomain(d);

  // ---- estimation
  Future<void> runEstimate() async {
    if (domain.isEmpty) {
      errors = {...errors, 'domain': 'Choose a domain first so similar projects can be found.'};
      refresh();
      return;
    }
    estimating = true;
    refresh();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (isDisposed) return;
    estimate = EstimationService.estimate(
      domain: domain,
      subDomain: subDomain,
      tech: tech.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      description: '$title $objective $description ${components.join(' ')}',
      complexity: complexity,
      history: ref.read(projectRepositoryProvider),
      fallbackRate: ref.read(preferencesProvider).hourlyRate,
    );
    estimating = false;
    refresh();
  }

  void applyEstimate() {
    final e = estimate;
    if (e == null) return;
    hours = e.hours.round().toString();
    budget = e.cost.round().toString();
    duration = e.days.toString();
    durationUnit = 'Days';
    deliveryDate = DateTime.now().add(Duration(days: e.days));
    applied++;
    refresh();
  }

  // ---- validation
  bool _validate({bool draft = false}) {
    final e = <String, String>{};
    if (title.trim().isEmpty) e['title'] = 'Enter a project title.';
    if (!draft) {
      if (clientName.trim().isEmpty) e['client'] = 'Enter the client name.';
      if (domain.isEmpty) e['domain'] = 'Choose a domain, or add your own.';
      if (description.trim().length < 20) e['description'] = 'Describe the project in at least 20 characters.';
      if ((int.tryParse(duration) ?? 0) <= 0) e['duration'] = 'Enter a duration.';
      if ((double.tryParse(hours) ?? 0) <= 0) e['hours'] = 'Enter the expected working hours.';
      if ((double.tryParse(budget) ?? 0) <= 0) e['budget'] = 'Enter the project budget.';
      final adv = double.tryParse(advance);
      if (adv == null || adv < 0 || adv > 100) e['advance'] = 'Enter a percentage from 0 to 100.';
      if (int.tryParse(revisions) == null) e['revisions'] = 'Enter a number.';
    }
    errors = e;
    return e.isEmpty;
  }

  /// Saves the project and a default milestone plan. Returns the new id, or null if invalid.
  String? save({bool draft = false}) {
    submitted = true;
    final ok = _validate(draft: draft);
    refresh();
    if (!ok) return null;

    final client = ref.read(clientRepositoryProvider.notifier).ensure(clientName.isEmpty ? 'Unassigned' : clientName);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dur = int.tryParse(duration) ?? 0;
    final days = dur > 0 ? durationToDays(dur, durationUnit) : 30;
    final due = deliveryDate ?? today.add(Duration(days: days));
    final techList = tech.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final project = Project(
      id: 'p${now.millisecondsSinceEpoch}',
      name: title.trim(),
      clientId: client.id,
      domain: domain,
      subDomain: subDomain.trim(),
      description: description.trim(),
      objective: objective.trim(),
      techStack: techList,
      status: ProjectStatus.notStarted,
      startDate: today,
      dueDate: due,
      budget: double.tryParse(budget) ?? 0,
      estimatedHours: double.tryParse(hours) ?? 0,
      advancePct: double.tryParse(advance) ?? 20,
      revisions: int.tryParse(revisions) ?? 2,
      ipOwnership: ip,
      paymentStructure: paymentStructure,
      complexity: complexity,
      deliverables: deliverables.trim(),
      exclusions: exclusions.trim(),
      durationValue: dur,
      durationUnit: durationUnit,
      currency: currency,
      technicalComponents: components.toList(),
      externalDeps: deps.toList(),
      nda: nda,
      jurisdiction: jurisdiction.trim().isEmpty ? 'Bengaluru' : jurisdiction.trim(),
      isDraft: draft,
    );
    ref.read(projectRepositoryProvider.notifier).add(project);
    if (project.budget > 0) {
      final repo = ref.read(milestoneRepositoryProvider.notifier);
      repo.addAll(MilestonePlanner.plan(project, repo.nextId));
    }
    return project.id;
  }
}

final projectFormViewModelProvider = ChangeNotifierProvider.autoDispose<ProjectFormViewModel>((ref) => ProjectFormViewModel(ref));
