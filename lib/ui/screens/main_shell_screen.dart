// lib/ui/screens/main_shell_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:venceya/core/theme.dart'; // Para colores del tema

class MainShellScreen extends StatelessWidget {
  final Widget
      child; // El widget 'child' es la pantalla actual dentro del ShellRoute

  const MainShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Obtener la ruta actual para saber qué ítem de la barra de navegación resaltar
    final String location =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.toString();

    // Determina el índice de la pestaña activa basado en la ruta actual
    int getSelectedIndex(String location) {
      if (location.startsWith('/dashboard')) {
        return 0; // 'Inicio'
      }
      if (location.startsWith('/add-reminder')) {
        return 1; // 'Nuevo'
      }
      if (location.startsWith('/profile')) {
        return 2; // 'Perfil'
      }
      // Si hay otras rutas no manejadas por la barra (ej. detalle, editar),
      // puedes devolver un índice que no se resalte o manejar un default.
      return 0; // Por defecto a Inicio
    }

    int selectedIndex = getSelectedIndex(location);

    return Scaffold(
      body:
          child, // Aquí se mostrará la pantalla hija actual del ShellRoute (Dashboard, Add, Profile)
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Nuevo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
          // Eliminamos el ítem "Archivo" como solicitaste
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.archive_outlined),
          //   label: 'Archivo',
          // ),
        ],
        currentIndex: selectedIndex, // Resalta el ítem basado en la ruta actual
        onTap: (index) {
          // Navegación dentro del ShellRoute
          if (index == 0) {
            // Inicio -> Dashboard
            context.go(
                '/dashboard'); // Usamos go para ir a la ruta principal del Dashboard
          } else if (index == 1) {
            // Nuevo -> Añadir Recordatorio
            context
                .go('/add-reminder'); // Usamos go para ir a la ruta de añadir
          } else if (index == 2) {
            // Perfil -> Pantalla de Perfil
            context.go('/profile'); // Usamos go para ir a la ruta de perfil
          }
          // El ítem "Archivo" ha sido eliminado
        },
      ),
    );
  }
}
