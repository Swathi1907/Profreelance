import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/portfolio_provider.dart';
import '../../../data/repositories/vault_repository.dart';
import '../../../domain/domain_providers.dart';
import '../../../domain/services/client_scoring.dart';
import '../../../domain/services/contract_analyzer.dart';

/// Analyses a contract the client sent: extracts clauses, flags risks, lists
/// missing terms, and combines the result with the client's reliability.
class AnalyzerViewModel extends BaseViewModel {
  AnalyzerViewModel(super.ref, this.projectId) {
    watch(portfolioProvider);
  }

  static const stages = ['Reading the document', 'Extracting clauses', 'Classifying clause types', 'Scoring risks and missing terms'];

  final String? projectId;
  String text = '';
  bool running = false;
  int stage = 0;
  AnalysisResult? result;

  Project? get project => projectId == null ? null : ref.read(portfolioProvider).project(projectId!);
  Client? get client => project == null ? null : ref.read(portfolioProvider).client(project!.clientId);
  ClientScore? get score => client == null ? null : ref.read(scoresProvider)[client!.id];

  void setText(String v) {
    text = v;
    refresh();
  }

  void loadSample() {
    text = ContractAnalyzer.sampleClientContract;
    result = null;
    refresh();
  }

  void reset() {
    result = null;
    refresh();
  }

  Future<void> analyze() async {
    if (text.trim().length < 40) return;
    running = true;
    stage = 0;
    result = null;
    refresh();
    for (var i = 0; i < stages.length; i++) {
      stage = i;
      refresh();
      await Future<void>.delayed(const Duration(milliseconds: 550));
    }
    result = ContractAnalyzer.analyze(text);
    running = false;
    refresh();
  }

  /// Combined advice from the contract risk and the client's reliability.
  String? get verdict {
    final r = result;
    if (r == null) return null;
    final risky = score?.isRisky ?? false;
    if (r.risk >= 60 && risky) return 'High-risk contract from a client with a weak payment record. Do not sign without the changes below, and take 50% upfront.';
    if (r.risk >= 60) return 'The contract is one-sided. Negotiate the red items first; the client\'s record is acceptable.';
    if (risky) return 'The contract is acceptable, but the client pays late. Add a larger advance and a late-fee clause.';
    if (r.risk >= 35) return 'Mostly workable. Fix the flagged items and add the missing protections.';
    return 'Looks balanced. Add any missing terms and you can sign.';
  }

  String get counterProposal => result == null ? '' : ContractAnalyzer.counterProposal(result!);
  Future<void> copyCounter() => Clipboard.setData(ClipboardData(text: counterProposal));

  void saveReport() {
    final r = result;
    if (r == null) return;
    final repo = ref.read(vaultRepositoryProvider.notifier);
    repo.add(VaultDoc(
      id: repo.nextId(),
      name: 'Contract_analysis_${client?.name.replaceAll(' ', '_') ?? 'client'}.txt',
      category: DocCategory.proposals,
      projectId: projectId,
      sizeKb: 12,
      addedAt: DateTime.now(),
      tags: const ['analysis', 'risk'],
    ));
  }
}

final analyzerViewModelProvider =
    ChangeNotifierProvider.autoDispose.family<AnalyzerViewModel, String>((ref, pid) => AnalyzerViewModel(ref, pid.isEmpty ? null : pid));
