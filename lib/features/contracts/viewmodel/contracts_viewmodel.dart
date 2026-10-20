import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/contract_repository.dart';
import '../../../data/repositories/portfolio_provider.dart';
import '../../../domain/services/contract_analyzer.dart';
import '../../../domain/services/contract_builder.dart';

/// The Contracts tab: every contract version, filterable by project and status.
class ContractsViewModel extends BaseViewModel {
  ContractsViewModel(super.ref) {
    watch(portfolioProvider);
  }

  String? projectId;
  ContractStatus? status;

  Portfolio get _p => ref.read(portfolioProvider);
  List<Project> get projects => _p.projects.where((p) => !p.isDraft).toList();
  String projectName(String id) => _p.project(id)?.name ?? 'Project';
  String clientName(String projectId) {
    final p = _p.project(projectId);
    return p == null ? '' : (_p.client(p.clientId)?.name ?? '');
  }

  List<Contract> get visible {
    final l = _p.contracts.where((c) => (projectId == null || c.projectId == projectId) && (status == null || c.status == status)).toList();
    l.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return l;
  }

  int count(ContractStatus s) => _p.contracts.where((c) => c.status == s).length;

  void setProject(String? id) {
    projectId = id;
    refresh();
  }

  void setStatus(ContractStatus? s) {
    status = s;
    refresh();
  }
}

final contractsViewModelProvider = ChangeNotifierProvider.autoDispose<ContractsViewModel>((ref) => ContractsViewModel(ref));

/// One contract: reading, status changes, copy, and a risk self-check.
class ContractViewModel extends BaseViewModel {
  ContractViewModel(super.ref, this.contractId) {
    watch(contractRepositoryProvider);
    watch(portfolioProvider);
  }

  final String contractId;
  AnalysisResult? health;

  Contract? get contract => ref.read(contractRepositoryProvider.notifier).byId(contractId);
  Project? get project => contract == null ? null : ref.read(portfolioProvider).project(contract!.projectId);
  List<Contract> get versions => contract == null ? [] : ref.read(contractRepositoryProvider.notifier).forProject(contract!.projectId);

  String get text => contract == null ? '' : ContractBuilder.renderContract(contract!);

  void setStatus(ContractStatus s) => ref.read(contractRepositoryProvider.notifier).setStatus(contractId, s);
  Future<void> copy() => Clipboard.setData(ClipboardData(text: text));

  void runHealthCheck() {
    health = ContractAnalyzer.analyze(text);
    refresh();
  }
}

final contractViewModelProvider =
    ChangeNotifierProvider.autoDispose.family<ContractViewModel, String>((ref, id) => ContractViewModel(ref, id));
