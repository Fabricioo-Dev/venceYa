// lib/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:venceya/ui/screens/splash_screen.dart';
import 'package:venceya/ui/screens/login_screen.dart';
import 'package:venceya/ui/screens/signup_screen.dart';
import 'package:venceya/ui/screens/reset_password_screen.dart';
import 'package:venceya/services/auth_service.dart';
import 'dart:async';

// Importaciones de todas las pantallas
import 'package:venceya/ui/screens/dashboard_screen.dart';
import 'package:venceya/ui/screens/add_edit_reminder_screen.dart';
import 'package:venceya/ui/screens/reminder_detail_screen.dart';
import 'package:venceya/ui/screens/profile_screen.dart';
import 'package:venceya/ui/screens/main_shell_screen.dart';

class AppRouter {
  final AuthService authService;

  AppRouter(this.authService);

  late final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (BuildContext context, GoRouterState state) {
          return const SignUpScreen();
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'resetPassword',
        builder: (BuildContext context, GoRouterState state) {
          return const ResetPasswordScreen();
        },
      ),
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return MainShellScreen(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (BuildContext context, GoRouterState state) {
              return const DashboardScreen();
            },
          ),
          GoRoute(
            path: '/add-reminder',
            name: 'addReminder',
            builder: (BuildContext context, GoRouterState state) {
              return const AddEditReminderScreen();
            },
          ),
          GoRoute(
            path: '/edit-reminder/:id',
            name: 'editReminder',
            builder: (BuildContext context, GoRouterState state) {
              final reminderId = state.pathParameters['id']!;
              return AddEditReminderScreen(reminderId: reminderId);
            },
          ),
          GoRoute(
            path: '/reminder-detail/:id',
            name: 'reminderDetail',
            builder: (BuildContext context, GoRouterState state) {
              final reminderId = state.pathParameters['id']!;
              return ReminderDetailScreen(reminderId: reminderId);
            },
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (BuildContext context, GoRouterState state) {
              return const ProfileScreen();
            },
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authService.getCurrentUser() != null;
      final bool loggingIn = state.matchedLocation == '/login';
      final bool isSplash = state.matchedLocation == '/splash';
      final bool isSigningUp =
          state.matchedLocation == '/signup'; // Ruta de registro
      final bool isResettingPassword =
          state.matchedLocation == '/reset-password';

      // Define las rutas que no requieren autenticación (splash, login, signup, reset-password)
      final bool isAuthRelatedRoute =
          isSplash || loggingIn || isSigningUp || isResettingPassword;

      // Si NO está logueado Y NO está en una ruta de autenticación, redirige al login.
      if (!loggedIn && !isAuthRelatedRoute) {
        return '/login';
      }
      // Si SÍ está logueado Y está en una ruta de autenticación:
      if (loggedIn && isAuthRelatedRoute) {
        // <<-- ¡CAMBIO CLAVE AQUÍ! -->>
        // Si el usuario acaba de registrarse (y está en la pantalla de registro),
        // NO LO REDIRIJAS aún. Deja que la SignUpScreen muestre su diálogo y navegue a Login.
        if (isSigningUp) {
          return null; // No redirigir, dejar que SignUpScreen maneje la navegación
        }
        // Para otras rutas de autenticación (Login, Splash, Reset Password), si ya está logueado,
        // entonces sí, redirige al Dashboard.
        return '/dashboard';
      }

      return null; // No redirige en otros casos.
    },
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
