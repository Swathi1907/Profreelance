import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models.dart';
import 'seed_provider.dart';

class ClientRepository extends Notifier<List<Client>> {
  int _seq = 100;

  @override
  List<Client> build() => ref.read(seedProvider).clients;

  Client? byId(String id) {
    for (final c in state) {
      if (c.id == id) return c;
    }
    return null;
  }

  Client? findByName(String name) {
    final n = name.trim().toLowerCase();
    for (final c in state) {
      if (c.name.toLowerCase() == n) return c;
    }
    return null;
  }

  /// Returns the existing client with this name, or creates one.
  Client ensure(String name, {String industry = ''}) {
    final found = findByName(name);
    if (found != null) return found;
    final c = Client(id: 'c${_seq++}', name: name.trim(), contact: '', industry: industry);
    state = [...state, c];
    return c;
  }

  void addReview(String clientId, ClientReview r) =>
      state = [for (final c in state) c.id == clientId ? c.withReview(r) : c];
}

final clientRepositoryProvider = NotifierProvider<ClientRepository, List<Client>>(ClientRepository.new);
