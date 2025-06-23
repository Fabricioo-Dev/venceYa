// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';

// Importaciones de los archivos de nuestro proyecto.
import 'package:venceya/firebase_options.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/services/local_notification_service.dart';
import 'package:venceya/app.dart';

/// Manejador para mensajes de notificaciones push (FCM) recibidos cuando la app está en segundo plano o cerrada.
/// La etiqueta `@pragma('vm:entry-point')` es crucial para asegurar que este código
/// pueda ser ejecutado por el sistema incluso si la app principal no está corriendo.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Se debe inicializar Firebase aquí también para que los servicios de Firebase funcionen en segundo plano.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
  // NOTA: Esta es una implementación básica. Aquí se podría añadir lógica para
  // mostrar una notificación local si la push no fuera visible.
}

/// La función `main` es el punto de entrada de toda aplicación en Dart y Flutter.
void main() async {
  // --- SECUENCIA DE INICIALIZACIÓN ---
  // Es crucial que esta secuencia se ejecute en el orden correcto.

  // 1. `WidgetsFlutterBinding.ensureInitialized()`: Asegura que el motor de Flutter
  //    esté listo para usar antes de ejecutar cualquier otra cosa, especialmente
  //    antes de los `await` que vienen a continuación.
  WidgetsFlutterBinding.ensureInitialized();

  // 2. `initializeDateFormatting('es', null)`: Carga los datos de localización para el español.
  //    Esto es necesario para que los formatos de fecha (ej. "Lunes, 23 de junio") funcionen correctamente.
  await initializeDateFormatting('es_AR', null);

  // 3. `Firebase.initializeApp(...)`: Inicializa la conexión con tu proyecto de Firebase
  //    en la nube, usando las credenciales del archivo `firebase_options.dart`.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 4. `FirebaseMessaging.onBackgroundMessage(...)`: Configura la función que se ejecutará
  //    cuando se reciba una notificación push y la app no esté en primer plano.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // --- CREACIÓN DE SERVICIOS (SINGLETONS) ---
  // Creamos una única instancia de cada uno de nuestros servicios.
  // Estas instancias se compartirán en toda la aplicación gracias a Provider.

  // --- ¡AQUÍ ESTABA EL ERROR! ---
  // El constructor de `AuthService` ya no recibe parámetros, porque él mismo
  // se encarga de crear las instancias de FirebaseAuth y GoogleSignIn.
  final authService = AuthService();
  final firestoreService = FirestoreService();
  final localNotificationService = LocalNotificationService();

  // --- INICIALIZACIÓN DE SERVICIOS ADICIONALES ---

  // Inicializa el servicio de notificaciones locales (configura canales, pide permisos).
  await localNotificationService.init();

  // Pide permisos para recibir notificaciones push en iOS y versiones modernas de Android.
  await FirebaseMessaging.instance.requestPermission();

  // --- EJECUCIÓN DE LA APLICACIÓN ---
  // `runApp` es la función de Flutter que "infla" el widget principal y lo dibuja en pantalla.
  runApp(
    // `MultiProvider` es un widget que nos permite "inyectar" nuestros servicios
    // en el árbol de widgets. Esto hace que cualquier widget hijo pueda acceder
    // a las instancias de `authService`, `firestoreService`, etc., de forma sencilla y eficiente.
    MultiProvider(
      providers: [
        // Proveemos la instancia de AuthService a toda la app.
        // `ChangeNotifierProvider` es especial porque permite a los widgets "escuchar" cambios.
        ChangeNotifierProvider<AuthService>(create: (_) => authService),

        // Proveemos la instancia de FirestoreService.
        Provider<FirestoreService>(create: (_) => firestoreService),

        // Proveemos la instancia de LocalNotificationService.
        Provider<LocalNotificationService>(
            create: (_) => localNotificationService),
      ],
      // `VenceYaApp` es el widget raíz de nuestra aplicación.
      child: const VenceYaApp(),
    ),
  );
}
