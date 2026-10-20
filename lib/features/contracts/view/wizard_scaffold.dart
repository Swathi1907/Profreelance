import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

/// Shared frame for the contract and amendment wizards: progress header,
/// animated step body and a Back / Continue bar.
class WizardScaffold extends StatelessWidget {
  const WizardScaffold({
    super.key,
    required this.title,
    required this.steps,
    required this.step,
    required this.body,
    required this.onBack,
    required this.onNext,
    this.nextLabel = 'Continue',
    this.busy = false,
    this.extra,
    this.bodyKey,
  });

  final String title;
  final List<String> steps;
  final int step;
  final Widget body;
  final VoidCallback onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool busy;
  final Widget? extra;
  final Object? bodyKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.canPop() ? context.pop() : context.go('/contracts')),
      ),
      body: Column(children: [
        Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('STEP ${step + 1} OF ${steps.length}', style: monoStyle(context, size: 10.5)),
                const SizedBox(height: 4),
                Text(steps[step], style: context.tt.headlineSmall),
                const SizedBox(height: 12),
                Row(children: [
                  for (var i = 0; i < steps.length; i++)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 5,
                        margin: EdgeInsets.only(right: i < steps.length - 1 ? 6 : 0),
                        decoration: BoxDecoration(
                          color: i <= step ? (context.isDark ? Pf.gold : Pf.maroon) : context.cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                ]),
                if (MediaQuery.sizeOf(context).width > 700)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(children: [
                      for (var i = 0; i < steps.length; i++)
                        Expanded(child: Text(steps[i], style: TextStyle(fontSize: 11, fontWeight: i == step ? FontWeight.w800 : FontWeight.w500, color: i <= step ? context.cs.onSurface : context.cs.onSurfaceVariant))),
                    ]),
                  ),
              ]),
            ),
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(position: Tween(begin: const Offset(0.03, 0), end: Offset.zero).animate(anim), child: child),
            ),
            child: KeyedSubtree(
              key: ValueKey(bodyKey ?? step),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [body]),
                ),
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(color: context.cs.surface, border: Border(top: BorderSide(color: context.cs.outlineVariant))),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 860),
                child: Row(children: [
                  if (step > 0) OutlinedButton(onPressed: onBack, child: const Text('Back')),
                  const Spacer(),
                  if (extra != null) ...[extra!, const SizedBox(width: 10)],
                  FilledButton(
                    onPressed: busy ? null : onNext,
                    child: busy ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white)) : Text(nextLabel),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
