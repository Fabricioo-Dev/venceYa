// lib/services/local_notification_service.dart
import 'package:flutter/material.dart'; // Necesario si usas BuildContext en onNotificationTap
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart'
    as tz; // Cambio a latest_all para más compatibilidad
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart'; // Para kDebugMode

class LocalNotificationService {
  // Asegúrate de que FlutterLocalNotificationsPlugin esté correctamente escrito aquí (con 's')
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin(); // <<-- ¡CORREGIDO! Faltaba una 's'

  Future<void> init() async {
    tz.initializeTimeZones(); // <<-- ¡CORREGIDO! Era initializeTimeTimes

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      // onDidReceiveLocalNotification: onDidReceiveLocalNotification, // Esta línea no es necesaria si solo usas Android o versiones modernas
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS:
          initializationSettingsDarwin, // Mantener iOS para compatibilidad del plugin si no es solo Android
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );

    // SOLICITAR PERMISOS DE NOTIFICACIÓN (para Android 13+)
    // y para alarmas exactas (Android 12+)
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Solicitar permiso para mostrar notificaciones (Android 13+)
      final bool? grantedNotificationPermission = await androidImplementation
          .requestNotificationsPermission(); // <<-- Método correcto
      if (grantedNotificationPermission == true) {
        if (kDebugMode) print("Permiso de notificaciones concedido.");
      } else {
        if (kDebugMode) print("Permiso de notificaciones denegado.");
      }

      // Solicitar permiso para alarmas exactas (Android 12/S y superior)
      final bool? grantedExactAlarmPermission = await androidImplementation
          .requestExactAlarmsPermission(); // <<-- Método correcto
      if (grantedExactAlarmPermission == true) {
        if (kDebugMode) print("Permiso de alarmas exactas concedido.");
      } else {
        if (kDebugMode)
          print(
              "Permiso de alarmas exactas denegado. Las notificaciones podrían no ser exactas.");
      }
    }
  }

  // Este método onDidReceiveLocalNotification se usa para iOS < 10, pero se deja por completitud
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    if (kDebugMode)
      print(
          'onDidReceiveLocalNotification: id $id, title $title, payload $payload');
  }

  static void onNotificationTap(NotificationResponse notificationResponse) {
    if (kDebugMode) {
      print('Notificación tocada:');
      print('id: ${notificationResponse.id}');
      print('payload: ${notificationResponse.payload}');
    }
    // Aquí se manejaría la navegación al detalle del recordatorio.
    // GoRouter.of(context).goNamed('reminderDetail', pathParameters: {'id': notificationResponse.payload!});
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) {
      if (kDebugMode)
        print("No se puede programar una notificación para una fecha pasada.");
      return;
    }

    final tz.TZDateTime scheduledTzDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'venceya_channel_id',
          'Vencimientos',
          channelDescription: 'Notificaciones para recordatorios de VenceYa',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
        iOS:
            DarwinNotificationDetails(), // Mantener para compatibilidad del plugin si no es solo Android
      ),
      androidScheduleMode: AndroidScheduleMode
          .exactAllowWhileIdle, // Para  // Reintroducido, es útil
      payload: payload,
    );
    if (kDebugMode)
      print(
          "Notificación programada para $title a las $scheduledDate con id $id");
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    if (kDebugMode) print("Notificación cancelada con id $id");
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    if (kDebugMode) print("Todas las notificaciones canceladas");
  }
}
