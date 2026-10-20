import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/format.dart';
import '../../../core/widgets/widgets.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'intelligence_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.watch(profileViewModelProvider);
    final p = vm.prefs;
    return PageBody(maxWidth: 900, children: [
      HeroCard(
        child: Row(children: [
          CircleAvatar(radius: 32, backgroundColor: Pf.gold, foregroundColor: Pf.ink, child: Text(initials(p.userName), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.userName, style: const TextStyle(color: Pf.cream, fontSize: 22, fontWeight: FontWeight.w800)),
              Text(p.userEmail, style: TextStyle(color: Pf.cream.withValues(alpha: 0.75))),
              const SizedBox(height: 8),
              Text('${vm.projectCount} projects  ·  ${vm.clientCount} clients  ·  ${vm.fileCount} files', style: monoStyle(context, size: 10.5, color: Pf.gold)),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 24),
      const SectionTitle('Business details', subtitle: 'Used to pre-fill contracts and estimates'),
      PfCard(
        child: Column(children: [
          PfField(label: 'Hourly rate', prefixText: '₹ ', decimal: true, initial: p.hourlyRate.round().toString(), helper: 'Fallback rate for estimates and extra-revision pricing', onChanged: vm.setRate),
          const FieldGap(),
          PfField(label: 'Business address', icon: Icons.location_on_outlined, initial: p.address, onChanged: (v) => vm.setBusiness(address: v)),
          const FieldGap(),
          PfField(label: 'GSTIN (optional)', icon: Icons.badge_outlined, initial: p.gstin, capitalize: TextCapitalization.characters, onChanged: (v) => vm.setBusiness(gstin: v)),
        ]),
      ),
      const SizedBox(height: 24),
      const SectionTitle('Appearance'),
      PfCard(
        child: SegmentedButton<ThemeMode>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_outlined), label: Text('Light')),
            ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_outlined), label: Text('Dark')),
            ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_outlined), label: Text('System')),
          ],
          selected: {vm.themeMode},
          onSelectionChanged: (s) => vm.setTheme(s.first),
        ),
      ),
      const SizedBox(height: 24),
      const SectionTitle('Intelligence layer', subtitle: 'What runs behind each feature'),
      const IntelligenceCard(),
      const SizedBox(height: 24),
      OutlinedButton.icon(onPressed: vm.signOut, icon: const Icon(Icons.logout), label: const Text('Sign out')),
      const SizedBox(height: 12),
      Center(child: Text('ProFreelance prototype v0.2  ·  Flutter  ·  MVVM', style: monoStyle(context, size: 10.5))),
    ]);
  }
}
