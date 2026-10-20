import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/auth_repository.dart';
import '../features/alerts/view/alerts_screen.dart';
import '../features/auth/view/login_screen.dart';
import '../features/auth/view/signup_screen.dart';
import '../features/clients/view/client_detail_screen.dart';
import '../features/clients/view/clients_screen.dart';
import '../features/contracts/view/amendment/amendment_screen.dart';
import '../features/contracts/view/analyzer/contract_analyzer_screen.dart';
import '../features/contracts/view/contract_view_screen.dart';
import '../features/contracts/view/contracts_screen.dart';
import '../features/contracts/view/wizard/contract_wizard_screen.dart';
import '../features/dashboard/view/dashboard_screen.dart';
import '../features/insights/view/insights_screen.dart';
import '../features/negotiation/view/negotiation_screen.dart';
import '../features/payments/view/payments_screen.dart';
import '../features/profile/view/profile_screen.dart';
import '../features/projects/view/project_form_screen.dart';
import '../features/projects/view/projects_screen.dart';
import '../features/projects/view/workspace/project_workspace_screen.dart';
import '../features/vault/view/vault_screen.dart';
import 'adaptive_shell.dart';

CustomTransitionPage<void> _page(GoRouterState s, Widget child) => CustomTransitionPage<void>(
      key: s.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, anim, secondary, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(position: Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(curved), child: child),
        );
      },
    );

StatefulShellBranch _branch(String path, Widget screen) =>
    StatefulShellBranch(routes: [GoRoute(path: path, builder: (c, s) => screen)]);

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen<AuthState>(authProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final signedIn = ref.read(authProvider).signedIn;
      final loc = state.matchedLocation;
      final onAuth = loc == '/login' || loc == '/signup';
      if (!signedIn && !onAuth) return '/login';
      if (signedIn && onAuth) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', pageBuilder: (c, s) => _page(s, const LoginScreen())),
      GoRoute(path: '/signup', pageBuilder: (c, s) => _page(s, const SignupScreen())),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AdaptiveShell(shell: shell),
        branches: [
          _branch('/dashboard', const DashboardScreen()),
          _branch('/projects', const ProjectsScreen()),
          _branch('/contracts', const ContractsScreen()),
          _branch('/payments', const PaymentsScreen()),
          _branch('/insights', const InsightsScreen()),
          _branch('/clients', const ClientsScreen()),
          _branch('/vault', const VaultScreen()),
          _branch('/negotiate', const NegotiationScreen()),
          _branch('/alerts', const AlertsScreen()),
          _branch('/profile', const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/projects/new', pageBuilder: (c, s) => _page(s, const ProjectFormScreen())),
      GoRoute(path: '/projects/:id', pageBuilder: (c, s) => _page(s, ProjectWorkspaceScreen(id: s.pathParameters['id']!))),
      GoRoute(path: '/projects/:id/amend', pageBuilder: (c, s) => _page(s, AmendmentScreen(projectId: s.pathParameters['id']!))),
      GoRoute(path: '/contracts/new', pageBuilder: (c, s) => _page(s, ContractWizardScreen(projectId: s.uri.queryParameters['project']))),
      GoRoute(path: '/contracts/analyze', pageBuilder: (c, s) => _page(s, ContractAnalyzerScreen(projectId: s.uri.queryParameters['project']))),
      GoRoute(path: '/contracts/:id', pageBuilder: (c, s) => _page(s, ContractViewScreen(id: s.pathParameters['id']!))),
      GoRoute(path: '/clients/:id', pageBuilder: (c, s) => _page(s, ClientDetailScreen(id: s.pathParameters['id']!))),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
