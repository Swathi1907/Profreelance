import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../theme/app_colors.dart';
import 'widgets.dart';

/// Fades and lifts its child in. Used for staggered entrances.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.delay = 0});
  final Widget child;
  final int delay;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  late final Animation<double> _a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
  late final Animation<Offset> _slide = Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(_a);
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return FadeTransition(opacity: _a, child: SlideTransition(position: _slide, child: widget.child));
  }
}

/// Number that counts up to its value.
class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.value, required this.format, this.style});
  final double value;
  final String Function(double) format;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(format(v), style: style),
    );
  }
}

/// Reveals text word by word, like a streamed model reply.
class StreamedText extends StatefulWidget {
  const StreamedText(this.text, {super.key, this.style, this.animate = true, this.onDone});
  final String text;
  final TextStyle? style;
  final bool animate;
  final VoidCallback? onDone;

  @override
  State<StreamedText> createState() => _StreamedTextState();
}

class _StreamedTextState extends State<StreamedText> {
  Timer? _t;
  int _shown = 0;
  late final List<String> _words = widget.text.split(' ');

  @override
  void initState() {
    super.initState();
    if (!widget.animate) {
      _shown = _words.length;
      return;
    }
    _t = Timer.periodic(const Duration(milliseconds: 28), (t) {
      if (!mounted) return;
      setState(() => _shown = min(_words.length, _shown + 3));
      if (_shown >= _words.length) {
        t.cancel();
        widget.onDone?.call();
      }
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Text(_words.take(_shown).join(' '), style: widget.style);
}
