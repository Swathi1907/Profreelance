import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences_repository.dart';

class AuthState {
  const AuthState({this.signedIn = false});
  final bool signedIn;
}

/// Mock authentication. Replace with Supabase `auth.signInWithPassword` /
/// `auth.signUp`, which the Kotlin app already uses.
class AuthRepository extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<String?> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!email.contains('@') || password.length < 6) return 'Wrong email or password.';
    state = const AuthState(signedIn: true);
    return null;
  }

  Future<String?> signUp(String name, String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    ref.read(preferencesProvider.notifier).setUser(name, email);
    state = const AuthState(signedIn: true);
    return null;
  }

  void signOut() => state = const AuthState();
}

final authProvider = NotifierProvider<AuthRepository, AuthState>(AuthRepository.new);
