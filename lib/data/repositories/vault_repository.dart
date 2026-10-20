import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'seed_provider.dart';

/// Metadata for the document vault. Files themselves would live in a Supabase Storage bucket.
class VaultRepository extends Notifier<List<VaultDoc>> {
  int _seq = 100;

  @override
  List<VaultDoc> build() => ref.read(seedProvider).docs;

  String nextId() => 'd${_seq++}';

  void add(VaultDoc d) => state = [d, ...state];
  void remove(String id) => state = state.where((d) => d.id != id).toList();
}

final vaultRepositoryProvider = NotifierProvider<VaultRepository, List<VaultDoc>>(VaultRepository.new);
