import 'package:intl/intl.dart';

import '../../core/utils/format.dart';
import '../../data/models/models.dart';
import 'contract_inputs.dart';

export 'contract_inputs.dart';

/// Builds a full clause set from structured inputs. Every clause carries a
/// rationale (why it is there) and a source (template, your settings, or the
/// client risk model), so the freelancer can defend each term.
class ContractBuilder {
  ContractBuilder._();

  static String _list(Iterable<String> items, {String none = 'None specified'}) => items.isEmpty ? none : items.join('; ');

  static List<ContractClause> build(ContractInputs i) {
    final p = i.project;
    final cur = i.currency == 'INR' ? '₹' : '${i.currency} ';
    String money(num v) => i.currency == 'INR' ? inr(v) : '$cur${NumberFormat('#,##0').format(v)}';
    var n = 0;
    ContractClause c(String title, String cat, String body, String why, [String source = 'Template']) =>
        ContractClause(id: 'g${++n}', title: title, category: cat, body: body, rationale: why, source: source);

    final ms = i.milestones.isEmpty
        ? 'Payment milestones are listed in Schedule A.'
        : i.milestones.asMap().entries.map((e) => 'M${e.key + 1}: ${e.value.title}, ${money(e.value.amount)}, due ${fmtDate(e.value.due)}').join('\n');
    final risky = i.clientScore?.isRisky ?? false;
    final score = i.clientScore;

    return [
      c(
        'Parties and Effective Date',
        'General',
        'This agreement is made on ${fmtDate(i.effectiveDate)} between ${i.freelancerName} (${i.freelancerEntity}${i.freelancerAddress.isEmpty ? '' : ', ${i.freelancerAddress}'}${i.freelancerGstin.isEmpty ? '' : ', GSTIN ${i.freelancerGstin}'}) ("Freelancer") and ${i.clientLegalName} (${i.clientEntity}${i.clientAddress.isEmpty ? '' : ', ${i.clientAddress}'}${i.clientGstin.isEmpty ? '' : ', GSTIN ${i.clientGstin}'}), represented by ${i.clientSignatory.isEmpty ? 'its authorised signatory' : i.clientSignatory} ("Client"). Contract type: ${i.contractType}.',
        'Full legal names and entity types make the agreement enforceable and the invoices valid.',
        'Your inputs',
      ),
      c(
        'Scope of Work and Deliverables',
        'Scope',
        'The Freelancer will deliver "${p.name}" (${p.domain}${p.subDomain.isEmpty ? '' : ', ${p.subDomain}'}).\nDeliverables:\n${i.deliverables.isEmpty ? 'As described in the project brief.' : i.deliverables}\nOut of scope: ${i.outOfScope.isEmpty ? 'anything not listed above' : i.outOfScope}.\nAssumptions: ${i.assumptions.isEmpty ? 'none beyond this agreement' : i.assumptions}.',
        'An explicit list of inclusions and exclusions is the strongest protection against scope creep.',
        'Your inputs',
      ),
      c(
        'Acceptance Criteria',
        'Scope',
        'Each deliverable is accepted when it meets these acceptance criteria: ${i.acceptanceCriteria.isEmpty ? 'it works as described in the deliverables list' : i.acceptanceCriteria}. The Client has 7 business days to review each deliverable and report defects in writing. If no defect is reported within 7 days, the deliverable is deemed accepted.',
        'Measurable criteria and a review window stop approvals from delaying payment.',
        'Your inputs',
      ),
      c(
        'Client Responsibilities',
        'Scope',
        'The Client will: ${_list(i.clientDuties)}. Delays caused by missing inputs extend the schedule by the same number of days.',
        'Protects your deadline from dependencies you do not control.',
      ),
      c(
        'Technical Specifications',
        'Technical',
        'Technology stack: ${i.techStack.isEmpty ? 'at the Freelancer\'s discretion' : i.techStack}.\nEnvironments: ${_list(i.environments)}.\nSupported platforms: ${i.platforms.isEmpty ? 'as agreed in writing' : i.platforms}.\nPerformance targets: ${i.performanceTargets.isEmpty ? 'none specified' : i.performanceTargets}.\nSecurity requirements: ${_list(i.security)}.\nTesting scope: ${_list(i.testing)}.\nDocumentation: ${_list(i.documentation)}.\nHosting: ${i.hosting}. Third-party service costs: ${i.thirdPartyCosts}.',
        'Technical commitments written down remove ambiguity about what "done" means.',
        'Your inputs',
      ),
      c(
        'Schedule and Milestones',
        'Timeline',
        'Work starts on ${fmtDate(p.startDate)} and the target completion date is ${fmtDate(p.dueDate)}.\nMilestones:\n$ms',
        'A dated milestone schedule links delivery to payment.',
      ),
      c(
        'Fees, Taxes and Payment',
        'Payment',
        'Total fee: ${money(i.totalFee)} (${i.taxMode}). An advance of ${i.advancePct.toStringAsFixed(0)}% is payable before work starts. Each invoice is payable within ${i.invoiceDueDays} days. Payment method: ${i.paymentMethod}. ${i.tds ? 'The Client may deduct TDS as required by law and will provide the certificate. ' : ''}${i.expenses}.',
        score == null ? 'Standard payment terms.' : 'Advance set to ${i.advancePct.toStringAsFixed(0)}% because the client scores ${score.overall.round()} (${score.tier}).',
        score == null ? 'Template' : 'Client risk model',
      ),
      c(
        'Late Payment and Suspension',
        'Payment',
        'Late payment attracts interest of ${i.lateFeePct.toStringAsFixed(1)}% per month. If an invoice is overdue by more than ${i.pauseAfterDays} days, the Freelancer may pause work until it is paid, and the schedule extends accordingly.',
        score == null ? 'Standard late-fee clause.' : 'Late fee of ${i.lateFeePct.toStringAsFixed(1)}% follows from this client\'s payment history.',
        score == null ? 'Template' : 'Client risk model',
      ),
      c(
        'Revisions',
        'Scope',
        'Revision limit: revisions are capped at ${i.revisions} rounds per deliverable. ${i.revisionDefinition} Additional revisions are billed at ${money(i.changeRate)} per hour.',
        'Capping revisions keeps effort aligned with the quote.',
        'Your inputs',
      ),
      c(
        'Change Requests',
        'Scope',
        'Work outside the agreed scope needs a written change order. The Freelancer will provide an estimate of cost and time within ${i.changeSlaDays} business days, and starts the work after written approval. Approved change orders are recorded as numbered amendments to this agreement.',
        risky ? 'Stricter, because this client has a history of changing requirements.' : 'Connects directly to the amendment workflow in this app.',
        risky ? 'Client risk model' : 'Template',
      ),
      c(
        'Intellectual Property',
        'IP',
        'Intellectual property in the final deliverables: ${i.ipModel}. Until full payment, the Client holds only a limited licence to review the work. The Freelancer keeps ownership of pre-existing tools, libraries and know-how.',
        'Tying ownership to payment protects you if an invoice goes unpaid.',
        'Your inputs',
      ),
      c(
        'Source Code and Handover',
        'IP',
        'Delivery of source and assets: ${i.sourceDelivery}. ${i.warrantyDays > 0 ? 'Handover includes the documentation listed in the technical specifications.' : ''}',
        'Defines exactly when the client receives the code.',
      ),
      c(
        'Confidentiality',
        'Confidentiality',
        'Each party keeps the other\'s non-public information confidential during the project and for ${i.confidentialityYears} years afterwards.${i.nda ? ' The parties will also sign a separate non-disclosure agreement before work starts.' : ''}',
        i.nda ? 'You marked an NDA as required for this project.' : 'Mutual confidentiality is the market norm.',
        i.nda ? 'Your inputs' : 'Template',
      ),
      c(
        'Warranty and Support',
        'Liability',
        'The Freelancer will fix defects reported within ${i.warrantyDays} days of final delivery at no charge. After that: ${i.maintenance}.',
        'A bounded warranty keeps support from becoming free and endless.',
        'Your inputs',
      ),
      c(
        'Limitation of Liability',
        'Liability',
        'Limitation of liability: each party\'s total liability is limited to ${i.liabilityCap.toLowerCase()}. Neither party is liable for indirect or consequential losses. Each party is responsible for third-party claims arising from content it supplied.',
        'A liability cap keeps your risk proportional to your fee.',
        'Your inputs',
      ),
      c(
        'Termination',
        'Termination',
        'Either party may end this agreement with ${i.noticeDays} days\' written notice. The Client pays for all work completed up to the termination date, plus a kill fee of ${i.killFeePct.toStringAsFixed(0)}% of the remaining fee if the Client ends the agreement after work has started.',
        'A kill fee compensates for the time you reserved for this project.',
        'Your inputs',
      ),
      if (i.dpdp)
        c(
          'Data Protection',
          'Compliance',
          'Where the Freelancer processes personal data on the Client\'s behalf, it will do so only on the Client\'s instructions and in line with the Digital Personal Data Protection Act, 2023, and will return or delete the data at the end of the project.',
          'Required whenever the project touches personal data.',
          'Your inputs',
        ),
      if (i.forceMajeure)
        c(
          'Force Majeure',
          'General',
          'Neither party is in breach for delays caused by events beyond its reasonable control, provided it gives prompt notice and resumes work as soon as possible.',
          'Standard protection for both sides.',
        ),
      if (i.nonSolicitMonths > 0)
        c(
          'Non-solicitation',
          'Restrictions',
          'For ${i.nonSolicitMonths} months after this agreement ends, neither party will directly hire the other\'s staff involved in the project.',
          'Added because you asked for it. Mutual by design, so it does not restrict your freedom to work.',
          'Your inputs',
        ),
      c(
        'Subcontracting',
        'General',
        'Subcontracting by the Freelancer: ${i.subcontracting.toLowerCase()}. The Freelancer stays responsible for any subcontracted work.',
        'Makes it clear who may touch the work.',
        'Your inputs',
      ),
      if (i.portfolioRights)
        c(
          'Portfolio Rights',
          'IP',
          'The Freelancer may show non-confidential parts of the work in a portfolio and case studies, without revealing the Client\'s confidential information.',
          'Lets you use the project to win future clients.',
        ),
      c(
        'Governing Law and Disputes',
        'Disputes',
        'This agreement is governed by the laws of ${i.governingLaw}. Disputes are handled through: ${i.disputeMode.toLowerCase()}, seated in ${i.city}.',
        'Staged dispute resolution is faster and cheaper than court.',
        'Your inputs',
      ),
      c(
        'General',
        'General',
        'This agreement is the entire understanding between the parties. Changes must be in writing and signed by both parties. Notices may be sent by email to the addresses on record.',
        'Standard boilerplate.',
      ),
    ];
  }

  static String render(ContractInputs i, List<ContractClause> clauses, {int version = 1}) {
    final b = StringBuffer()
      ..writeln('FREELANCE SERVICES AGREEMENT (v$version)')
      ..writeln('Project: ${i.project.name}')
      ..writeln();
    for (var k = 0; k < clauses.length; k++) {
      b
        ..writeln('${k + 1}. ${clauses[k].title}')
        ..writeln(clauses[k].body)
        ..writeln();
    }
    b
      ..writeln('Signed:')
      ..writeln('______________________   ______________________')
      ..writeln('${i.freelancerName}                 ${i.clientLegalName}');
    return b.toString();
  }

  static String renderContract(Contract c, {String? projectName}) {
    final b = StringBuffer()..writeln('${c.title.isEmpty ? 'AGREEMENT' : c.title.toUpperCase()} (v${c.version})')..writeln();
    for (var k = 0; k < c.clauses.length; k++) {
      b
        ..writeln('${k + 1}. ${c.clauses[k].title}')
        ..writeln(c.clauses[k].body)
        ..writeln();
    }
    return b.toString();
  }
}
