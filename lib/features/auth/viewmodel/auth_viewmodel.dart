import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mvvm/base_viewmodel.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthViewModel extends BaseViewModel {
  AuthViewModel(super.ref);

  bool busy = false;
  String? error;
  bool hidePassword = true;
  bool agreed = false;
  String? agreeError;
  String password = '';

  /// 0 to 4: length, mixed case, digit, symbol.
  int get strength {
    var s = 0;
    if (password.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) s++;
    if (RegExp(r'\d').hasMatch(password)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) s++;
    return s;
  }

  bool get passwordAcceptable => password.length >= 8 && strength >= 3;

  void togglePassword() {
    hidePassword = !hidePassword;
    refresh();
  }

  void setPassword(String v) {
    password = v;
    refresh();
  }

  void setAgreed(bool v) {
    agreed = v;
    if (v) agreeError = null;
    refresh();
  }

  Future<void> login(String email, String pw) async {
    busy = true;
    error = null;
    refresh();
    error = await ref.read(authProvider.notifier).signIn(email, pw);
    busy = false;
    refresh();
  }

  Future<void> register(String name, String email, String pw) async {
    if (!agreed) {
      agreeError = 'Please accept the Terms and Privacy Policy.';
      refresh();
      return;
    }
    busy = true;
    error = null;
    refresh();
    error = await ref.read(authProvider.notifier).signUp(name, email, pw);
    busy = false;
    refresh();
  }
}

final authViewModelProvider = ChangeNotifierProvider.autoDispose<AuthViewModel>((ref) => AuthViewModel(ref));
