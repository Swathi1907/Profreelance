import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';

/// Shared frame: brand panel on wide screens, logo header on phones.
class AuthFrame extends StatelessWidget {
  const AuthFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final form = SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: child),
        ),
      ),
    );
    if (!wide) return Scaffold(body: form);

    const points = [
      ('Contracts drafted and risk-checked by AI', Icons.description_outlined),
      ('Estimates learned from your own past projects', Icons.auto_graph),
      ('Payments, alerts and client scores in one place', Icons.account_balance_wallet_outlined),
    ];
    return Scaffold(
      body: Row(children: [
        Expanded(
          flex: 5,
          child: Container(
            color: context.isDark ? const Color(0xFF0B0206) : Pf.ink,
            padding: const EdgeInsets.all(56),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Reveal(child: ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.asset('assets/images/logo.jpg', width: 84, height: 84))),
              const SizedBox(height: 28),
              Reveal(
                delay: 100,
                child: Text('Run your freelance business like a studio.', style: context.tt.displaySmall?.copyWith(color: Pf.cream, height: 1.12)),
              ),
              const SizedBox(height: 32),
              for (var i = 0; i < points.length; i++)
                Reveal(
                  delay: 250 + i * 120,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(children: [
                      Icon(points[i].$2, color: Pf.gold, size: 22),
                      const SizedBox(width: 14),
                      Expanded(child: Text(points[i].$1, style: TextStyle(color: Pf.cream.withValues(alpha: 0.85), fontSize: 15))),
                    ]),
                  ),
                ),
            ]),
          ),
        ),
        Expanded(flex: 4, child: form),
      ]),
    );
  }
}

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.cs.onSurface.withValues(alpha: 0.35);
    return Row(children: [
      Expanded(child: Divider(color: c)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('OR CONTINUE WITH', style: monoStyle(context, size: 10.5, color: context.cs.onSurface)),
      ),
      Expanded(child: Divider(color: c)),
    ]);
  }
}

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key, required this.verb});
  final String verb;

  @override
  Widget build(BuildContext context) {
    final style = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      foregroundColor: context.cs.onSurface,
      side: BorderSide(color: context.cs.onSurface.withValues(alpha: 0.6)),
    );
    return Column(children: [
      OutlinedButton.icon(
        onPressed: () => toast(context, 'Google sign-in uses Supabase OAuth in the Android app. Demo only here.'),
        icon: const Icon(Icons.g_mobiledata, size: 28),
        label: Text('$verb with Google'),
        style: style,
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => toast(context, 'LinkedIn sign-in is a planned integration.'),
        icon: const Icon(Icons.business_center_outlined, size: 20),
        label: Text('$verb with LinkedIn'),
        style: style,
      ),
    ]);
  }
}

Widget authLogo() => Center(
      child: ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.asset('assets/images/logo.jpg', width: 84, height: 84)),
    );

class AuthError extends StatelessWidget {
  const AuthError(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: context.pf.danger.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Text(message, style: TextStyle(color: context.pf.danger)),
      );
}

class BusyLabel extends StatelessWidget {
  const BusyLabel({super.key, required this.busy, required this.label});
  final bool busy;
  final String label;
  @override
  Widget build(BuildContext context) => busy
      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
      : Text(label);
}
