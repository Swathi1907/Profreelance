import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'auth_frame.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pw = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pw.dispose();
    super.dispose();
  }

  void _submit(AuthViewModel vm) {
    if (_form.currentState!.validate()) vm.register(_name.text.trim(), _email.text.trim(), _pw.text);
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(authViewModelProvider);
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final align = wide ? TextAlign.start : TextAlign.center;
    final colors = [context.pf.danger, context.pf.warning, context.pf.warning, context.pf.success];
    const labels = ['Too weak', 'Weak', 'Fair', 'Good', 'Strong'];
    return AuthFrame(
      child: Form(
        key: _form,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (!wide) Reveal(child: authLogo()),
          const SizedBox(height: 20),
          Reveal(delay: 60, child: Text('Join FreelancePro', textAlign: align, style: context.tt.headlineMedium)),
          const SizedBox(height: 6),
          Reveal(
            delay: 100,
            child: Text('Create your account to start managing projects.', textAlign: align, style: context.tt.bodyMedium?.copyWith(color: context.cs.onSurfaceVariant)),
          ),
          const SizedBox(height: 28),
          if (vm.error != null) AuthError(vm.error!),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
            validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your full name.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.mail_outline)),
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email address.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pw,
            obscureText: vm.hidePassword,
            onChanged: vm.setPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                onPressed: vm.togglePassword,
                icon: Icon(vm.hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              ),
            ),
            validator: (v) => vm.passwordAcceptable ? null : 'Use at least 8 characters, with a number and a symbol.',
          ),
          const SizedBox(height: 10),
          Row(children: [
            for (var i = 0; i < 4; i++)
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 5,
                  margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: i < vm.strength ? colors[vm.strength - 1] : context.cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Text(labels[vm.strength], style: monoStyle(context, size: 10.5)),
          ]),
          const SizedBox(height: 6),
          Text('Use at least 8 characters, with a number and a symbol.', style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant)),
          const SizedBox(height: 16),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => vm.setAgreed(!vm.agreed),
            child: Row(children: [
              Checkbox(value: vm.agreed, onChanged: (v) => vm.setAgreed(v ?? false)),
              Expanded(child: Text('I agree to the Terms & Conditions and Privacy Policy', style: TextStyle(color: context.cs.primary, fontSize: 13))),
            ]),
          ),
          if (vm.agreeError != null) Text(vm.agreeError!, style: TextStyle(color: context.pf.danger, fontSize: 12)),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: vm.busy ? null : () => _submit(vm),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            child: BusyLabel(busy: vm.busy, label: 'Create Account'),
          ),
          const SizedBox(height: 24),
          const OrDivider(),
          const SizedBox(height: 20),
          const SocialButtons(verb: 'Sign up'),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Already have an account?', style: TextStyle(color: context.cs.onSurfaceVariant)),
            TextButton(onPressed: () => context.go('/login'), child: const Text('Log In')),
          ]),
        ]),
      ),
    );
  }
}
