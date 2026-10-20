import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../theme/app_colors.dart';
import 'widgets.dart';

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({super.key, required this.value, this.color, this.height = 8});
  final double value; // 0..1
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.cs.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Container(
        height: height,
        color: context.cs.surfaceContainerHighest,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value.clamp(0, 1)),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (_, v, __) => FractionallySizedBox(
            widthFactor: v,
            child: Container(decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(height))),
          ),
        ),
      ),
    );
  }
}

class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.score, this.size = 96, this.caption, this.color, this.stroke = 9});
  final double score; // 0..100
  final double size;
  final double stroke;
  final String? caption;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final col = color ?? scoreColor(context, score);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score.clamp(0, 100) / 100),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _RingPainter(v, col, context.cs.surfaceContainerHighest, stroke),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(v * 100).round()}',
                    style: context.tt.titleLarge?.copyWith(fontSize: size * 0.28, height: 1)),
                if (caption != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(caption!, style: monoStyle(context, size: max(8, size * 0.09))),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color, this.track, this.stroke);
  final double value;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 2 * pi, false, p..color = track);
    canvas.drawArc(rect, -pi / 2, 2 * pi * value, false, p..color = color);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.value != value || o.color != color || o.track != track;
}
