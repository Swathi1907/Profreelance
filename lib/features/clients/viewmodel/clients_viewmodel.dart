import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/client_repository.dart';
import '../../../data/repositories/milestone_repository.dart';
import '../../../data/repositories/portfolio_provider.dart';
import '../../../domain/domain_providers.dart';
import '../../../domain/services/client_scoring.dart';
import '../../dashboard/viewmodel/dashboard_viewmodel.dart';

/// Overview of every client plus the overall client experience.
class ClientsViewModel extends BaseViewModel {
  ClientsViewModel(super.ref) {
    watch(portfolioProvider);
    watch(scoresProvider);
  }

  String? tierFilter;

  Portfolio get _p => ref.read(portfolioProvider);
  Map<String, ClientScore> get scores => ref.read(scoresProvider);
  ClientExperience get experience => ClientExperience.compute(_p.clients, scores);

  List<String> get tiers => const ['Reliable', 'Good', 'Cautious', 'High risk', 'New client'];

  void setTier(String? t) {
    tierFilter = t;
    refresh();
  }

  List<Client> get visible {
    final l = _p.clients.where((c) => c.id != 'c7' && (tierFilter == null || scores[c.id]!.tier == tierFilter)).toList();
    l.sort((a, b) => scores[b.id]!.overall.compareTo(scores[a.id]!.overall));
    return l;
  }

  int projectCount(String clientId) => _p.projects.where((p) => p.clientId == clientId).length;
}

final clientsViewModelProvider = ChangeNotifierProvider.autoDispose<ClientsViewModel>((ref) => ClientsViewModel(ref));

/// One client's profile, payment record and reviews.
class ClientDetailViewModel extends BaseViewModel {
  ClientDetailViewModel(super.ref, this.clientId) {
    watch(portfolioProvider);
    watch(scoresProvider);
  }

  final String clientId;
  Portfolio get _p => ref.read(portfolioProvider);
  Client? get client => _p.client(clientId);
  ClientScore? get score => ref.read(scoresProvider)[clientId];
  List<Project> get projects => _p.projects.where((p) => p.clientId == clientId).toList();
  List<Milestone> get payments {
    final ids = projects.map((p) => p.id).toSet();
    return _p.milestones.where((m) => ids.contains(m.projectId)).toList()..sort((a, b) => b.due.compareTo(a.due));
  }

  List<ClientReview> get reviews => [...?client?.reviews]..sort((a, b) => b.date.compareTo(a.date));

  void addReview({required int punctuality, required int stability, required int communication, required int overall, String projectName = '', String note = ''}) {
    ref.read(clientRepositoryProvider.notifier).addReview(
          clientId,
          ClientReview(
            id: 'r${DateTime.now().millisecondsSinceEpoch}',
            date: DateTime.now(),
            punctuality: punctuality,
            stability: stability,
            communication: communication,
            overall: overall,
            projectName: projectName,
            note: note,
          ),
        );
  }

  void markPaid(String id) => ref.read(milestoneRepositoryProvider.notifier).markPaid(id, DateTime.now());
}

final clientDetailViewModelProvider =
    ChangeNotifierProvider.autoDispose.family<ClientDetailViewModel, String>((ref, id) => ClientDetailViewModel(ref, id));
