import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/format.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/preferences_repository.dart';
import '../domain/domain_providers.dart';

class Dest {
  const Dest(this.label, this.icon, this.selectedIcon, this.path);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String path;
}

const kDests = <Dest>[
  Dest('Dashboard', Icons.dashboard_outlined, Icons.dashboard, '/dashboard'),
  Dest('Projects', Icons.folder_outlined, Icons.folder, '/projects'),
  Dest('Contracts', Icons.description_outlined, Icons.description, '/contracts'),
  Dest('Payments', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, '/payments'),
  Dest('Insights', Icons.insights_outlined, Icons.insights, '/insights'),
  Dest('Clients', Icons.people_outline, Icons.people, '/clients'),
  Dest('Vault', Icons.inventory_2_outlined, Icons.inventory_2, '/vault'),
  Dest('Negotiate', Icons.forum_outlined, Icons.forum, '/negotiate'),
  Dest('Alerts', Icons.notifications_outlined, Icons.notifications, '/alerts'),
  Dest('Profile', Icons.person_outline, Icons.person, '/profile'),
];

/// One shell, two layouts:
///   phone  (< 700px)  bottom navigation: 4 tabs + "More"
///   laptop (>= 700px) side navigation: icon rail, or full sidebar from 1100px
class AdaptiveShell extends ConsumerWidget {
  const AdaptiveShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  void _go(int i) => shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final w = MediaQuery.sizeOf(context).width;
    final idx = shell.currentIndex;
    final alerts = ref.watch(alertsProvider).length;

    if (w < 700) {
      return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/images/logo.jpg', width: 30, height: 30)),
            const SizedBox(width: 10),
            Text(kDests[idx].label),
          ]),
          actions: [_TopActions(alerts: alerts)],
        ),
        body: shell,
        bottomNavigationBar: _bottomBar(context, idx),
      );
    }

    final extended = w >= 1100;
    return Scaffold(
      body: Row(children: [
        _Sidebar(extended: extended, index: idx, alerts: alerts, onSelect: _go),
        Expanded(
          child: Column(children: [
            Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.cs.outlineVariant))),
              child: Row(children: [
                Text(kDests[idx].label, style: context.tt.titleLarge),
                const Spacer(),
                _TopActions(alerts: alerts),
              ]),
            ),
            Expanded(child: shell),
          ]),
        ),
      ]),
    );
  }

  Widget _bottomBar(BuildContext context, int idx) {
    final sel = idx >= 4 ? 4 : idx;
    return NavigationBar(
      selectedIndex: sel,
      onDestinationSelected: (i) => i == 4 ? _more(context) : _go(i),
      destinations: [
        for (final d in kDests.take(4)) NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
        NavigationDestination(
          icon: const Icon(Icons.apps_outlined),
          selectedIcon: Icon(kDests[idx >= 4 ? idx : 4].selectedIcon),
          label: idx >= 4 ? kDests[idx].label : 'More',
        ),
      ],
    );
  }

  void _more(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Wrap(spacing: 12, runSpacing: 12, children: [
            for (var i = 4; i < kDests.length; i++)
              SizedBox(
                width: (MediaQuery.sizeOf(context).width - 32 - 24) / 3,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pop(sheet);
                    _go(i);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: shell.currentIndex == i ? context.cs.primaryContainer : context.cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.pf.cardLine),
                    ),
                    child: Column(children: [
                      Icon(kDests[i].icon, color: shell.currentIndex == i && !context.isDark ? Pf.maroon : context.cs.primary),
                      const SizedBox(height: 6),
                      Text(kDests[i].label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _TopActions extends ConsumerWidget {
  const _TopActions({required this.alerts});
  final int alerts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
        tooltip: 'Alerts',
        onPressed: () => context.go('/alerts'),
        icon: Badge(isLabelVisible: alerts > 0, label: Text('$alerts'), child: const Icon(Icons.notifications_outlined)),
      ),
      IconButton(
        tooltip: dark ? 'Light mode' : 'Dark mode',
        onPressed: () => ref.read(themeModeProvider.notifier).state = dark ? ThemeMode.light : ThemeMode.dark,
        icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      ),
      PopupMenuButton<String>(
        tooltip: 'Account',
        onSelected: (v) {
          if (v == 'profile') context.go('/profile');
          if (v == 'out') ref.read(authProvider.notifier).signOut();
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'profile', child: Text('Profile')),
          PopupMenuItem(value: 'out', child: Text('Sign out')),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: Pf.maroon,
            foregroundColor: Pf.gold,
            child: Text(initials(prefs.userName), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
          ),
        ),
      ),
    ]);
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({required this.extended, required this.index, required this.alerts, required this.onSelect});
  final bool extended;
  final int index;
  final int alerts;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferencesProvider);
    final bg = context.isDark ? const Color(0xFF0B0206) : Pf.ink;
    return Container(
      width: extended ? 248 : 88,
      color: bg,
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Row(mainAxisAlignment: extended ? MainAxisAlignment.start : MainAxisAlignment.center, children: [
              ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/images/logo.jpg', width: 42, height: 42)),
              if (extended) ...[
                const SizedBox(width: 12),
                Expanded(child: Text('ProFreelance', style: context.tt.titleMedium?.copyWith(color: Pf.cream, fontWeight: FontWeight.w800))),
              ],
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(children: [
                for (var i = 0; i < kDests.length; i++)
                  _SideItem(dest: kDests[i], selected: i == index, extended: extended, badge: kDests[i].path == '/alerts' ? alerts : 0, onTap: () => onSelect(i)),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: extended
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Pf.cream.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundColor: Pf.gold,
                        foregroundColor: Pf.ink,
                        child: Text(initials(prefs.userName), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(prefs.userName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Pf.cream, fontWeight: FontWeight.w700, fontSize: 13)),
                          Text('Freelancer', style: monoStyle(context, size: 10, color: Pf.cream.withValues(alpha: 0.6))),
                        ]),
                      ),
                      IconButton(
                        tooltip: 'Sign out',
                        onPressed: () => ref.read(authProvider.notifier).signOut(),
                        icon: Icon(Icons.logout, size: 18, color: Pf.cream.withValues(alpha: 0.7)),
                      ),
                    ]),
                  )
                : IconButton(
                    tooltip: 'Sign out',
                    onPressed: () => ref.read(authProvider.notifier).signOut(),
                    icon: Icon(Icons.logout, color: Pf.cream.withValues(alpha: 0.7)),
                  ),
          ),
        ]),
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  const _SideItem({required this.dest, required this.selected, required this.extended, required this.badge, required this.onTap});
  final Dest dest;
  final bool selected;
  final bool extended;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Pf.gold : Pf.cream.withValues(alpha: 0.72);
    final icon = Badge(
      isLabelVisible: badge > 0,
      label: Text('$badge'),
      child: Icon(selected ? dest.selectedIcon : dest.icon, color: color, size: 22),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? Pf.gold.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: extended
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(children: [
                    icon,
                    const SizedBox(width: 14),
                    Text(dest.label, style: TextStyle(color: color, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, fontSize: 14)),
                  ]),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(children: [
                    icon,
                    const SizedBox(height: 4),
                    Text(dest.label, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w700)),
                  ]),
                ),
        ),
      ),
    );
  }
}
