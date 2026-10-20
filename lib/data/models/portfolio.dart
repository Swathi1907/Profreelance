import 'client.dart';
import 'contract.dart';
import 'milestone.dart';
import 'project.dart';
import 'vault_doc.dart';

/// Read-only snapshot of everything the freelancer owns. Built from the
/// repositories and handed to the domain services (alerts, analytics).
class Portfolio {
  const Portfolio({
    required this.projects,
    required this.milestones,
    required this.clients,
    required this.contracts,
    required this.docs,
  });

  final List<Project> projects;
  final List<Milestone> milestones;
  final List<Client> clients;
  final List<Contract> contracts;
  final List<VaultDoc> docs;

  Project? project(String id) {
    for (final p in projects) {
      if (p.id == id) return p;
    }
    return null;
  }

  Client? client(String id) {
    for (final c in clients) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<Milestone> milestonesOf(String projectId) =>
      milestones.where((m) => m.projectId == projectId).toList()..sort((a, b) => a.due.compareTo(b.due));
}
