import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'seed_provider.dart';

class ContractRepository extends Notifier<List<Contract>> {
  int _seq = 100;

  @override
  List<Contract> build() => ref.read(seedProvider).contracts;

  String nextId() => 'k${_seq++}';

  Contract? byId(String id) {
    for (final c in state) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<Contract> forProject(String projectId) =>
      state.where((c) => c.projectId == projectId).toList()..sort((a, b) => b.version.compareTo(a.version));

  int nextVersion(String projectId) => forProject(projectId).length + 1;

  void add(Contract c) => state = [c, ...state];

  void setStatus(String id, ContractStatus s) => state = [for (final c in state) c.id == id ? c.withStatus(s) : c];
}

final contractRepositoryProvider = NotifierProvider<ContractRepository, List<Contract>>(ContractRepository.new);
