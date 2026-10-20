import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/portfolio_provider.dart';
import '../../../data/repositories/project_repository.dart';

enum ProjectSort { dueDate, name, budget, progress }

extension ProjectSortX on ProjectSort {
  String get label => switch (this) {
        ProjectSort.dueDate => 'Due date',
        ProjectSort.name => 'Name',
        ProjectSort.budget => 'Budget',
        ProjectSort.progress => 'Progress',
      };
}

/// State and logic for the "Projects Directory" list.
class ProjectsViewModel extends BaseViewModel {
  ProjectsViewModel(super.ref) {
    watch(portfolioProvider);
  }

  String query = '';
  int tab = 0; // 0 all, 1 not started, 2 in progress, 3 completed
  ProjectSort sort = ProjectSort.dueDate;

  static const tabs = ['All', 'Not started', 'In progress', 'Completed'];

  Portfolio get _p => ref.read(portfolioProvider);

  void setQuery(String v) {
    query = v;
    refresh();
  }

  void setTab(int v) {
    tab = v;
    refresh();
  }

  void setSort(ProjectSort s) {
    sort = s;
    refresh();
  }

  bool _inTab(Project p, int t) => switch (t) {
        1 => p.status == ProjectStatus.notStarted,
        2 => p.status == ProjectStatus.inProgress,
        3 => p.status == ProjectStatus.completed,
        _ => true,
      };

  int count(int t) => _p.projects.where((p) => _inTab(p, t)).length;

  String clientName(Project p) => _p.client(p.clientId)?.name ?? '-';

  List<Milestone> milestones(Project p) => _p.milestonesOf(p.id);
  int paidCount(Project p) => milestones(p).where((m) => m.paidOn != null).length;
  double progress(Project p) {
    final ms = milestones(p);
    return ms.isEmpty ? 0 : paidCount(p) / ms.length;
  }

  List<Project> get visible {
    final q = query.trim().toLowerCase();
    final l = _p.projects.where((p) {
      if (!_inTab(p, tab)) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) || clientName(p).toLowerCase().contains(q) || p.domain.toLowerCase().contains(q);
    }).toList();
    l.sort((a, b) => switch (sort) {
          ProjectSort.dueDate => a.dueDate.compareTo(b.dueDate),
          ProjectSort.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          ProjectSort.budget => b.budget.compareTo(a.budget),
          ProjectSort.progress => progress(b).compareTo(progress(a)),
        });
    return l;
  }

  void start(String id) => ref.read(projectRepositoryProvider.notifier).start(id);
}

final projectsViewModelProvider = ChangeNotifierProvider.autoDispose<ProjectsViewModel>((ref) => ProjectsViewModel(ref));
