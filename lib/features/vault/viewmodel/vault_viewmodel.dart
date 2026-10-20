import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/portfolio_provider.dart';
import '../../../data/repositories/project_repository.dart';
import '../../../data/repositories/vault_repository.dart';

class VaultViewModel extends BaseViewModel {
  VaultViewModel(super.ref) {
    watch(portfolioProvider);
  }

  static const capacityKb = 5 * 1024 * 1024; // 5 GB

  String query = '';
  DocCategory? category;
  String? projectId;

  List<VaultDoc> get all => ref.read(vaultRepositoryProvider);
  List<Project> get projects => ref.read(projectRepositoryProvider);

  String projectName(String? id) {
    if (id == null) return 'General';
    for (final p in projects) {
      if (p.id == id) return p.name;
    }
    return 'General';
  }

  List<VaultDoc> get visible {
    final q = query.trim().toLowerCase();
    return all.where((d) {
      if (category != null && d.category != category) return false;
      if (projectId != null && d.projectId != projectId) return false;
      if (q.isEmpty) return true;
      return d.name.toLowerCase().contains(q) || d.tags.any((t) => t.toLowerCase().contains(q)) || projectName(d.projectId).toLowerCase().contains(q);
    }).toList();
  }

  int get usedKb => all.fold(0, (s, d) => s + d.sizeKb);
  double get usedFraction => usedKb / capacityKb;

  int countIn(DocCategory c) => all.where((d) => d.category == c).length;

  void setQuery(String v) {
    query = v;
    refresh();
  }

  void setCategory(DocCategory? c) {
    category = c;
    refresh();
  }

  void setProject(String? id) {
    projectId = id;
    refresh();
  }

  void add({required String name, required DocCategory category, String? projectId, int sizeKb = 240, List<String> tags = const []}) {
    final repo = ref.read(vaultRepositoryProvider.notifier);
    repo.add(VaultDoc(id: repo.nextId(), name: name, category: category, projectId: projectId, sizeKb: sizeKb, addedAt: DateTime.now(), tags: tags));
  }

  void remove(String id) => ref.read(vaultRepositoryProvider.notifier).remove(id);
}

final vaultViewModelProvider = ChangeNotifierProvider.autoDispose<VaultViewModel>((ref) => VaultViewModel(ref));

String formatSize(int kb) => kb >= 1024 ? '${(kb / 1024).toStringAsFixed(1)} MB' : '$kb KB';
