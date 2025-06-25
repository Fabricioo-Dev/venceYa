// lib/ui/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/core/theme.dart';

/// Pantalla de bienvenida que se muestra al iniciar la aplicación.
/// Su principal función es decidir a qué pantalla redirigir al usuario
/// basándose en su estado de autenticación.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// El método `initState` se ejecuta una sola vez cuando el widget se crea.
  /// Es el lugar ideal para iniciar procesos que solo deben correr una vez.
  @override
  void initState() {
    super.initState();
    // Inicia el proceso de verificación y navegación.
    _checkAuthAndNavigate();
  }

  /// Verifica si el usuario ya ha iniciado sesión y navega a la pantalla correcta.
  Future<void> _checkAuthAndNavigate() async {
    // Usamos `Future.delayed` para que la pantalla de bienvenida sea visible
    // por un tiempo determinado
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Usamos Provider para obtener acceso al AuthService de forma segura.
    final authService = Provider.of<AuthService>(context, listen: false);

    // Comprueba si hay un usuario logueado.
    if (authService.getCurrentUser() != null) {
      // Si hay un usuario, lo redirige al dashboard principal.
      context.go('/dashboard');
    } else {
      // Si no hay usuario, lo redirige a la pantalla de login.
      context.go('/login');
    }
  }

  /// Construye la interfaz de usuario de la pantalla de bienvenida.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppTheme.primaryBlue, // Fondo con el color principal de la app.
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centra los elementos verticalmente.
          children: <Widget>[
            // Muestra el logo de la aplicación desde la carpeta de assets.
            Image.asset(
              'assets/venceya_logo.png',
              width: 380,
            ),
            const SizedBox(height: 18),

            // Muestra un indicador de carga circular para dar feedback de que algo está pasando.
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
