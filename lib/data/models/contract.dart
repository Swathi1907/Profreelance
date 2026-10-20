import 'models.dart';
class ContractClause {
  const ContractClause({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.rationale = '',
    this.source = 'Template',
  });

  final String id;
  final String title;
  final String body;
  final String category;

  /// Why the assistant suggested this clause (shown to the freelancer).
  final String rationale;
  final String source;
}

class Contract {
  const Contract({
    required this.id,
    required this.projectId,
    required this.version,
    required this.status,
    required this.createdAt,
    required this.clauses,
    this.title = '',
    this.summary = '',
  });

  final String id;
  final String projectId;
  final int version;
  final ContractStatus status;
  final DateTime createdAt;
  final List<ContractClause> clauses;
  final String title;
  final String summary;

  Contract withStatus(ContractStatus s) => Contract(
        id: id,
        projectId: projectId,
        version: version,
        status: s,
        createdAt: createdAt,
        clauses: clauses,
        title: title,
        summary: summary,
      );
}
