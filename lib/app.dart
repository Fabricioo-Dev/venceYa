// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Importaciones del proyecto.
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/app_router.dart';
import 'package:venceya/core/theme.dart';

/// VenceYaApp es el widget raíz de la aplicación.
///
/// Es `StatelessWidget` porque su configuración (tema, rutas, etc.)
/// no cambia durante el tiempo de vida de la app.
class VenceYaApp extends StatelessWidget {
  const VenceYaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Se obtiene el servicio de autenticación para pasarlo al router.
    // `listen: false` es una optimización, ya que este widget no necesita
    // redibujarse si `AuthService` notifica cambios.
    final authService = Provider.of<AuthService>(context, listen: false);

    // Se instancia el router, que necesita saber sobre el estado de auth
    // para decidir a qué pantalla redirigir al usuario.
    final appRouter = AppRouter(authService);

    // MaterialApp.router es el widget principal que configura la app
    // para usar un sistema de navegación declarativo como GoRouter.
    return MaterialApp.router(
      // --- Configuración General ---
      title: 'VenceYa',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,

      // --- Configuración de Navegación ---
      // Conecta GoRouter a la aplicación para manejar todas las rutas.
      routerConfig: appRouter.router,

      // --- Configuración de Idioma (Localización) ---
      // Provee las traducciones para los widgets estándar de Flutter.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Define los idiomas que la app soporta.
      // 'es' es suficiente para cubrir variantes como 'es_AR' o 'es_ES'
      // para los textos de los widgets por defecto. El formato específico de
      // fechas se controla con `initializeDateFormatting` en main.dart.
      supportedLocales: const [
        Locale('es'),
      ],
    );
  }
}
