// lib/services/local_notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart'; // Para BuildContext en onNotificationTap

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );

    // <<-- ¡NUEVA LÓGICA PARA PERMISOS DE ANDROID 12+! -->>
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Solicitar permiso para alarmas exactas (Android 12+)
      final bool? granted =
          await androidImplementation.requestExactAlarmsPermission();
      if (granted == true) {
        print("Permiso de alarmas exactas concedido.");
      } else {
        print(
            "Permiso de alarmas exactas denegado. Las notificaciones podrían no ser exactas.");
      }
      // Solicitar permiso para mostrar notificaciones (Android 13+)
      final bool? notificationGranted =
          await androidImplementation.requestNotificationsPermission();
      if (notificationGranted == true) {
        print("Permiso de notificaciones concedido.");
      } else {
        print("Permiso de notificaciones denegado.");
      }
    }
  }

  // Este método 'onDidReceiveLocalNotification' se vuelve obsoleto o no se usará
  // si solo inicializamos para Android. Lo podemos dejar comentado o eliminar si quieres.
  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    print(
        'onDidReceiveLocalNotification (deprecated for new plugin versions): id $id, title $title, payload $payload');
  }

  static void onNotificationTap(NotificationResponse notificationResponse) {
    print('Notificación tocada:');
    print('id: ${notificationResponse.id}');
    print('actionId: ${notificationResponse.actionId}');
    print('input: ${notificationResponse.input}');
    print('payload: ${notificationResponse.payload}');
    // Aquí se manejaría la navegación al detalle del recordatorio.
    // Si el payload es el ID del recordatorio, podrías hacer:
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
      print("No se puede programar una notificación para una fecha pasada.");
      return;
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'venceya_channel_id',
          'Vencimientos',
          channelDescription: 'Notificaciones para recordatorios de VenceYa',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // Para mayor precisión
      payload: payload,
    );
    print(
        "Notificación programada para $title a las $scheduledDate con id $id");
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    print("Notificación cancelada con id $id");
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print("Todas las notificaciones canceladas");
  }
}
