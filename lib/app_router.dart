// lib/app_router.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:venceya/services/auth_service.dart';

// Importaciones de todas las pantallas
import 'package:venceya/ui/screens/splash_screen.dart';
import 'package:venceya/ui/screens/login_screen.dart';
import 'package:venceya/ui/screens/signup_screen.dart';
import 'package:venceya/ui/screens/main_shell_screen.dart';
import 'package:venceya/ui/screens/dashboard_screen.dart';
import 'package:venceya/ui/screens/add_edit_reminder_screen.dart';
import 'package:venceya/ui/screens/reminder_detail_screen.dart';
import 'package:venceya/ui/screens/profile_screen.dart';

/// Bloque Principal: `AppRouter`.
///
/// Centraliza toda la configuración de navegación. Actúa como el mapa y el
/// guardia de seguridad de la aplicación.
class AppRouter {
  final AuthService authService;
  AppRouter(this.authService);

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authService.authStateChanges),

    // --- CORRECCIÓN #1: RUTA INICIAL ---
    // Se establece explícitamente que la app SIEMPRE debe empezar en '/splash'.
    // Esto asegura que el SplashScreen tenga la oportunidad de mostrarse.
    initialLocation: '/splash',

    routes: <RouteBase>[
      // --- Rutas Públicas ---
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      // --- Rutas Privadas (Protegidas) ---
      // Se agrupan bajo un `ShellRoute` para mantener la barra de navegación.
      ShellRoute(
        builder: (context, state, child) => MainShellScreen(child: child),
        routes: <GoRoute>[
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/add-reminder',
            name: 'addReminder',
            builder: (context, state) => const AddEditReminderScreen(),
          ),
          GoRoute(
            path: '/edit-reminder/:id',
            name: 'editReminder',
            builder: (context, state) {
              final reminderId = state.pathParameters['id'];
              return AddEditReminderScreen(reminderId: reminderId);
            },
          ),
          GoRoute(
            path: '/reminder-detail/:id',
            name: 'reminderDetail',
            builder: (context, state) {
              final reminderId = state.pathParameters['id']!;
              return ReminderDetailScreen(reminderId: reminderId);
            },
          ),
        ],
      ),
    ],

    /// Bloque de Lógica de Redirección.
    ///
    /// Este "guardia" se ejecuta antes de cada navegación. Su lógica ahora
    /// es más simple: protege las rutas privadas pero deja pasar al splash.
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = authService.currentUser != null;
      final String location = state.matchedLocation;

      // Condición 1: Si estamos yendo al splash, lo permitimos sin importar qué.
      // Esto asegura que la pantalla se muestre.
      if (location == '/splash') {
        return null; // `null` significa "proceder con la navegación".
      }

      // Condición 2: Si el usuario NO está logueado y NO va a una ruta de
      // autenticación, lo redirigimos al login.
      final isAuthRoute = location == '/login' || location == '/signup';
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // Condición 3: Si el usuario SÍ está logueado y por alguna razón intenta
      // volver a la pantalla de login/signup, lo llevamos al dashboard.
      if (isLoggedIn && isAuthRoute) {
        return '/dashboard';
      }

      // Si ninguna de las condiciones de redirección se cumple, se permite el paso.
      return null;
    },
  );
}

/// Bloque de Utilidad: `GoRouterRefreshStream`.
///
/// Un adaptador que convierte el `Stream` de autenticación de Firebase en un
/// `Listenable`, que es lo que `GoRouter` necesita para reaccionar a los cambios.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
