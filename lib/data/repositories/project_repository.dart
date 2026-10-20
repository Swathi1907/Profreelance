import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'seed_provider.dart';

/// Model layer for projects. Swap the bodies for Supabase `from('projects')` calls.
class ProjectRepository extends Notifier<List<Project>> {
  @override
  List<Project> build() => ref.read(seedProvider).projects;

  Project? byId(String id) {
    for (final p in state) {
      if (p.id == id) return p;
    }
    return null;
  }

  void add(Project p) => state = [p, ...state];

  void replace(Project p) => state = [for (final x in state) x.id == p.id ? p : x];

  void start(String id) => _map(id, (p) => p.copyWith(status: ProjectStatus.inProgress, isDraft: false));

  void complete(String id) => _map(id, (p) => p.copyWith(status: ProjectStatus.completed, endDate: DateTime.now()));

  void applyAmendment(String id, {required double extraCost, required double extraHours, required int extraDays}) {
    _map(
      id,
      (p) => p.copyWith(
        budget: p.budget + extraCost,
        estimatedHours: p.estimatedHours + extraHours,
        dueDate: p.dueDate.add(Duration(days: extraDays)),
        changeRequests: p.changeRequests + 1,
      ),
    );
  }

  void _map(String id, Project Function(Project) f) => state = [for (final p in state) p.id == id ? f(p) : p];
}

final projectRepositoryProvider = NotifierProvider<ProjectRepository, List<Project>>(ProjectRepository.new);
