import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../core/widgets/charts.dart';
import '../../../domain/domain_providers.dart';
import '../../../domain/services/analytics.dart';

class InsightsViewModel extends BaseViewModel {
  InsightsViewModel(super.ref) {
    watch(analyticsProvider);
  }

  AnalyticsSummary get s => ref.read(analyticsProvider);
  bool get hasHistory => s.completed.isNotEmpty;

  /// Estimated vs actual hours per finished project.
  List<BarGroup> get estimateVsActual => [
        for (final p in s.completed) BarGroup(p.name.split(' ').first, p.estimatedHours, p.actualHours),
      ];

  List<MapEntry<String, int>> get topTech => s.techFreq.take(8).toList();
  List<MapEntry<String, int>> get topDomains => s.domainFreq.take(6).toList();

  String get biasNote {
    final b = s.bias;
    if (b > 1.05) return 'Your estimates run ${((b - 1) * 100).round()}% low. New quotes from the estimator already use real hours from similar projects, so you are corrected automatically.';
    if (b < 0.95) return 'You tend to overestimate by ${((1 - b) * 100).round()}%. You may be leaving competitive room on price.';
    return 'Your estimates are well calibrated.';
  }
}

final insightsViewModelProvider = ChangeNotifierProvider.autoDispose<InsightsViewModel>((ref) => InsightsViewModel(ref));
