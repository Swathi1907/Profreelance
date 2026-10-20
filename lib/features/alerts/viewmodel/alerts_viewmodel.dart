import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/preferences_repository.dart';
import '../../../domain/domain_providers.dart';

class AlertsViewModel extends BaseViewModel {
  AlertsViewModel(super.ref) {
    watch(alertsProvider);
    watch(preferencesProvider);
  }

  AlertType? type;

  List<AppAlert> get all => ref.read(alertsProvider);
  List<AppAlert> get visible => type == null ? all : all.where((a) => a.type == type).toList();
  int countOf(AlertType t) => all.where((a) => a.type == t).length;
  int get dismissedCount => ref.read(preferencesProvider).dismissedAlerts.length;
  int get leadDays => ref.read(preferencesProvider).alertLeadDays;

  void setType(AlertType? t) {
    type = t;
    refresh();
  }

  void dismiss(String id) => ref.read(preferencesProvider.notifier).dismiss(id);
  void restore() => ref.read(preferencesProvider.notifier).restoreAlerts();
  void setLeadDays(int d) => ref.read(preferencesProvider.notifier).setLeadDays(d);

  static String label(AlertType t) => switch (t) {
        AlertType.deadline => 'Deadlines',
        AlertType.payment => 'Payments',
        AlertType.contract => 'Contracts',
        AlertType.scope => 'Scope changes',
        AlertType.estimation => 'Estimates',
      };
}

final alertsViewModelProvider = ChangeNotifierProvider.autoDispose<AlertsViewModel>((ref) => AlertsViewModel(ref));
