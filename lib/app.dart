// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/app_router.dart';
import 'package:venceya/core/theme.dart'; // Importa el tema global de la aplicación

class VenceYaApp extends StatelessWidget {
  const VenceYaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final appRouter = AppRouter(authService);

    return MaterialApp.router(
      title: 'VenceYa',
      theme: AppTheme.lightTheme, // Aplicamos nuestro tema claro personalizado
      routerConfig: appRouter.router,
      debugShowCheckedModeBanner:
          false, // Oculta la etiqueta "DEBUG" en la esquina
    );
  }
}
