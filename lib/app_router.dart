// lib/app_router.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/ui/screens/splash_screen.dart';
import 'package:venceya/ui/screens/login_screen.dart';
import 'package:venceya/ui/screens/signup_screen.dart';
import 'package:venceya/ui/screens/dashboard_screen.dart';
import 'package:venceya/ui/screens/add_edit_reminder_screen.dart';
import 'package:venceya/ui/screens/reminder_detail_screen.dart';
import 'package:venceya/ui/screens/profile_screen.dart';
import 'package:venceya/ui/screens/main_shell_screen.dart';

/// Centraliza toda la configuración de navegación de la aplicación.
class AppRouter {
  final AuthService authService;

  AppRouter(this.authService);

  /// La instancia de GoRouter que será utilizada por la aplicación.
  late final GoRouter router = GoRouter(
    // Configuración inicial del router.
    initialLocation: '/splash',
    debugLogDiagnostics: true, // Imprime logs de navegación para depuración.
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges),

    // Define todas las rutas de la aplicación.
    routes: <RouteBase>[
      GoRoute(
          path: '/splash',
          name: 'splash',
          builder: (context, state) => const SplashScreen()),
      GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignUpScreen()),
      // Ruta "cáscara" para mantener la barra de navegación inferior.
      ShellRoute(
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: <GoRoute>[
          GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => const DashboardScreen()),
          GoRoute(
              path: '/add-reminder',
              name: 'addReminder',
              builder: (context, state) => const AddEditReminderScreen()),
          GoRoute(
            path: '/edit-reminder/:id',
            name: 'editReminder',
            builder: (context, state) =>
                AddEditReminderScreen(reminderId: state.pathParameters['id']),
          ),
          GoRoute(
            path: '/reminder-detail/:id',
            name: 'reminderDetail',
            builder: (context, state) =>
                ReminderDetailScreen(reminderId: state.pathParameters['id']!),
          ),
          GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfileScreen()),
        ],
      ),
    ],

    /// Lógica de redirección que se ejecuta antes de cada navegación.
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authService.getCurrentUser() != null;
      final String location = state.matchedLocation;

      final bool isAuthRoute = location == '/login' || location == '/signup';
      final bool isSplash = location == '/splash';

      // Si el usuario NO está logueado Y NO está en una ruta pública, llévalo al login.
      if (!loggedIn && !isAuthRoute && !isSplash) {
        return '/login';
      }

      // Si ya está logueado y va a una ruta de autenticación o al splash, llévalo al dashboard.
      if (loggedIn && (isAuthRoute || isSplash)) {
        return '/dashboard';
      }

      // En el resto de los casos, permite la navegación.
      return null;
    },
  );
}

/// Convierte el Stream de autenticación en un Listenable para GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    // Escucha los cambios en el stream y notifica a GoRouter para que se refresque.
    _subscription =
        stream.asBroadcastStream().listen((dynamic _) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
