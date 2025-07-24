// lib/services/local_notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio que encapsula toda la lógica de las notificaciones locales.
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa las configuraciones básicas del plugin de notificaciones.
  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuraciones para iOS. `requestAlertPermission`, etc., se establecen
    // en `true` para solicitar los permisos necesarios al iniciar.
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  /// Solicita permisos al usuario en Android (versiones 13+).
  Future<bool> requestPermissions() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool? permissionGranted =
          await androidImplementation.requestNotificationsPermission();
      return permissionGranted ?? false;
    }
    // En iOS, los permisos se solicitan en `init`, por lo que aquí devolvemos `true`.
    return true;
  }

  /// Programa una notificación para una fecha y hora específicas.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'venceya_channel_id',
      'Vencimientos',
      channelDescription: 'Notificaciones para recordatorios de VenceYa',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      // --- CORRECCIÓN AQUÍ ---
      // El parámetro `uiLocalNotificationDateInterpretation` fue eliminado en
      // versiones más recientes del paquete para Android y se maneja
      // de forma diferente en iOS (generalmente a través de `init`).
      // Solo necesitamos especificar el modo de Android para asegurar que.
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Cancela una notificación programada usando su ID.
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
