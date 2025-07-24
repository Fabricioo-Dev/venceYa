// lib/main.dart
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Importaciones del proyecto.
import 'package:venceya/firebase_options.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/services/local_notification_service.dart';
import 'package:venceya/app.dart';

/// Punto de entrada de la aplicación. Es `async` para poder usar `await`.
void main() async {
  // --- SECUENCIA DE INICIALIZACIÓN ---

  // 1. Asegura que Flutter esté inicializado antes de usar los plugins.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Habilita el formato de fechas para español (Argentina).
  await initializeDateFormatting('es_AR', null);

  // 3. Conecta la app con el proyecto de Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- CREACIÓN DE SERVICIOS ---
  // Se crean instancias únicas (singletons) de los servicios.
  final authService = AuthService();
  final firestoreService = FirestoreService();
  final localNotificationService = LocalNotificationService();

  // Prepara el servicio de notificaciones para su uso.
  await localNotificationService.init();

  // --- EJECUCIÓN DE LA APP ---
  // Dibuja el widget principal en la pantalla.
  runApp(
    // Permite proveer múltiples servicios al árbol de widgets.
    MultiProvider(
      providers: [
        // Notifica a los widgets cuando hay cambios en la autenticación.
        Provider<AuthService>(create: (_) => authService),

        // Provee una instancia de FirestoreService, sin notificar cambios.
        Provider<FirestoreService>(create: (_) => firestoreService),

        // Provee una instancia del servicio de notificaciones.
        Provider<LocalNotificationService>(
            create: (_) => localNotificationService),
      ],
      // El widget raíz de la aplicación.
      child: const VenceYaApp(),
    ),
  );
}
