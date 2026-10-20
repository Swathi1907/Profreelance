import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../theme/app_colors.dart';
import 'widgets.dart';

class MonoLabel extends StatelessWidget {
  const MonoLabel(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: monoStyle(context, size: 10, color: color));
}

class PfChip extends StatelessWidget {
  const PfChip(this.label, {super.key, required this.color, this.dot = false, this.icon});
  final String label;
  final Color color;
  final bool dot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
