import '../../data/models/models.dart';

class ExtractedClause {
  const ExtractedClause({required this.number, required this.title, required this.text, required this.category, required this.plain});
  final String number;
  final String title;
  final String text;
  final String category;
  final String plain;
}

class RiskFlag {
  const RiskFlag({
    required this.severity,
    required this.title,
    required this.clauseTitle,
    required this.quote,
    required this.plain,
    required this.fix,
  });
  final Severity severity;
  final String title;
  final String clauseTitle;
  final String quote;
  final String plain;
  final String fix;
}

class MissingTerm {
  const MissingTerm({required this.title, required this.why, required this.wording, required this.important});
  final String title;
  final String why;
  final String wording;
  final bool important;
}

class AnalysisResult {
  const AnalysisResult({
    required this.risk,
    required this.level,
    required this.flags,
    required this.missing,
    required this.clauses,
    required this.words,
  });
  final int risk; // 0 (safe) .. 100 (dangerous)
  final String level;
  final List<RiskFlag> flags;
  final List<MissingTerm> missing;
  final List<ExtractedClause> clauses;
  final int words;
}

class _Rule {
  _Rule(this.pattern, this.severity, this.title, this.plain, this.fix);
  final RegExp pattern;
  final Severity severity;
  final String title;
  final String plain;
  final String fix;
}

class _Required {
  _Required(this.pattern, this.title, this.why, this.wording, {this.important = true});
  final RegExp pattern;
  final String title;
  final String why;
  final String wording;
  final bool important;
}

/// Clause extraction + risk detection.
///
/// Baseline method: segment the text into clauses, classify each clause with a
/// keyword model, match a lexicon of known risky patterns (weighted by
/// severity), and check a list of terms every freelance contract should have.
/// The scoring stays explainable: every flag points at the exact text.
///
/// Upgrade path: replace [analyze] with a fine-tuned legal-domain transformer
/// (clause classification + risk tagging) served from FastAPI, and keep the
/// same result classes so the UI does not change.
class ContractAnalyzer {
  ContractAnalyzer._();

  static final _rules = <_Rule>[
    _Rule(
      RegExp(r'unlimited\s+revisions?|revisions?\s+until\s+(the\s+)?client\s+is\s+(fully\s+)?satisfied', caseSensitive: false),
      Severity.high,
      'Unlimited revisions',
      'The client can ask for changes forever without paying more. This is the classic way projects overrun.',
      'Cap revisions (for example 2 rounds) and bill extra rounds hourly.',
    ),
    _Rule(
      RegExp(r'work\s+made\s+for\s+hire|all\s+(intellectual\s+property|rights).{0,80}(upon\s+creation|immediately|vest)', caseSensitive: false),
      Severity.high,
      'IP transfers before payment',
      'The client owns everything the moment you create it, even if they never pay you.',
      'Transfer ownership only after the final invoice is paid in full.',
    ),
    _Rule(
      RegExp(r'net\s*(60|75|90|120)|within\s+(60|75|90|120)\s+days', caseSensitive: false),
      Severity.high,
      'Very long payment terms',
      'You could wait two to four months to be paid after delivering.',
      'Ask for payment within 7 to 15 days, or move to milestone invoices.',
    ),
    _Rule(
      RegExp(r'sole\s+discretion', caseSensitive: false),
      Severity.medium,
      'One-sided discretion',
      'One party decides alone. If this covers acceptance or payment, the client can withhold money with no objective test.',
      'Replace with written acceptance criteria and a deemed-acceptance period.',
    ),
    _Rule(
      RegExp(r'terminate.{0,60}(at\s+any\s+time|without\s+cause).{0,100}(no|without)\s+(further\s+)?(payment|compensation)', caseSensitive: false),
      Severity.high,
      'Termination without pay',
      'The client can cancel at any time and owe you nothing for work already done.',
      'Require payment for all work completed plus a kill fee.',
    ),
    _Rule(
      RegExp(r'unlimited\s+liability|liab\w*\s+(shall\s+)?not\s+be\s+(limited|capped)', caseSensitive: false),
      Severity.high,
      'Uncapped liability',
      'You could be responsible for losses far bigger than your fee.',
      'Cap liability at the fees paid under the contract.',
    ),
    _Rule(
      RegExp(r'indemnif', caseSensitive: false),
      Severity.medium,
      'Broad indemnity',
      'You promise to cover the client\'s legal costs and losses in certain situations. If it is wide, that is open-ended exposure.',
      'Limit indemnity to third-party IP claims caused by your own work, within the liability cap.',
    ),
    _Rule(
      RegExp(r'non[-\s]?compete|shall\s+not\s+(work|provide|perform).{0,60}(competitor|similar)', caseSensitive: false),
      Severity.high,
      'Non-compete restriction',
      'You may be blocked from working with other clients in the same field, which hurts a freelancer\'s income.',
      'Delete it, or limit it to direct competitors, 3 months and the project\'s own confidential information.',
    ),
    _Rule(
      RegExp(r'exclusive(ly)?\s+(for|to|with)|exclusivity', caseSensitive: false),
      Severity.medium,
      'Exclusivity',
      'You may only work for this client during the engagement.',
      'Remove exclusivity, or price it with an exclusivity premium.',
    ),
    _Rule(
      RegExp(r'liquidated\s+damages|penalt(y|ies)', caseSensitive: false),
      Severity.medium,
      'Delay penalties',
      'Fixed deductions apply if you are late, but nothing protects you when the client is late.',
      'Make penalties mutual and cap them (for example 5% of the fee).',
    ),
    _Rule(
      RegExp(r'(additional|extra)\s+(work|features?|changes?).{0,60}(no\s+(additional|extra)|without\s+(additional|extra))\s+(cost|charge|fee)|at\s+no\s+(additional|extra)\s+cost', caseSensitive: false),
      Severity.high,
      'Free extra work',
      'New requests are included in the price. The scope has no edge.',
      'Require a written change order with its own price and timeline.',
    ),
    _Rule(
      RegExp(r'(lifetime|perpetual|indefinite)\s+(support|warranty|maintenance)|free\s+(support|maintenance|bug\s*fix\w*).{0,40}(year|lifetime|indefinite)', caseSensitive: false),
      Severity.high,
      'Endless free support',
      'You promise free fixes and support for years or forever.',
      'Limit the warranty to 30 to 60 days and sell a maintenance plan after that.',
    ),
    _Rule(
      RegExp(r'payment\s+(is\s+)?(due\s+)?(only\s+)?(upon|after)\s+(final\s+)?(acceptance|approval|go-?live)', caseSensitive: false),
      Severity.medium,
      'Payment depends on final approval',
      'You are paid only when the client approves the whole project, which can be delayed indefinitely.',
      'Add milestone payments and a deemed-acceptance period.',
    ),
  ];

  static final _required = <_Required>[
    _Required(
      RegExp(r'milestone|instal?lment|invoice', caseSensitive: false),
      'Payment schedule',
      'Without milestones you carry all the risk until the end.',
      'Fees are invoiced in milestones as listed in Schedule A; each invoice is payable within 7 days.',
    ),
    _Required(
      RegExp(r'late\s+(fee|payment|interest)|interest\s+on\s+(overdue|late)', caseSensitive: false),
      'Late payment fee',
      'No penalty means no incentive to pay on time.',
      'Overdue amounts attract interest of 1.5% per month.',
    ),
    _Required(
      RegExp(r'kill\s+fee|termination.{0,80}(work\s+(completed|performed)|payment\s+for)', caseSensitive: false),
      'Payment on termination',
      'If the client cancels, you could lose the money for work already done.',
      'On termination the Client pays for all work completed plus a kill fee of 10% of the remaining fee.',
    ),
    _Required(
      RegExp(r'revisions?.{0,40}(\d+|one|two|three|four|limited|up\s+to)', caseSensitive: false),
      'Revision limit',
      'No stated limit invites open-ended rework.',
      'Two rounds of revisions are included; additional rounds are billed hourly.',
    ),
    _Required(
      RegExp(r'change\s+(request|order)', caseSensitive: false),
      'Change request process',
      'You need a formal way to price new requirements.',
      'Work outside scope requires a written change order approved before it starts.',
    ),
    _Required(
      RegExp(r'intellectual\s+property|copyright|ownership', caseSensitive: false),
      'IP ownership',
      'Ownership should be explicit, and tied to payment.',
      'Ownership of the deliverables transfers to the Client on full payment.',
    ),
    _Required(
      RegExp(r'accept(ance)?\b.{0,60}(days|criteria)', caseSensitive: false),
      'Acceptance criteria and time limit',
      'Without a review deadline, approvals can stall your final payment.',
      'The Client has 7 business days to review each deliverable; silence is acceptance.',
    ),
    _Required(
      RegExp(r'limit(ation)?\s+of\s+liability|liability.{0,60}(capped|shall\s+not\s+exceed|limited\s+to)', caseSensitive: false),
      'Liability cap',
      'Your exposure should be proportional to your fee.',
      'Total liability is limited to the fees paid under this agreement.',
    ),
    _Required(
      RegExp(r'confidential|non-?disclosure', caseSensitive: false),
      'Confidentiality',
      'Standard protection for both sides.',
      'Each party keeps the other\'s non-public information confidential.',
      important: false,
    ),
    _Required(
      RegExp(r'arbitrat|governing\s+law|jurisdiction', caseSensitive: false),
      'Governing law and disputes',
      'Decides where and how a dispute is handled.',
      'Governed by the laws of India; disputes go to arbitration.',
      important: false,
    ),
    _Required(
      RegExp(r'portfolio', caseSensitive: false),
      'Portfolio rights',
      'Lets you show the finished work to win new clients.',
      'The Freelancer may show non-confidential work in a portfolio.',
      important: false,
    ),
  ];

  static const _categories = <String, List<String>>{
    'Payment': ['pay', 'fee', 'invoice', 'compensation', 'net '],
    'IP': ['intellectual', 'copyright', 'ownership', 'licen', 'work made for hire'],
    'Termination': ['terminat', 'cancel'],
    'Liability': ['liab', 'indemn', 'damages', 'warrant'],
    'Scope': ['revision', 'scope', 'change request', 'additional work', 'deliverable', 'feature'],
    'Confidentiality': ['confidential', 'non-disclosure'],
    'Restrictions': ['compete', 'exclusiv', 'solicit'],
    'Disputes': ['arbitrat', 'jurisdiction', 'governing law', 'dispute', 'court'],
    'Timeline': ['deadline', 'schedule', 'timeline', 'delay', 'deliver by'],
  };

  static const _plainByCategory = {
    'Payment': 'Explains how and when you get paid.',
    'IP': 'Says who owns the work you create, and when ownership changes hands.',
    'Termination': 'Describes how either side can end the contract and what is owed.',
    'Liability': 'Describes who pays if something goes wrong, and up to how much.',
    'Scope': 'Defines what you must deliver and how changes are handled.',
    'Confidentiality': 'Obliges both sides to keep project information private.',
    'Restrictions': 'Limits who else you can work for or what you can do.',
    'Disputes': 'Says which law applies and how disagreements are settled.',
    'Timeline': 'Sets deadlines and what happens if they slip.',
    'General': 'General or administrative terms.',
  };

  static String _classify(String t) {
    final l = t.toLowerCase();
    var best = 'General';
    var bestScore = 0;
    _categories.forEach((cat, words) {
      final s = words.where(l.contains).length;
      if (s > bestScore) {
        bestScore = s;
        best = cat;
      }
    });
    return best;
  }

  static List<ExtractedClause> extract(String text) {
    final head = RegExp(r'^\s*(\d+(?:\.\d+)*)[.)]?\s+(.+)$');
    final lines = text.split('\n');
    final hasNumbers = lines.any((l) => head.hasMatch(l));
    final parts = <MapEntry<String, String>>[]; // number -> text
    if (hasNumbers) {
      String? num;
      final buf = StringBuffer();
      void flush() {
        if (num != null && buf.toString().trim().isNotEmpty) parts.add(MapEntry(num, buf.toString().trim()));
        buf.clear();
      }

      for (final raw in lines) {
        final m = head.firstMatch(raw);
        if (m != null) {
          flush();
          num = m.group(1);
          buf.writeln(m.group(2));
        } else if (num != null) {
          buf.writeln(raw);
        }
      }
      flush();
    } else {
      final paras = text.split(RegExp(r'\n\s*\n')).map((e) => e.trim()).where((e) => e.length > 20).toList();
      for (var i = 0; i < paras.length; i++) {
        parts.add(MapEntry('${i + 1}', paras[i]));
      }
    }
    return [
      for (final e in parts)
        () {
          final cat = _classify(e.value);
          final firstLine = e.value.split('\n').first.trim();
          final title = firstLine.length > 54 ? '${firstLine.substring(0, 54)}…' : firstLine;
          return ExtractedClause(
            number: e.key,
            title: title,
            text: e.value,
            category: cat,
            plain: _plainByCategory[cat] ?? '',
          );
        }(),
    ];
  }

  static AnalysisResult analyze(String text) {
    final clauses = extract(text);
    final flags = <RiskFlag>[];
    for (final c in clauses) {
      for (final r in _rules) {
        final m = r.pattern.firstMatch(c.text);
        if (m == null) continue;
        final s = (m.start - 40).clamp(0, c.text.length);
        final e = (m.end + 40).clamp(0, c.text.length);
        flags.add(RiskFlag(
          severity: r.severity,
          title: r.title,
          clauseTitle: '${c.number}. ${c.title}',
          quote: '…${c.text.substring(s, e).replaceAll('\n', ' ').trim()}…',
          plain: r.plain,
          fix: r.fix,
        ));
      }
    }
    flags.sort((a, b) => b.severity.index.compareTo(a.severity.index));

    final missing = [
      for (final q in _required)
        if (!q.pattern.hasMatch(text)) MissingTerm(title: q.title, why: q.why, wording: q.wording, important: q.important),
    ];

    var risk = 0;
    for (final f in flags) {
      risk += switch (f.severity) { Severity.high => 16, Severity.medium => 8, Severity.low => 3 };
    }
    for (final m in missing) {
      risk += m.important ? 6 : 2;
    }
    risk = risk.clamp(0, 100);
    final level = risk >= 60 ? 'High risk' : (risk >= 35 ? 'Moderate risk' : 'Low risk');
    final words = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    return AnalysisResult(risk: risk, level: level, flags: flags, missing: missing, clauses: clauses, words: words);
  }

  /// Plain-text redline suggestions ready to send back to the client.
  static String counterProposal(AnalysisResult r) {
    final b = StringBuffer('Proposed changes to the draft agreement\n\n');
    var i = 1;
    for (final f in r.flags) {
      b.writeln('$i. ${f.clauseTitle}: ${f.title}\n   Suggested change: ${f.fix}\n');
      i++;
    }
    for (final m in r.missing.where((m) => m.important)) {
      b.writeln('$i. Add: ${m.title}\n   Suggested wording: ${m.wording}\n');
      i++;
    }
    return b.toString();
  }

  static const sampleClientContract = '''SERVICE AGREEMENT

1. Services. The Contractor shall design and develop the Client's mobile application and any additional features requested by the Client at no additional cost.

2. Revisions. The Contractor shall provide unlimited revisions until the Client is fully satisfied with the deliverables.

3. Fees. The total fee is INR 120,000. Payment shall be made within 90 days after final delivery, at the sole discretion of the Client's finance team.

4. Intellectual Property. All work product constitutes work made for hire, and all intellectual property rights vest in the Client immediately upon creation.

5. Exclusivity. The Contractor shall work exclusively for the Client during the term and shall not provide similar services to any competitor for 12 months after completion.

6. Termination. The Client may terminate this agreement at any time without cause and without further payment or compensation to the Contractor.

7. Support. The Contractor shall provide free bug fixes and support for the lifetime of the application.

8. Indemnity. The Contractor shall indemnify the Client against all losses, claims and expenses arising from the services.

9. Delays. If the Contractor misses any deadline, liquidated damages of 2% of the fee apply for each day of delay.

10. Confidentiality. Both parties shall keep project information confidential.''';
}
