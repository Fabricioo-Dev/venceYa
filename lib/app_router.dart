// lib/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:venceya/ui/screens/splash_screen.dart';
import 'package:venceya/ui/screens/login_screen.dart';
import 'package:venceya/ui/screens/signup_screen.dart';
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
    debugLogDiagnostics: true, // Habilita logs para depuración de navegación

    routes: <RouteBase>[
      // Ruta para la Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      // Ruta para la pantalla de Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      // Ruta para la pantalla de registro
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (BuildContext context, GoRouterState state) {
          return const SignUpScreen();
        },
      ),

      // ShellRoute para la navegación inferior persistente
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return MainShellScreen(child: child);
        },
        routes: <GoRoute>[
          // Ruta para el Dashboard
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (BuildContext context, GoRouterState state) {
              return const DashboardScreen();
            },
          ),
          // Ruta para añadir un nuevo recordatorio
          GoRoute(
            path: '/add-reminder',
            name: 'addReminder',
            builder: (BuildContext context, GoRouterState state) {
              return const AddEditReminderScreen();
            },
          ),
          // Ruta para editar un recordatorio existente
          GoRoute(
            path: '/edit-reminder/:id',
            name: 'editReminder',
            builder: (BuildContext context, GoRouterState state) {
              final reminderId = state.pathParameters['id']!;
              return AddEditReminderScreen(reminderId: reminderId);
            },
          ),
          // Ruta para ver detalles de un recordatorio
          GoRoute(
            path: '/reminder-detail/:id',
            name: 'reminderDetail',
            builder: (BuildContext context, GoRouterState state) {
              final reminderId = state.pathParameters['id']!;
              return ReminderDetailScreen(reminderId: reminderId);
            },
          ),
          // Ruta para la pantalla de perfil
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

    // Lógica de redirección de la aplicación.
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authService.getCurrentUser() != null;
      final bool loggingIn = state.matchedLocation == '/login';
      final bool isSplash = state.matchedLocation == '/splash';
      final bool isSigningUp = state.matchedLocation == '/signup';
      // Se elimina la variable isResettingPassword

      // Define las rutas que no requieren autenticación (splash, login, signup)
      final bool isAuthRelatedRoute = isSplash || loggingIn || isSigningUp;

      // Si NO está logueado Y NO está en una ruta de autenticación, redirige al login.
      if (!loggedIn && !isAuthRelatedRoute) {
        return '/login';
      }
      // Si SÍ está logueado Y está en una ruta de autenticación:
      if (loggedIn && isAuthRelatedRoute) {
        if (isSigningUp) {
          return null; // Deja que SignUpScreen maneje la navegación
        }
        return '/dashboard'; // Redirige al Dashboard
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
