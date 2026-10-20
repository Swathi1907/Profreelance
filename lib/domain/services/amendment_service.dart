import 'dart:math';

import '../../core/utils/format.dart';
import '../../data/models/models.dart';
import 'estimation.dart';

const kChangeTypes = [
  'New feature',
  'Modification of delivered work',
  'Removal of scope',
  'Third-party integration',
  'Performance or security requirement',
  'Design change',
  'Data migration',
];
const kRetestScopes = ['None', 'Regression on affected modules', 'Full regression'];
const kTimelineModes = ['Extend the deadline', 'Keep the deadline (parallel work)', 'Compress (rush)'];
const kPriorities = ['Normal', 'High', 'Urgent'];
const kMilestoneHandling = ['Add a new milestone', 'Merge into the next milestone'];

/// Everything the amendment wizard collects.
class AmendmentInputs {
  AmendmentInputs(this.project);
  final Project project;

  String title = '';
  String changeType = kChangeTypes[0];
  String description = '';
  Set<String> components = {};
  String newTech = '';
  int complexity = 3;
  bool thirdParty = false;
  bool dataMigration = false;
  bool securityImpact = false;
  double reworkPct = 0;
  String retest = kRetestScopes[1];
  bool newInfra = false;
  String requestedBy = '';
  String approvalRef = '';
  String priority = kPriorities[0];
  String timelineMode = kTimelineModes[0];
  bool manualPricing = false;
  String manualCost = '';
  String manualHours = '';
  String milestoneHandling = kMilestoneHandling[0];
  String acceptance = '';
  DateTime effectiveDate = DateTime.now();
}

class AmendmentLine {
  const AmendmentLine(this.label, this.hours, this.note);
  final String label;
  final double hours;
  final String note;
}

class AmendmentEstimate {
  const AmendmentEstimate({
    required this.lines,
    required this.totalHours,
    required this.rate,
    required this.multiplier,
    required this.cost,
    required this.extraDays,
    required this.newBudget,
    required this.newDue,
    required this.confidence,
    required this.neighbors,
    required this.fallback,
  });

  final List<AmendmentLine> lines;
  final double totalHours;
  final double rate;
  final double multiplier;
  final double cost;
  final int extraDays;
  final double newBudget;
  final DateTime newDue;
  final double confidence;
  final List<Neighbor> neighbors;
  final bool fallback;
}

/// Prices a change request.
///
/// Step 1: find similar finished projects (same domain and technologies) with
/// the kNN estimator. Step 2: take the share of a whole project that this
/// change represents (from complexity and affected components). Step 3: add
/// explicit adjustments (integration, migration, security, rework, re-testing,
/// infrastructure). Every adjustment is shown to the user, so the figure can
/// be defended to the client.
class AmendmentEstimator {
  AmendmentEstimator._();

  static double _parse(String s) => double.tryParse(s.replaceAll(',', '').trim()) ?? 0;

  static AmendmentEstimate estimate({required AmendmentInputs a, required List<Project> history, required double fallbackRate}) {
    final p = a.project;
    final tech = [
      ...p.techStack,
      ...a.newTech.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty),
    ];
    final base = EstimationService.estimate(
      domain: p.domain,
      subDomain: p.subDomain,
      tech: tech,
      description: '${a.title} ${a.description} ${a.components.join(' ')}',
      complexity: p.complexity,
      history: history.where((h) => h.id != p.id).toList(),
      fallbackRate: fallbackRate,
    );

    final shareBase = a.complexity <= 2 ? 0.05 : (a.complexity <= 3 ? 0.10 : 0.20);
    final share = shareBase + min(0.10, 0.02 * a.components.length);
    final feature = base.hours * share;

    final lines = <AmendmentLine>[
      AmendmentLine('Core change work', feature, '${(share * 100).round()}% of a similar full project (${base.hours.round()}h)'),
    ];
    if (a.thirdParty) lines.add(AmendmentLine('Third-party integration', feature * 0.12, 'Credentials, sandbox testing, error handling'));
    if (a.dataMigration) lines.add(AmendmentLine('Data migration', feature * 0.10, 'Mapping, scripts and verification'));
    if (a.securityImpact) lines.add(AmendmentLine('Security review', feature * 0.08, 'Threat check on the changed surface'));
    if (a.reworkPct > 0) {
      lines.add(AmendmentLine('Rework of delivered work', a.reworkPct / 100 * p.actualHours * 0.25, '${a.reworkPct.round()}% of delivered work is touched'));
    }
    final subtotal = lines.fold<double>(0, (s, l) => s + l.hours);
    final retestPct = a.retest == kRetestScopes[2] ? 0.25 : (a.retest == kRetestScopes[1] ? 0.12 : 0.0);
    if (retestPct > 0) lines.add(AmendmentLine('Re-testing', subtotal * retestPct, a.retest));
    if (a.newInfra) lines.add(const AmendmentLine('New infrastructure', 6, 'Environment, CI and deployment changes'));

    var hours = lines.fold<double>(0, (s, l) => s + l.hours);
    final rate = base.usedFallback ? (p.effectiveRate > 0 ? p.effectiveRate : fallbackRate) : base.ratePerHour;
    var mult = 1.0;
    if (a.priority == 'Urgent') mult *= 1.2;
    if (a.priority == 'High') mult *= 1.1;
    if (a.timelineMode == kTimelineModes[2]) mult *= 1.15;

    var cost = hours * rate * mult;
    if (a.manualPricing) {
      final mh = _parse(a.manualHours);
      final mc = _parse(a.manualCost);
      if (mh > 0) hours = mh;
      if (mc > 0) cost = mc;
    }
    cost = (cost / 500).round() * 500.0;

    final baseDays = max(1, (hours / 5.5 * 1.25).ceil());
    final extra = a.timelineMode == kTimelineModes[0] ? baseDays : (a.timelineMode == kTimelineModes[1] ? (baseDays * 0.4).ceil() : (baseDays * 0.6).ceil());
    final conf = (base.confidence * (a.description.trim().length > 40 ? 1.0 : 0.85)).clamp(0.25, 0.95).toDouble();

    return AmendmentEstimate(
      lines: lines,
      totalHours: hours.roundToDouble(),
      rate: rate,
      multiplier: mult,
      cost: cost,
      extraDays: extra,
      newBudget: p.budget + cost,
      newDue: p.dueDate.add(Duration(days: extra)),
      confidence: conf,
      neighbors: base.neighbors,
      fallback: base.usedFallback,
    );
  }

  static List<ContractClause> document(AmendmentInputs a, AmendmentEstimate e, int number) {
    final p = a.project;
    var n = 0;
    ContractClause c(String title, String body, String why) =>
        ContractClause(id: 'a${++n}', title: title, body: body, category: 'Amendment', rationale: why, source: 'Amendment wizard');
    final tech = [
      if (a.components.isNotEmpty) 'Affected components: ${a.components.join(', ')}.',
      if (a.newTech.trim().isNotEmpty) 'Additional technologies: ${a.newTech.trim()}.',
      if (a.thirdParty) 'Includes a third-party integration.',
      if (a.dataMigration) 'Includes data migration.',
      if (a.securityImpact) 'Has security impact and receives a security review.',
    ].join(' ');
    return [
      c(
        'Background',
        'Amendment No. $number to the agreement for "${p.name}". The Client requested this change${a.requestedBy.isEmpty ? '' : ' through ${a.requestedBy}'}${a.approvalRef.isEmpty ? '' : ' (reference: ${a.approvalRef})'}. Effective date: ${fmtDate(a.effectiveDate)}. Priority: ${a.priority}.',
        'Ties the change to a documented client request.',
      ),
      c(
        'Description of the Change',
        '${a.title}. Type: ${a.changeType}. ${a.description.trim()} ${tech.isEmpty ? '' : tech}',
        'A precise technical description avoids later disputes about what was agreed.',
      ),
      c(
        'Revised Deliverables and Acceptance Criteria',
        'The following is added to the deliverables: ${a.title}. Acceptance criteria for the change: ${a.acceptance.trim().isEmpty ? 'works as described above and passes the agreed tests' : a.acceptance.trim()}. Re-testing scope: ${a.retest.toLowerCase()}.',
        'New work needs its own acceptance test.',
      ),
      c(
        'Revised Fees',
        'Previous total fee: ${inr(p.budget)}. Additional fee for this change: ${inr(e.cost)} (${e.totalHours.round()} hours). Revised total fee: ${inr(e.newBudget)}. The additional fee follows the change order process of the main agreement.',
        'Shows the old, added and new fee side by side.',
      ),
      c(
        'Revised Schedule',
        'Previous completion date: ${fmtDate(p.dueDate)}. Revised completion date: ${fmtDate(e.newDue)} (${e.extraDays} additional days, ${a.timelineMode.toLowerCase()}).',
        'Keeps the delivery date consistent with the extra effort.',
      ),
      c(
        'Payment of the Additional Fee',
        '${a.milestoneHandling}. The additional fee is invoiced as a milestone linked to this amendment and is payable within 7 days of invoice. Late payment interest follows the main agreement.',
        'Connects the extra money to a payment milestone.',
      ),
      c(
        'Effect on Existing Work',
        a.reworkPct > 0
            ? 'About ${a.reworkPct.round()}% of already delivered work is modified. The Freelancer will re-test affected areas and the Client will re-accept them.'
            : 'The change does not require modifying delivered work.',
        'Rework is a hidden cost; stating it keeps the price fair.',
      ),
      c(
        'Other Terms',
        'All other terms of the agreement remain in force. If this amendment conflicts with the agreement, this amendment prevails for the change described above only.',
        'Standard closing clause for an amendment.',
      ),
    ];
  }
}
