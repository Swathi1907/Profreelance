enum ProjectStatus { notStarted, inProgress, completed }

enum MilestoneStatus { pending, paid, overdue }

enum ContractStatus { draft, sent, signed, amendmentPending }

enum Severity { low, medium, high }

enum AlertType { deadline, payment, contract, scope, estimation }

enum DocCategory { requirements, proposals, invoices, clientBriefs, designFiles, references, deliverables }

extension DocCategoryX on DocCategory {
  String get label => switch (this) {
        DocCategory.requirements => 'Requirements',
        DocCategory.proposals => 'Proposals',
        DocCategory.invoices => 'Invoices',
        DocCategory.clientBriefs => 'Client briefs',
        DocCategory.designFiles => 'Design files',
        DocCategory.references => 'References',
        DocCategory.deliverables => 'Deliverables',
      };
}

extension ProjectStatusX on ProjectStatus {
  String get label => switch (this) {
        ProjectStatus.notStarted => 'NOT STARTED',
        ProjectStatus.inProgress => 'IN PROGRESS',
        ProjectStatus.completed => 'COMPLETED',
      };
}

extension ContractStatusX on ContractStatus {
  String get label => switch (this) {
        ContractStatus.draft => 'Draft',
        ContractStatus.sent => 'Sent',
        ContractStatus.signed => 'Signed',
        ContractStatus.amendmentPending => 'Amendment pending',
      };
}
