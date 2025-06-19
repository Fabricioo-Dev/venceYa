// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';

import 'package:venceya/firebase_options.dart';
import 'package:venceya/services/auth_service.dart';
import 'package:venceya/services/firestore_service.dart';
import 'package:venceya/services/local_notification_service.dart';
import 'package:venceya/app.dart';

/// Manejador para mensajes de FCM en segundo plano.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Inicializa Firebase si no lo está.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Imprime detalles del mensaje para depuración.
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Data: ${message.data}");
  }

  // Programa una notificación local si el mensaje FCM contiene un ID de recordatorio.
  if (message.data.containsKey('reminderId')) {
    final localNotificationService = LocalNotificationService();
    await localNotificationService.init();
    final int notificationId = message.data['reminderId'].hashCode;
    localNotificationService.scheduleNotification(
      id: notificationId,
      title: message.notification?.title ?? 'VenceYa Reminder',
      body: message.notification?.body ?? 'A reminder is due!',
      scheduledDate: DateTime.now().add(const Duration(seconds: 1)),
      payload: message.data['reminderId'],
    );
    if (kDebugMode) print("Local notification triggered from FCM background.");
  }
}

void main() async {
  // Asegura que Flutter esté inicializado.
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa los datos de localización para español.
  await initializeDateFormatting('es', null);
  // Inicializa Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Configura el manejador de mensajes en segundo plano de FCM.
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Crea instancias de los servicios.
  final authService = AuthService(FirebaseAuth.instance, GoogleSignIn());
  final firestoreService = FirestoreService();
  final localNotificationService = LocalNotificationService();

  // Inicializa el servicio de notificaciones locales.
  await localNotificationService.init();
  // Solicita permisos de notificación a Firebase Messaging.
  FirebaseMessaging.instance.requestPermission();

  // Ejecuta la aplicación.
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => authService),
        Provider<FirestoreService>(create: (_) => firestoreService),
        Provider<LocalNotificationService>(
            create: (_) => localNotificationService),
      ],
      child: const VenceYaApp(),
    ),
  );
}
