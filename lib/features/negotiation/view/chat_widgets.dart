import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../../../domain/services/negotiation.dart';

class UserBubble extends StatelessWidget {
  const UserBubble(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(left: 48, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.isDark ? Pf.gold : Pf.maroon,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(4)),
          ),
          child: Text(text, style: TextStyle(color: context.isDark ? Pf.ink : Colors.white, height: 1.35)),
        ),
      );
}

class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key});
  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: context.cs.surfaceContainerLowest, border: Border.all(color: context.pf.cardLine), borderRadius: BorderRadius.circular(18)),
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 0; i < 3; i++)
                Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  decoration: BoxDecoration(
                    color: context.cs.primary.withValues(alpha: 0.25 + 0.75 * ((_c.value * 3 - i).clamp(0, 1))),
                    shape: BoxShape.circle,
                  ),
                ),
            ]),
          ),
        ),
      );
}

class AssistantBubble extends StatelessWidget {
  const AssistantBubble({super.key, required this.text, required this.animate, this.child});
  final String text;
  final bool animate;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(right: 24, bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cs.surfaceContainerLowest,
            border: Border.all(color: context.pf.cardLine),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(18), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (text.isNotEmpty) StreamedText(text, animate: animate, style: const TextStyle(height: 1.4)),
            if (child != null) ...[const SizedBox(height: 12), child!],
          ]),
        ),
      );
}

class StrategyCard extends StatelessWidget {
  const StrategyCard({super.key, required this.s, required this.onDraft});
  final Strategy s;
  final VoidCallback onDraft;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: s.applicable ? 1 : 0.55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: context.cs.surfaceContainer, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(s.icon, size: 20, color: context.cs.primary),
            const SizedBox(width: 8),
            Expanded(child: Text('Option ${s.option}: ${s.title}', style: const TextStyle(fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 6),
          Text(s.summary, style: context.tt.bodySmall),
          const SizedBox(height: 4),
          Text(s.math, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: Text(s.margin, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant, fontStyle: FontStyle.italic))),
            if (s.applicable) TextButton(onPressed: onDraft, child: const Text('Draft reply')),
          ]),
        ]),
      ),
    );
  }
}

class DraftBlock extends StatelessWidget {
  const DraftBlock({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: context.cs.surfaceContainer, borderRadius: BorderRadius.circular(14), border: Border.all(color: context.pf.cardLine)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const MonoLabel('Draft message'),
          const SizedBox(height: 8),
          SelectableText(text, style: const TextStyle(height: 1.45)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: text));
                toast(context, 'Draft copied.');
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38)),
            ),
          ),
        ]),
      );
}

class ReplyExtras extends StatelessWidget {
  const ReplyExtras({super.key, required this.reply, required this.onDraft});
  final NegotiationReply reply;
  final ValueChanged<Strategy> onDraft;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final s in reply.strategies) StrategyCard(s: s, onDraft: () => onDraft(s)),
      if (reply.package != null) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(reply.package!, style: const TextStyle(fontWeight: FontWeight.w700))),
      if (reply.floor != null) Padding(padding: const EdgeInsets.only(bottom: 10), child: Text('Your walk-away price (15% floor): ${inr(reply.floor!)}', style: context.tt.bodySmall)),
      if (reply.warning != null && reply.warning!.isNotEmpty)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: context.pf.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.warning_amber_rounded, size: 18, color: context.pf.warning),
            const SizedBox(width: 8),
            Expanded(child: Text(reply.warning!, style: const TextStyle(fontSize: 13))),
          ]),
        ),
      if (reply.draft != null) DraftBlock(text: reply.draft!),
    ]);
  }
}
