import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Maroon gradient panel with a gold hairline. Used for the headline card on a
/// screen. Children must set their own cream text colour.
class HeroCard extends StatelessWidget {
  const HeroCard({super.key, required this.child, this.padding = const EdgeInsets.all(20)});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Pf.maroon, Pf.ink]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Pf.gold.withValues(alpha: 0.35)),
      ),
      child: child,
    );
  }
}
