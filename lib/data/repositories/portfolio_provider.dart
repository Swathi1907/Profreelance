import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'client_repository.dart';
import 'contract_repository.dart';
import 'milestone_repository.dart';
import 'project_repository.dart';
import 'vault_repository.dart';

/// Combines the repositories into one snapshot for the domain services.
final portfolioProvider = Provider<Portfolio>((ref) => Portfolio(
      projects: ref.watch(projectRepositoryProvider),
      milestones: ref.watch(milestoneRepositoryProvider),
      clients: ref.watch(clientRepositoryProvider),
      contracts: ref.watch(contractRepositoryProvider),
      docs: ref.watch(vaultRepositoryProvider),
    ));
