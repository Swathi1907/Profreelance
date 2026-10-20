import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/widgets.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'auth_frame.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'aarav@profreelance.dev');
  final _pw = TextEditingController(text: 'demo1234');

  @override
  void dispose() {
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  void _submit(AuthViewModel vm) {
    if (_form.currentState!.validate()) vm.login(_email.text.trim(), _pw.text);
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(authViewModelProvider);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final align = wide ? TextAlign.start : TextAlign.center;
    return AuthFrame(
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (!wide) Reveal(child: authLogo()),
          const SizedBox(height: 20),
          Reveal(delay: 60, child: Text('Welcome Back', textAlign: align, style: context.tt.headlineMedium)),
          const SizedBox(height: 6),
          Reveal(
            delay: 100,
            child: Text('Log in to manage your projects.', textAlign: align, style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant)),
          ),
          const SizedBox(height: 28),
          if (vm.error != null) AuthError(vm.error!),
          Reveal(
            delay: 140,
            child: TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.mail_outline)),
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email address.' : null,
            ),
          ),
          const SizedBox(height: 16),
          Reveal(
            delay: 180,
            child: TextFormField(
              controller: _pw,
              obscureText: vm.hidePassword,
              onFieldSubmitted: (_) => _submit(vm),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: vm.togglePassword,
                  icon: Icon(vm.hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Enter your password.' : null,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () => toast(context, 'Password reset is sent through Supabase Auth.'), child: const Text('Forgot Password?')),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: vm.busy ? null : () => _submit(vm),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            child: BusyLabel(busy: vm.busy, label: 'Log In'),
          ),
          const SizedBox(height: 28),
          const OrDivider(),
          const SizedBox(height: 20),
          const SocialButtons(verb: 'Continue'),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Don't have an account?", style: TextStyle(color: context.cs.onSurfaceVariant)),
            TextButton(onPressed: () => context.go('/signup'), child: const Text('Sign Up')),
          ]),
          Text('Demo mode: any email and a password of 6+ characters.',
              textAlign: TextAlign.center, style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
        ]),
      ),
    );
  }
}
