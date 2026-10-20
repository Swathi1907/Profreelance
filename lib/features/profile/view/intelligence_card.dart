import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Documents the models behind each feature, and where a trained model plugs in.
class IntelligenceCard extends StatelessWidget {
  const IntelligenceCard({super.key});

  static const rows = [
    ('Estimation', 'k-nearest neighbours over your finished projects (cosine similarity on domain, stack and description features, similarity-weighted hours).', 'Swap for a gradient-boosted regressor served by FastAPI.'),
    ('Contract analysis', 'Clause segmentation, keyword classifier, weighted risk lexicon and a missing-term checklist.', 'Swap for a fine-tuned legal-domain transformer.'),
    ('Client reliability', 'Weighted sub-scores with recency decay and Bayesian shrinkage toward a prior.', 'Add a logistic model that predicts late payment.'),
    ('Smart alerts', 'Rule engine over deadlines, payments, contracts, scope changes and burn rate.', 'Add anomaly detection on hours logged.'),
    ('Negotiation', 'Intent detection plus deterministic arithmetic for every concession.', 'Let an LLM rewrite only the wording, never the numbers.'),
  ];

  @override
  Widget build(BuildContext context) {
    return PfCard(
      child: Column(children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const Divider(height: 24),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 110, child: Text(rows[i].$1, style: const TextStyle(fontWeight: FontWeight.w800))),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(rows[i].$2, style: const TextStyle(fontSize: 13, height: 1.4)),
                const SizedBox(height: 4),
                Text(rows[i].$3, style: context.tt.bodySmall?.copyWith(color: context.cs.primary, fontWeight: FontWeight.w700)),
              ]),
            ),
          ]),
        ],
      ]),
    );
  }
}
