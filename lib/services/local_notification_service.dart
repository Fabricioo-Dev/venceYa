// lib/services/local_notification_service.dart

// El plugin principal para manejar notificaciones locales en Flutter.
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Paquetes para manejar correctamente las zonas horarias. Esencial para que las
// notificaciones se disparen a la hora correcta en cualquier parte del mundo.
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
// Import para usar 'kDebugMode', que nos permite ejecutar código (como prints) solo en modo de depuración.
import 'package:flutter/foundation.dart';

/// Un servicio dedicado para encapsular toda la lógica de las notificaciones locales.
/// Abstraer esta lógica en una clase separada hace que el resto del código sea más limpio,
/// ya que las pantallas solo necesitan llamar a métodos simples como `scheduleNotification()`.
class LocalNotificationService {
  // La instancia del plugin que usaremos para todas las operaciones de notificación.
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inicializa el servicio de notificaciones. Debe ser llamado al arrancar la app.
  Future<void> init() async {
    // 1. Inicializa los datos de zonas horarias para que el paquete `timezone` funcione.
    tz.initializeTimeZones();

    // 2. Define las configuraciones de inicialización para cada plataforma.

    // Para Android, especificamos el ícono que se mostrará en la barra de estado.
    // '@mipmap/ic_launcher' se refiere al ícono principal de la app.
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Para iOS y macOS, solicitamos los permisos básicos al inicializar.
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 3. Combina las configuraciones de ambas plataformas.
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // 4. Inicializa el plugin con las configuraciones y define los manejadores de eventos.
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // Se llama cuando el usuario toca una notificación y la app está en primer plano.
      onDidReceiveNotificationResponse: onNotificationTap,
      // Se llama cuando el usuario toca una notificación y la app estaba en segundo plano o terminada.
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );

    // 5. Solicita permisos específicos para Android (versiones modernas).
    // Esto es crucial, ya que desde Android 12 y 13 los permisos son más estrictos.
    await _requestAndroidPermissions();
  }

  /// Solicita los permisos necesarios en versiones modernas de Android.
  Future<void> _requestAndroidPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // Para Android 13 (API 33) y superior, se necesita un permiso explícito para MOSTRAR notificaciones.
      await androidImplementation.requestNotificationsPermission();

      // Para Android 12 (API 31) y superior, se necesita un permiso explícito para programar ALARMAS EXACTAS.
      // Sin esto, el sistema operativo podría retrasar nuestras notificaciones para ahorrar batería.
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  /// Manejador estático que se ejecuta cuando el usuario toca una notificación.
  /// Es 'static' para que pueda ser llamado desde el background sin una instancia de la clase.
  @pragma('vm:entry-point')
  static void onNotificationTap(NotificationResponse notificationResponse) {
    // El 'payload' es información extra que adjuntamos a la notificación.
    // Aquí, lo ideal es que sea el ID del recordatorio.
    final String? payload = notificationResponse.payload;

    if (kDebugMode) {
      print('Notificación tocada con payload: $payload');
    }

    // TODO: Lógica de navegación.
    // Aquí es donde usaríamos go_router para navegar a la pantalla de detalle.
    // Ejemplo: if (payload != null) { AppRouter.router.go('/reminder-detail/$payload'); }
  }

  /// Programa una notificación para una fecha y hora específicas.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    // No podemos programar notificaciones para el pasado.
    if (scheduledDate.isBefore(DateTime.now())) {
      if (kDebugMode)
        print(
            "Intento de programar notificación para una fecha pasada. Cancelado.");
      return;
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      // Usamos `tz.TZDateTime.from(scheduledDate, tz.local)` en lugar de un `DateTime` simple.
      // Esto convierte la fecha a una consciente de la zona horaria del dispositivo,
      // asegurando que se dispare a la hora local correcta, incluso con cambios de horario de verano.
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        // Configuración específica para Android.
        android: AndroidNotificationDetails(
          'venceya_channel_id', // ID del canal de notificación (obligatorio).
          'Vencimientos', // Nombre del canal (visible para el usuario en los ajustes de la app).
          channelDescription: 'Notificaciones para recordatorios de VenceYa',
          importance: Importance
              .max, // Máxima importancia para que aparezca como notificación emergente.
          priority: Priority.high, // Máxima prioridad.
        ),
        // Configuración específica para iOS.
        iOS: DarwinNotificationDetails(),
      ),
      // MODO DE PROGRAMACIÓN PARA ANDROID:
      // `exactAllowWhileIdle` es VITAL. Le pide al sistema que sea preciso y
      // dispare la notificación a la hora exacta, incluso si el dispositivo está
      // en modo de bajo consumo (Doze).
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload, // Adjuntamos el ID del recordatorio aquí.
    );

    if (kDebugMode)
      print("Notificación programada para '$title' a las $scheduledDate");
  }

  /// Cancela una notificación específica usando su ID.
  /// Se usa cuando un recordatorio se edita o elimina.
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    if (kDebugMode) print("Notificación cancelada con id: $id");
  }

  /// Cancela TODAS las notificaciones programadas por la app.
  /// Podría usarse, por ejemplo, si el usuario cierra sesión.
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    if (kDebugMode) print("Todas las notificaciones han sido canceladas.");
  }
}
