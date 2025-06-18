// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Importa las opciones de Firebase generadas por FlutterFire CLI
import 'package:venceya/firebase_options.dart'; // <<-- ¡IMPORTANTE! Nombre del paquete es 'venceya'

// Importa nuestros servicios y modelos
import 'package:venceya/services/auth_service.dart'; // <<-- ¡IMPORTANTE! Nombre del paquete es 'venceya'
import 'package:venceya/services/firestore_service.dart'; // <<-- ¡IMPORTANTE! Nombre del paquete es 'venceya'
import 'package:venceya/services/local_notification_service.dart'; // <<-- ¡IMPORTANTE! Nombre del paquete es 'venceya'
// <<-- ¡IMPORTANTE! Nombre del paquete es 'venceya'
// <<-- ¡IMPORTANTE! Nombre del paquete es 'venceya'
import 'package:venceya/app.dart'; // <<-- ¡IMPORTANTE! Nombre del paquete es 'venceya'
import 'package:intl/date_symbol_data_local.dart';

// Este manejador DEBE ser una función de nivel superior (fuera de cualquier clase)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("Handling a background message: ${message.messageId}");
  print("Título: ${message.notification?.title}");
  print("Cuerpo: ${message.notification?.body}");
  print("Data: ${message.data}");

  if (message.data.containsKey('reminderId')) {
    final localNotificationService = LocalNotificationService();
    await localNotificationService.init();
    final int notificationId = message.data['reminderId'].hashCode;
    localNotificationService.scheduleNotification(
      id: notificationId,
      title: message.notification?.title ?? 'Recordatorio VenceYa',
      body: message.notification?.body ?? 'Tienes un vencimiento pendiente.',
      scheduledDate: DateTime.now().add(const Duration(seconds: 1)),
      payload: message.data['reminderId'],
    );
    print("Notificación local disparada desde FCM en background.");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null); 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final authService = AuthService(FirebaseAuth.instance, GoogleSignIn());
  final firestoreService = FirestoreService();
  final localNotificationService = LocalNotificationService();

  await localNotificationService.init();
  FirebaseMessaging.instance.requestPermission();

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
