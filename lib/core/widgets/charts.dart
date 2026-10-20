import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/format.dart';
import 'widgets.dart';

class BarGroup {
  const BarGroup(this.label, this.a, this.b);
  final String label;
  final double a;
  final double b;
}

/// Two bars per label (for example paid vs pending, or estimated vs actual).
class PairedBarChart extends StatelessWidget {
  const PairedBarChart({
    super.key,
    required this.groups,
    required this.aLabel,
    required this.bLabel,
    this.height = 150,
    this.money = true,
  });

  final List<BarGroup> groups;
  final String aLabel;
  final String bLabel;
  final double height;
  final bool money;

  @override
  Widget build(BuildContext context) {
    final maxV = max(1.0, groups.fold<double>(0, (m, g) => max(m, max(g.a, g.b))));
    final ca = context.isDark ? Pf.gold : Pf.maroon;
    final cb = context.isDark ? const Color(0xFFE3B7C2) : Pf.gold;
    String fmt(double v) => v == 0 ? '' : (money ? inrShort(v) : v.round().toString());

    Widget bar(double v, Color c) => Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text(fmt(v), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: v / maxV),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (_, t, __) => Container(
                height: max(2.0, (height - 36) * t),
                decoration: BoxDecoration(color: c, borderRadius: const BorderRadius.vertical(top: Radius.circular(5))),
              ),
            ),
          ]),
        );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        height: height,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          for (final g in groups)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(children: [
                  Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [bar(g.a, ca), const SizedBox(width: 3), bar(g.b, cb)])),
                  const SizedBox(height: 6),
                  Text(g.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: monoStyle(context, size: 9.5)),
                ]),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 12),
      Row(children: [
        _Legend(color: ca, label: aLabel),
        const SizedBox(width: 16),
        _Legend(color: cb, label: bLabel),
      ]),
    ]);
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: context.tt.bodySmall),
      ]);
}

/// Label, animated bar and count on one line.
class HBarList extends StatelessWidget {
  const HBarList({super.key, required this.entries, this.color});
  final List<MapEntry<String, int>> entries;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final maxV = entries.isEmpty ? 1 : entries.map((e) => e.value).reduce(max);
    return Column(children: [
      for (final e in entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            SizedBox(width: 110, child: Text(e.key, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            Expanded(child: AnimatedBar(value: e.value / maxV, color: color)),
            const SizedBox(width: 10),
            SizedBox(width: 22, child: Text('${e.value}', textAlign: TextAlign.end, style: monoStyle(context, size: 11))),
          ]),
        ),
    ]);
  }
}
