// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Importaciones de los archivos de nuestro proyecto.
import 'package:venceya/firebase_options.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/services/local_notification_service.dart';
import 'package:venceya/app.dart';

/// La función `main`
void main() async {
  // --- SECUENCIA DE INICIALIZACIÓN ---
  // 1. `WidgetsFlutterBinding.ensureInitialized()`: Asegura que Flutter
  //    esté listo para usar antes de ejecutar cualquier otra cosa.
  WidgetsFlutterBinding.ensureInitialized();
  // 2. `initializeDateFormatting('es_AR', null)`: Carga los datos de localización para español.
  await initializeDateFormatting('es_AR', null);

  // 3. `Firebase.initializeApp(...)`: Inicializa la conexión con tu proyecto de Firebase
  //    en la nube, usando las credenciales del archivo `firebase_options.dart`.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // --- CREACIÓN DE SERVICIOS (SINGLETONS) ---
  // Creamos una única instancia de cada uno de nuestros servicios.
  // Estas instancias se compartirán en toda la aplicación gracias a Provider.
  final authService = AuthService();
  final firestoreService = FirestoreService();
  final localNotificationService = LocalNotificationService();

  // --- INICIALIZACIÓN DE SERVICIOS ADICIONALES ---
  await localNotificationService.init();

  // --- EJECUCIÓN DE LA APLICACIÓN ---
  // `runApp` es la función de Flutter que "infla" el widget principal y lo dibuja en pantalla.
  runApp(
    MultiProvider(
      providers: [
        // Proveemos la instancia de AuthService. ChangeNotifierProvider
        ChangeNotifierProvider<AuthService>(create: (_) => authService),
        // Proveemos la instancia de FirestoreService.
        Provider<FirestoreService>(create: (_) => firestoreService),
        // Proveemos la instancia de LocalNotificationService.
        Provider<LocalNotificationService>(
            create: (_) => localNotificationService),
      ],
      // `VenceYaApp` es el widget raíz.
      child: const VenceYaApp(),
    ),
  );
}
