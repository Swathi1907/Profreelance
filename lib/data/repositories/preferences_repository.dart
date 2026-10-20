import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Preferences {
  const Preferences({
    this.userName = 'Aarav Mehta',
    this.userEmail = 'aarav@profreelance.dev',
    this.hourlyRate = 1000,
    this.alertLeadDays = 7,
    this.dismissedAlerts = const {},
    this.customDomains = const [],
    this.address = 'Bengaluru, India',
    this.gstin = '',
  });

  final String userName;
  final String userEmail;
  final double hourlyRate;
  final int alertLeadDays;
  final Set<String> dismissedAlerts;
  final List<String> customDomains;
  final String address;
  final String gstin;

  Preferences copyWith({
    String? userName,
    String? userEmail,
    double? hourlyRate,
    int? alertLeadDays,
    Set<String>? dismissedAlerts,
    List<String>? customDomains,
    String? address,
    String? gstin,
  }) =>
      Preferences(
        userName: userName ?? this.userName,
        userEmail: userEmail ?? this.userEmail,
        hourlyRate: hourlyRate ?? this.hourlyRate,
        alertLeadDays: alertLeadDays ?? this.alertLeadDays,
        dismissedAlerts: dismissedAlerts ?? this.dismissedAlerts,
        customDomains: customDomains ?? this.customDomains,
        address: address ?? this.address,
        gstin: gstin ?? this.gstin,
      );
}

class PreferencesRepository extends Notifier<Preferences> {
  @override
  Preferences build() => const Preferences();

  void setUser(String name, String email) => state = state.copyWith(userName: name, userEmail: email);
  void setHourlyRate(double v) => state = state.copyWith(hourlyRate: v);
  void setLeadDays(int v) => state = state.copyWith(alertLeadDays: v);
  void setBusiness({String? address, String? gstin}) => state = state.copyWith(address: address, gstin: gstin);
  void dismiss(String id) => state = state.copyWith(dismissedAlerts: {...state.dismissedAlerts, id});
  void restoreAlerts() => state = state.copyWith(dismissedAlerts: {});

  void addDomain(String d) {
    final v = d.trim();
    if (v.isEmpty || state.customDomains.contains(v)) return;
    state = state.copyWith(customDomains: [...state.customDomains, v]);
  }
}

final preferencesProvider = NotifierProvider<PreferencesRepository, Preferences>(PreferencesRepository.new);

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
