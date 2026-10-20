import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'seed_provider.dart';

class MilestoneRepository extends Notifier<List<Milestone>> {
  int _seq = 5000;

  @override
  List<Milestone> build() => ref.read(seedProvider).milestones;

  String nextId() => 'm${_seq++}';

  List<Milestone> forProject(String projectId) =>
      state.where((m) => m.projectId == projectId).toList()..sort((a, b) => a.due.compareTo(b.due));

  void add(Milestone m) => state = [...state, m];
  void addAll(List<Milestone> ms) => state = [...state, ...ms];

  void markPaid(String id, DateTime on) => state = [for (final m in state) m.id == id ? m.markPaid(on) : m];
}

final milestoneRepositoryProvider = NotifierProvider<MilestoneRepository, List<Milestone>>(MilestoneRepository.new);
