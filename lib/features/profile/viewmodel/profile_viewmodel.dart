import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/portfolio_provider.dart';
import '../../../data/repositories/preferences_repository.dart';

class ProfileViewModel extends BaseViewModel {
  ProfileViewModel(super.ref) {
    watch(preferencesProvider);
    watch(themeModeProvider);
    watch(portfolioProvider);
  }

  Preferences get prefs => ref.read(preferencesProvider);
  ThemeMode get themeMode => ref.read(themeModeProvider);
  int get projectCount => ref.read(portfolioProvider).projects.length;
  int get clientCount => ref.read(portfolioProvider).clients.length;
  int get fileCount => ref.read(portfolioProvider).docs.length;

  void setTheme(ThemeMode m) => ref.read(themeModeProvider.notifier).state = m;
  void setRate(String v) {
    final r = double.tryParse(v);
    if (r != null && r > 0) ref.read(preferencesProvider.notifier).setHourlyRate(r);
  }

  void setBusiness({String? address, String? gstin}) => ref.read(preferencesProvider.notifier).setBusiness(address: address, gstin: gstin);
  void signOut() => ref.read(authProvider.notifier).signOut();
}

final profileViewModelProvider = ChangeNotifierProvider.autoDispose<ProfileViewModel>((ref) => ProfileViewModel(ref));
