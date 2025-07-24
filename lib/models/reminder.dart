// lib/models/reminder.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

/// Convierte entre el `Timestamp` de Firestore y el `DateTime` de Dart.
///
/// Esta clase implementa `JsonConverter`, permitiendo que se aplique como una
/// anotación a los campos de fecha para automatizar su conversión.
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Define las categorías disponibles para un recordatorio.
/// Usar un `enum` asegura que solo se puedan usar valores válidos.
enum ReminderCategory {
  payments,
  services,
  documents,
  personal,
  other,
}

/// Modelo de datos inmutable para un recordatorio.
@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    // ID del documento en Firestore. Es opcional (`?`) porque se asigna
    // después de que el documento es creado en la base de datos.
    String? id,

    // ID del usuario al que pertenece el recordatorio.
    required String userId,

    // Título principal del recordatorio.
    required String title,

    // Descripción o notas adicionales (opcional).
    String? description,

    // Fecha de vencimiento. Usa el conversor para manejar el tipo Timestamp.
    @TimestampConverter() required DateTime dueDate,

    // Categoría. `@Default` asigna `other` si no se provee un valor.
    @Default(ReminderCategory.other) ReminderCategory category,

    // Controla si la notificación local está habilitada para este recordatorio.
    @Default(true) bool isNotificationEnabled,

    // Fecha de creación (opcional, manejada por el servicio).
    @TimestampConverter() DateTime? createdAt,

    // Fecha de la última actualización (opcional, manejada por el servicio).
    @TimestampConverter() DateTime? updatedAt,
  }) = _Reminder;

  /// Constructor factory para crear una instancia desde un mapa JSON (Firestore).
  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}
