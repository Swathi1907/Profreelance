import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base class for every ViewModel.
///
/// A ViewModel exposes plain getters and command methods to its View, and
/// never imports a widget. It subscribes to the repositories it depends on
/// with [watch], so the View only ever has to watch the ViewModel.
abstract class BaseViewModel extends ChangeNotifier {
  BaseViewModel(this.ref);

  final Ref ref;
  bool _disposed = false;

  /// True after the screen is gone. Check it after any `await` before using [ref].
  bool get isDisposed => _disposed;

  void watch<T>(ProviderListenable<T> provider) {
    ref.listen<T>(provider, (_, __) => refresh());
  }

  void refresh() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
