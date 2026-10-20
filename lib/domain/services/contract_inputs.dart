import '../../data/models/models.dart';
import 'client_scoring.dart';

const kContractTypes = ['Fixed price', 'Time and materials', 'Monthly retainer'];
const kEntityTypes = ['Individual / sole proprietor', 'Partnership / LLP', 'Private limited company', 'Public company', 'Government / PSU', 'Non-profit'];
const kDisputeModes = ['Mediation, then arbitration', 'Arbitration', 'Courts of the chosen city'];
const kHostingOptions = ['Client hosts; Freelancer deploys', 'Freelancer hosts during development only', 'Freelancer hosts for 3 months', 'Not applicable'];
const kThirdPartyCosts = ['Client pays directly', 'Freelancer pays and re-invoices at cost'];
const kSourceDelivery = ['Private repository transfer on final payment', 'Archive on final payment', 'Escrow until final payment'];
const kTaxModes = ['GST 18% extra', 'GST included in fee', 'No GST (below threshold)', 'Export of services (zero-rated)'];
const kPaymentMethods = ['Bank transfer / UPI', 'Bank transfer', 'International wire', 'Escrow platform'];
const kLiabilityCaps = ['Fees paid under this agreement', 'Twice the fees paid', 'Fees paid in the last 12 months'];
const kSubcontracting = ['Not allowed', 'Allowed with written notice', 'Allowed'];
const kClientDuties = [
  'Provide content, brand assets and copy on time',
  'Provide API keys and third-party credentials',
  'Name one point of contact',
  'Give feedback within 3 business days',
  'Provide test devices and environments',
];
const kEnvironments = ['Development', 'Staging', 'Production'];
const kSecurityOptions = ['OWASP Top 10 review', 'Encryption in transit', 'Encryption at rest', 'Role-based access control', 'Audit logging', 'Client-run penetration test'];
const kTestingOptions = ['Unit tests', 'Integration tests', 'User acceptance testing support', 'Load testing', 'Cross-device testing'];
const kDocOptions = ['README and setup guide', 'API documentation', 'User manual', 'Architecture diagram', 'Handover video'];

/// Every detail the contract wizard collects. Plain mutable fields: the
/// wizard ViewModel edits them and notifies the view.
class ContractInputs {
  ContractInputs({required this.project, required this.client, required this.milestones}) {
    clientLegalName = client?.name ?? '';
    effectiveDate = DateTime.now();
    city = project.jurisdiction;
    deliverables = project.deliverables;
    outOfScope = project.exclusions;
    techStack = project.techStack.join(', ');
    currency = project.currency;
    totalFee = project.budget;
    advancePct = project.advancePct;
    revisions = project.revisions;
    ipModel = project.ipOwnership;
    nda = project.nda;
    contractType = project.paymentStructure.startsWith('Hourly')
        ? 'Time and materials'
        : (project.paymentStructure == 'Monthly retainer' ? 'Monthly retainer' : 'Fixed price');
    clientDuties = {kClientDuties[0], kClientDuties[2], kClientDuties[3]};
    security = project.technicalComponents.contains('Authentication') ? {'OWASP Top 10 review', 'Encryption in transit'} : {};
  }

  final Project project;
  final Client? client;
  final List<Milestone> milestones;
  ClientScore? clientScore;

  // parties
  String freelancerName = 'Freelancer';
  String freelancerEntity = kEntityTypes[0];
  String freelancerAddress = '';
  String freelancerGstin = '';
  late String clientLegalName;
  String clientEntity = kEntityTypes[2];
  String clientAddress = '';
  String clientGstin = '';
  String clientSignatory = '';
  late DateTime effectiveDate;
  late String contractType;
  String governingLaw = 'India';
  late String city;
  String disputeMode = kDisputeModes[0];

  // scope and technical
  late String deliverables;
  String acceptanceCriteria = '';
  late String outOfScope;
  String assumptions = '';
  late Set<String> clientDuties;
  late String techStack;
  Set<String> environments = {'Development', 'Staging', 'Production'};
  String hosting = kHostingOptions[0];
  String thirdPartyCosts = kThirdPartyCosts[0];
  String platforms = '';
  String performanceTargets = '';
  late Set<String> security;
  Set<String> testing = {'Unit tests'};
  Set<String> documentation = {'README and setup guide'};
  String sourceDelivery = kSourceDelivery[0];

  // commercial
  late String currency;
  late double totalFee;
  late double advancePct;
  int invoiceDueDays = 7;
  double lateFeePct = 1.5;
  String taxMode = kTaxModes[0];
  bool tds = false;
  String expenses = 'Pre-approved expenses are reimbursed at cost';
  double killFeePct = 10;
  String paymentMethod = kPaymentMethods[0];
  int pauseAfterDays = 7;

  // legal
  late int revisions;
  String revisionDefinition = 'A revision is a change to work already delivered within the agreed scope. New features or new screens are change requests.';
  int changeSlaDays = 3;
  double changeRate = 1000;
  late String ipModel;
  bool portfolioRights = true;
  int confidentialityYears = 2;
  late bool nda;
  int warrantyDays = 30;
  String maintenance = 'No maintenance after the warranty period; available under a separate agreement';
  String liabilityCap = kLiabilityCaps[0];
  int noticeDays = 14;
  bool forceMajeure = true;
  int nonSolicitMonths = 0;
  String subcontracting = kSubcontracting[1];
  bool dpdp = true;

  /// Starting values for a project, softened or tightened by the client's score.
  factory ContractInputs.defaults(Project p, Client? c, List<Milestone> ms, {ClientScore? score, String freelancer = 'Freelancer', double rate = 1000}) {
    final i = ContractInputs(project: p, client: c, milestones: ms)
      ..freelancerName = freelancer
      ..changeRate = rate
      ..clientScore = score;
    if (score != null) {
      i.lateFeePct = score.suggestedLateFee;
      i.advancePct = score.suggestedAdvance.toDouble() > p.advancePct ? score.suggestedAdvance.toDouble() : p.advancePct;
    }
    return i;
  }
}
