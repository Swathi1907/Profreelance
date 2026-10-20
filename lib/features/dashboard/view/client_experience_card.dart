import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../viewmodel/dashboard_viewmodel.dart';

/// Overall client experience across all clients. Tapping opens the clients tab.
class ClientExperienceCard extends StatelessWidget {
  const ClientExperienceCard({super.key, required this.vm});
  final DashboardViewModel vm;

  @override
  Widget build(BuildContext context) {
    final x = vm.clientExperience;
    return PfCard(
      onTap: () => context.go('/clients'),
      child: x.rated == 0
          ? const Text('Rate your first client to see their reliability here.')
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                ScoreRing(score: x.average, size: 84, caption: 'AVG'),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${x.rated} clients rated', style: context.tt.titleMedium),
                    if (x.onTimeRate != null) Text('${(x.onTimeRate! * 100).round()}% of payments on time', style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      for (final e in x.tiers.entries) PfChip('${e.value} ${e.key}', color: _tierColor(context, e.key)),
                    ]),
                  ]),
                ),
              ]),
              const Divider(height: 24),
              Row(children: [
                Expanded(child: _Mention(icon: Icons.emoji_events_outlined, label: 'BEST', name: x.best?.name ?? '-', color: context.pf.success)),
                Expanded(child: _Mention(icon: Icons.warning_amber_rounded, label: 'WATCH', name: x.needsAttention?.name ?? '-', color: context.pf.warning)),
              ]),
            ]),
    );
  }

  Color _tierColor(BuildContext c, String tier) => switch (tier) {
        'Reliable' || 'Good' => c.pf.success,
        'Cautious' => c.pf.warning,
        'High risk' => c.pf.danger,
        _ => c.cs.onSurfaceVariant,
      };
}

class _Mention extends StatelessWidget {
  const _Mention({required this.icon, required this.label, required this.name, required this.color});
  final IconData icon;
  final String label;
  final String name;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [MonoLabel(label), Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))])),
      ]);
}
