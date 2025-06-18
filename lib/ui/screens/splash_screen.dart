// lib/ui/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate(); // Inicia el proceso de verificación y navegación al cargar la pantalla.
  }

  /// Verifica el estado de autenticación del usuario y navega a la pantalla correspondiente.
  /// Espera un tiempo definido para mostrar el logo y el indicador de carga.
  Future<void> _checkAuthAndNavigate() async {
    // Espera un breve tiempo para mostrar el logo (3 segundos). Ajusta si es necesario.
    await Future.delayed(const Duration(seconds: 3));

    // Asegúrate de que el widget sigue montado en el árbol antes de intentar navegar.
    if (!mounted) return;

    // Obtiene una instancia del AuthService sin escuchar cambios (listen: false)
    // porque solo necesitamos el estado actual para la decisión de navegación.
    final authService = Provider.of<AuthService>(context, listen: false);

    // Si hay un usuario actualmente autenticado, navega al dashboard.
    if (authService.getCurrentUser() != null) {
      context.go('/dashboard');
    } else {
      // Si no hay un usuario autenticado, navega a la pantalla de login.
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usamos el color primaryBlue definido en AppTheme para consistencia.
    // Ya no usamos 'const Color primaryBlue = Color(0xFF3F51B5);' directamente aquí.

    return Scaffold(
      backgroundColor: AppTheme.primaryBlue, // <--- ¡Usamos el color del tema!
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centra los elementos verticalmente.
          children: <Widget>[
            // Muestra el logo de VenceYa. La imagen PNG ya incluye el reloj, calendario y texto.
            Image.asset(
              'assets/venceya_logo.png', // Ruta del asset del logo.
              width: 300, // Ancho deseado para el logo.
              height:
                  300, // Alto deseado para el logo. Ajusta según sea necesario.
            ),
            const SizedBox(
                height:
                    50), // Espacio vertical entre el logo y el indicador de carga.
            const CircularProgressIndicator(
              // Muestra un indicador de carga.
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white), // Color del indicador blanco.
            ),
          ],
        ),
      ),
    );
  }
}
