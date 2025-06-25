// lib/ui/screens/main_shell_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// --- DEFINICIÓN DEL WIDGET ---
// MainShellScreen es la "cáscara" o "plantilla" principal de la aplicación.
class MainShellScreen extends StatelessWidget {
  /// El widget 'child' es la pantalla actual que GoRouter inyecta aquí.
  /// Puede ser DashboardScreen, ProfileScreen, etc., dependiendo de la ruta.
  final Widget child;

  const MainShellScreen({
    super.key,
    required this.child,
  });

  /// Método privado para determinar qué ítem de la barra de navegación resaltar.
  
  int _getSelectedIndex(BuildContext context) {
    // Obtenemos la ruta actual usando GoRouterState. Es la forma moderna y limpia.
    final String location = GoRouterState.of(context).uri.toString();

    // Comprobamos con qué ruta empieza la ubicación actual.
    if (location.startsWith('/dashboard')) {
      return 0; // Índice 0 es 'Inicio'
    }
    if (location.startsWith('/add-reminder')) {
      return 1; // Índice 1 es 'Nuevo'
    }
    if (location.startsWith('/profile')) {
      return 2; // Índice 2 es 'Perfil'
    }
    // Caso por defecto: si estamos en una pantalla que no está en la barra
    // (ej. /reminders/detail/123), dejamos resaltado 'Inicio'.
    return 0;
  }

  /// Método privado que se ejecuta cuando el usuario toca un ítem de la barra.
  void _onItemTapped(int index, BuildContext context) {
    // Usamos una declaración 'switch' que es ideal para manejar casos basados en un índice.
    switch (index) {
      case 0: // Si el usuario toca el ítem en el índice 0...
        context.go('/dashboard'); // ...navegamos a la ruta '/dashboard'.
        break;
      case 1:
        context.go('/add-reminder');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El cuerpo del Scaffold es simplemente el widget 'child' que nos pasa GoRouter.
      body: child,

      // La barra de navegación persistente en la parte inferior.
      bottomNavigationBar: BottomNavigationBar(
        // La lista de ítems (botones/pestañas) que se mostrarán en la barra.
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), // Ícono normal
            activeIcon: Icon(Icons.home), // Ícono cuando la pestaña está activa
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Nuevo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        // 'currentIndex' le dice a la barra qué ítem debe resaltar.
        // Llamamos a nuestro método ayudante para que lo calcule por nosotros.
        currentIndex: _getSelectedIndex(context),

        // 'onTap' es la función que se ejecuta cuando el usuario toca un ítem.
        // Recibe el 'index' del ítem que fue presionado.
        onTap: (index) => _onItemTapped(index, context),
      ),
    );
  }
}
