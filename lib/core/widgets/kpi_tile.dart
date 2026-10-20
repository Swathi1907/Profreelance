import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../theme/app_colors.dart';
import 'widgets.dart';

/// Small stat tile used on the dashboard and insights.
class KpiTile extends StatelessWidget {
  const KpiTile({super.key, required this.label, required this.value, this.icon, this.hint, this.color});
  final String label;
  final Widget value;
  final IconData? icon;
  final String? hint;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.cs.primary;
    return PfCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, size: 18, color: c),
                ),
              if (icon != null) const SizedBox(width: 10),
              Expanded(child: MonoLabel(label)),
            ],
          ),
          const SizedBox(height: 12),
          value,
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(hint!, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}
