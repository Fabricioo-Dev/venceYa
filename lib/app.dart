// lib/app.dart

// Importaciones necesarias de Flutter y de nuestros propios archivos.
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
    // La necesitamos para pasarla a nuestro AppRouter, que la usará para
    // decidir si el usuario debe ver la pantalla de login o el dashboard (redirección).
    // 'listen: false' es una optimización: le decimos que este widget no necesita
    // reconstruirse si el estado de autenticación cambia. El router ya escucha esos cambios.
    final authService = Provider.of<AuthService>(context, listen: false);

    // Creamos una instancia de nuestro manejador de rutas, pasándole el servicio de autenticación.
    final appRouter = AppRouter(authService);

    // MaterialApp.router es el widget base para toda la aplicación cuando se usa GoRouter.
    // Le da a la app la apariencia y comportamiento de Material Design y se conecta a nuestro sistema de rutas.
    return MaterialApp.router(
      // --- CONFIGURACIÓN GENERAL DE LA APP ---
      title:
          'VenceYa', // El título de la app, usado por el sistema operativo (ej. en la lista de apps recientes).

      // Aplica el tema de diseño (colores, fuentes, estilos de botones) definido en 'core/theme.dart'.
      // Esto le da a toda la app un aspecto visual consistente.
      theme: AppTheme.lightTheme,

      // Oculta la molesta cinta roja de "DEBUG" que aparece en la esquina superior derecha durante el desarrollo.
      debugShowCheckedModeBanner: false,

      // --- CONFIGURACIÓN DE RUTAS (NAVEGACIÓN) ---
      // Aquí conectamos nuestro sistema de navegación (GoRouter) a la aplicación.
      // Toda la lógica de qué pantalla mostrar y cómo navegar está dentro de 'appRouter.router'.
      routerConfig: appRouter.router,

      // --- CONFIGURACIÓN DE IDIOMA (LOCALIZACIÓN) ---
      // Esta sección configura la app para que entienda y muestre texto en español.

      // 'localizationsDelegates' son como "traductores" que le enseñan a Flutter
      // el significado de los textos de los widgets nativos en diferentes idiomas.
      localizationsDelegates: const [
        // Traduce los textos de los widgets de Material (ej. "Aceptar", "Cancelar" en un diálogo).
        GlobalMaterialLocalizations.delegate,
        // Traduce la dirección del texto (de izquierda a derecha para el español).
        GlobalWidgetsLocalizations.delegate,
        // Traduce los textos de los widgets de estilo iOS (Cupertino).
        GlobalCupertinoLocalizations.delegate,
      ],
      // 'supportedLocales' le dice a la app qué idiomas soporta. En este caso,
      // especificamos español para España (ES) y Argentina (AR).
      // Esto es importante para que DateFormat y otros paquetes funcionen correctamente.
      supportedLocales: const [
        Locale('es', 'AR'), // Priorizamos Español de Argentina
        Locale('es', 'ES'),
        Locale('es'), // Español genérico como fallback
      ],
    );
  }
}
