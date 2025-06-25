// lib/services/local_notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

// --- CONSTANTES DE NOTIFICACIÓN ---
const String androidNotificationChannelId = 'venceya_channel_id';
const String androidNotificationChannelName = 'Vencimientos';
const String androidNotificationChannelDescription =
    'Notificaciones para recordatorios de VenceYa';

/// Servicio que encapsula la lógica de las notificaciones locales para Android.
/// Su única responsabilidad es inicializarse, programar y cancelar alertas.
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el servicio de notificaciones.
  Future<void> init() async {
    // Inicializa los datos de zonas horarias para que las fechas programadas sean correctas.
    tz.initializeTimeZones();

    // Define la configuración de inicialización solo para Android.
    // '@mipmap/ic_launcher' es el ícono pequeño que aparece en la barra de estado.
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // Inicializa el plugin.
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // Define qué función se llama cuando el usuario toca la notificación.
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );

    // Pide los permisos necesarios para Android.
    await _requestAndroidPermissions();
  }

  /// Solicita los permisos necesarios en versiones modernas de Android.
  Future<void> _requestAndroidPermissions() async {
    final androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Permiso para MOSTRAR notificaciones (Android 13+).
      await androidImplementation.requestNotificationsPermission();
      // Permiso para ALARMAS EXACTAS, crucial para una app de vencimientos (Android 12+).
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  /// Manejador que se ejecuta cuando el usuario toca una notificación.
  @pragma('vm:entry-point')
  static void onNotificationTap(NotificationResponse notificationResponse) {
    if (kDebugMode) {
      print('Notificación tocada con payload: ${notificationResponse.payload}');
    }
    // A futuro, aquí se podría usar el payload (ID del recordatorio)
    // para navegar a la pantalla de detalle correspondiente.
  }

  /// Programa una notificación para una fecha y hora específicas.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // No se puede programar una notificación para el pasado.
    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    // Define los detalles de la notificación para Android de forma simple.
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      androidNotificationChannelId, // Usamos la constante con el nuevo nombre.
      androidNotificationChannelName, // Usamos la constante con el nuevo nombre.
      channelDescription: androidNotificationChannelDescription,
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // Programa la notificación para que se dispare en la zona horaria local del dispositivo.
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );

    if (kDebugMode) {
      print(
          "Notificación simple programada para '$title' a las $scheduledDate");
    }
  }

  /// Cancela una notificación específica usando su ID.
  /// Se usa cuando un recordatorio se edita (y se desactiva la notif.) o se elimina.
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    if (kDebugMode) print("Notificación cancelada con id: $id");
  }
}
