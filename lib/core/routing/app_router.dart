import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/landing/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/auth_state.dart';

/// Configuración de rutas de la aplicación
///
/// Usa GoRouter para navegación declarativa y URLs amigables
class AppRouter {
  // ========== NOMBRES DE RUTAS ==========

  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String players = '/players';
  static const String teams = '/teams';
  static const String trainings = '/trainings';
  static const String matches = '/matches';

  // ========== RUTAS PÚBLICAS ==========
  static const List<String> publicRoutes = [
    landing,
    login,
    register,
  ];

  // ========== CONFIGURACIÓN DEL ROUTER ==========

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: landing,
      debugLogDiagnostics: true,
      refreshListenable: _GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState.isAuthenticated;
        final needsMigration = authState.needsPasswordMigration;
        final isPublicRoute = publicRoutes.contains(state.matchedLocation);

        // Si necesita migración, mantenerlo en /login
        if (needsMigration && state.matchedLocation != login) {
          return login;
        }
        if (needsMigration) {
          return null; // No redirect, stay on login to show migration form
        }

        // Si no está autenticado y trata de acceder a ruta protegida
        if (!isAuthenticated && !isPublicRoute) {
          return login;
        }

        // Si está autenticado y trata de acceder a login/register
        if (isAuthenticated &&
            (state.matchedLocation == login ||
                state.matchedLocation == register)) {
          return dashboard;
        }

        return null; // No redirect needed
      },
      routes: [
        // ========== LANDING PAGE ==========
        GoRoute(
          path: landing,
          name: 'landing',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const LandingPage(),
          ),
        ),

        // ========== AUTH ROUTES ==========
        GoRoute(
          path: login,
          name: 'login',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const LoginPage(),
          ),
        ),

        // ========== DASHBOARD (PROTEGIDO) ==========
        GoRoute(
          path: dashboard,
          name: 'dashboard',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const DashboardPage(),
          ),
        ),

        // TODO: Agregar más rutas protegidas según se implementen
      ],

      // ========== ERROR HANDLING ==========
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                '404 - Página no encontrada',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(landing),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Router estático para compatibilidad (usar createRouter en producción)
  static final GoRouter router = GoRouter(
    initialLocation: landing,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: landing,
        name: 'landing',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LandingPage(),
        ),
      ),
      GoRoute(
        path: login,
        name: 'login',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const DashboardPage(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '404 - Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(landing),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Helper class to refresh GoRouter when auth state changes
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<AuthState> stream) {
    // No llamamos notifyListeners() aquí para evitar bucles infinitos
    // GoRouter se suscribirá automáticamente cuando esté listo
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
