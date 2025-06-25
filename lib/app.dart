// lib/app.dart

// Importaciones
import 'package:flutter/material.dart'; // El paquete base para construir la UI con Material Design.
import 'package:provider/provider.dart'; // Para acceder a nuestros servicios.
import 'package:flutter_localizations/flutter_localizations.dart'; // Para configurar el idioma de la app.

// Importaciones de nuestros archivos locales.
import 'package:venceya/services/auth_service.dart'; // Nuestro servicio de autenticación.
import 'package:venceya/app_router.dart'; // Nuestro archivo de configuración de rutas.
import 'package:venceya/core/theme.dart'; // Nuestro tema personalizado.

// --- DEFINICIÓN DEL WIDGET RAÍZ DE LA APLICACIÓN ---
// VenceYaApp es el widget principal, el punto de partida de toda la aplicación.
// Es un "Widget Estático" (StatelessWidget) porque su única función es configurar
// la aplicación (título, tema, rutas, idioma). No maneja ningún estado que cambie por sí mismo.
class VenceYaApp extends StatelessWidget {
  const VenceYaApp({super.key});

  // El método 'build' es el corazón de todo widget. Describe cómo se debe
  // construir la interfaz de usuario. Se ejecuta muy pocas veces en este widget raíz.
  @override
  Widget build(BuildContext context) {
    // Obtenemos una instancia de nuestro AuthService usando Provider.
    final authService = Provider.of<AuthService>(context, listen: false);

    // Creamos una instancia de nuestro manejador de rutas, pasándole el servicio de autenticación.
    final appRouter = AppRouter(authService);

    // MaterialApp.router es el widget base para toda la aplicación cuando se usa GoRouter.
    return MaterialApp.router(
      // --- CONFIGURACIÓN GENERAL DE LA APP ---
      title:
          'VenceYa', 
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      // --- CONFIGURACIÓN DE RUTAS (NAVEGACIÓN) ---
      // Aquí conectamos nuestro sistema de navegación (GoRouter) a la aplicación.
      
      routerConfig: appRouter.router,

      // --- CONFIGURACIÓN DE IDIOMA (LOCALIZACIÓN) ---
      localizationsDelegates: const [
        // Traduce los textos de los widgets de Material (
        GlobalMaterialLocalizations.delegate,
        // Traduce la dirección del texto (de izquierda a derecha para el español).
        GlobalWidgetsLocalizations.delegate,
        // Traduce los textos de los widgets de estilo iOS (Cupertino).
        GlobalCupertinoLocalizations.delegate,
      ],
      // 'supportedLocales' le dice a la app qué idiomas soporta.
      // Esto es importante para que DateFormat y otros paquetes funcionen correctamente.
      supportedLocales: const [
        Locale('es', 'AR'), 
        Locale('es', 'ES'),
        Locale('es'),
      ],
    );
  }
}
