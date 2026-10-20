import 'enums.dart';

class Project {
  const Project({
    required this.id,
    required this.name,
    required this.clientId,
    required this.domain,
    required this.subDomain,
    required this.description,
    required this.techStack,
    required this.status,
    required this.startDate,
    required this.dueDate,
    required this.budget,
    required this.estimatedHours,
    this.endDate,
    this.actualHours = 0,
    this.advancePct = 20,
    this.revisions = 2,
    this.ipOwnership = 'Client, on full payment',
    this.paymentStructure = 'Milestone-based',
    this.complexity = 3,
    this.changeRequests = 0,
    this.deliverables = '',
    this.exclusions = '',
    this.objective = '',
    this.durationValue = 0,
    this.durationUnit = 'Weeks',
    this.currency = 'INR',
    this.technicalComponents = const [],
    this.externalDeps = const [],
    this.nda = false,
    this.jurisdiction = 'Bengaluru',
    this.isDraft = false,
  });

  final String id;
  final String name;
  final String clientId;
  final String domain;
  final String subDomain;
  final String description;
  final List<String> techStack;
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime dueDate;
  final DateTime? endDate;
  final double budget;
  final double estimatedHours;
  final double actualHours;
  final double advancePct;
  final int revisions;
  final String ipOwnership;
  final String paymentStructure;
  final int complexity;
  final int changeRequests;
  final String deliverables;
  final String exclusions;
  final String objective;
  final int durationValue;
  final String durationUnit;
  final String currency;
  final List<String> technicalComponents;
  final List<String> externalDeps;
  final bool nda;
  final String jurisdiction;
  final bool isDraft;

  bool get isCompleted => status == ProjectStatus.completed;
  double get effectiveRate => estimatedHours <= 0 ? 0 : budget / estimatedHours;

  Project copyWith({
    ProjectStatus? status,
    DateTime? dueDate,
    DateTime? endDate,
    double? budget,
    double? estimatedHours,
    double? actualHours,
    int? changeRequests,
    bool? isDraft,
  }) =>
      Project(
        id: id,
        name: name,
        clientId: clientId,
        domain: domain,
        subDomain: subDomain,
        description: description,
        techStack: techStack,
        status: status ?? this.status,
        startDate: startDate,
        dueDate: dueDate ?? this.dueDate,
        endDate: endDate ?? this.endDate,
        budget: budget ?? this.budget,
        estimatedHours: estimatedHours ?? this.estimatedHours,
        actualHours: actualHours ?? this.actualHours,
        advancePct: advancePct,
        revisions: revisions,
        ipOwnership: ipOwnership,
        paymentStructure: paymentStructure,
        complexity: complexity,
        changeRequests: changeRequests ?? this.changeRequests,
        deliverables: deliverables,
        exclusions: exclusions,
        objective: objective,
        durationValue: durationValue,
        durationUnit: durationUnit,
        currency: currency,
        technicalComponents: technicalComponents,
        externalDeps: externalDeps,
        nda: nda,
        jurisdiction: jurisdiction,
        isDraft: isDraft ?? this.isDraft,
      );
}
