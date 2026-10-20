import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/models/models.dart';
import '../theme/app_colors.dart';
import 'widgets.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing, this.subtitle});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.tt.titleLarge),
                if (subtitle != null)
                  Text(subtitle!, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title, required this.subtitle, this.actions = const []});
  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.tt.headlineMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant)),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Scrollable page body with a centred max width, used by every tab.
class PageBody extends StatelessWidget {
  const PageBody({super.key, required this.children, this.maxWidth = 1100, this.bottomPad = 96});
  final List<Widget> children;
  final double maxWidth;
  final double bottomPad;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPad),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ),
      ],
    );
  }
}

/// Lays two groups side by side on wide screens and stacks them on phones.
class TwoCol extends StatelessWidget {
  const TwoCol({super.key, required this.left, required this.right, this.flex = const [3, 2], this.gap = 20});
  final List<Widget> left;
  final List<Widget> right;
  final List<int> flex;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      if (c.maxWidth < 800) {
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...left, SizedBox(height: gap), ...right]);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: flex[0], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: left)),
          SizedBox(width: gap),
          Expanded(flex: flex[1], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: right)),
        ],
      );
    });
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.body, this.action});
  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: context.cs.surfaceContainer, borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, size: 30, color: context.cs.primary),
            ),
            const SizedBox(height: 16),
            Text(title, style: context.tt.titleMedium),
            const SizedBox(height: 6),
            Text(body,
                textAlign: TextAlign.center,
                style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant)),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

/// Responsive grid of equal tiles: 2 columns on phones, 4 on wide screens.
class TileGrid extends StatelessWidget {
  const TileGrid({super.key, required this.children, this.minWidth = 200});
  final List<Widget> children;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final cols = (c.maxWidth / minWidth).floor().clamp(1, 4);
      final w = (c.maxWidth - (cols - 1) * 12) / cols;
      return Wrap(spacing: 12, runSpacing: 12, children: [for (final ch in children) SizedBox(width: w, child: ch)]);
    });
  }
}
