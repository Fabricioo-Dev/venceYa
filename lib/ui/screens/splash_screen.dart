// lib/ui/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:venceya/core/theme.dart';
import 'package:venceya/services/auth_service.dart';

/// Bloque Principal: `SplashScreen Widget`.
///
/// Es la pantalla de bienvenida que se muestra al iniciar la aplicación.
/// Ahora es un `StatefulWidget` porque necesita gestionar una lógica interna
/// que depende del tiempo (esperar unos segundos) y del estado de
/// autenticación para decidir a qué pantalla navegar.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// Bloque de Estado: `_SplashScreenState`.
///
/// Contiene la lógica para iniciar la navegación después de un breve retraso.
class _SplashScreenState extends State<SplashScreen> {
  /// Bloque de Ciclo de Vida: `initState`.
  ///
  /// Se ejecuta una sola vez cuando la pantalla se crea. Es el lugar ideal
  /// para iniciar procesos que solo deben correr una vez, como nuestro
  /// temporizador de navegación.
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  /// Bloque de Lógica de Navegación: `_checkAuthAndNavigate`.
  ///
  /// Esta función es el corazón de la pantalla. Espera 2 segundos para que
  /// el logo sea visible y luego, basándose en el estado de autenticación,
  /// redirige al usuario a la pantalla correcta.
  Future<void> _checkAuthAndNavigate() async {
    // Esperamos 2 segundos para que la pantalla de bienvenida sea visible.
    await Future.delayed(const Duration(seconds: 2));

    // `if (!mounted)` es una comprobación de seguridad crucial. Si el usuario
    // cierra la app durante esos 2 segundos, el widget ya no estará "montado"
    // y no debemos intentar usar su `context` para navegar, ya que causaría un error.
    if (!mounted) return;

    // Usamos `context.read` para obtener el servicio de autenticación.
    final authService = context.read<AuthService>();

    // Decidimos a dónde ir. `go` reemplaza la pila de navegación, lo cual
    // es correcto aquí para que el usuario no pueda "volver atrás" al splash.
    if (authService.currentUser != null) {
      // Si hay un usuario, vamos al dashboard.
      context.go('/dashboard');
    } else {
      // Si no hay usuario, vamos al login.
      context.go('/login');
    }
  }

  /// Bloque de Construcción de UI: `build`.
  ///
  /// Dibuja la interfaz visual de la pantalla. Es una estructura simple
  /// que centra los elementos en la pantalla.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/venceya_logo.png',
              width: 380,
            ),
            const SizedBox(height: 24),
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
