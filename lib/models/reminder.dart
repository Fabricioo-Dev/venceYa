// lib/models/reminder.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

/// Convierte el Timestamp de Firestore a DateTime de Dart y viceversa.
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

/// Define las categorías posibles para un recordatorio.
enum ReminderCategory { payments, services, documents, personal, other }

/// Define la estructura de datos inmutable para un recordatorio usando Freezed.
@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    // ID del documento de Firestore (se asigna después de crearlo).
    String? id,
    // ID del usuario al que pertenece el recordatorio.
    required String userId,
    // Título principal del recordatorio.
    required String title,
    // Campo opcional para notas o detalles adicionales.
    String? description,
    // Fecha y hora exactas del vencimiento.
    @TimestampConverter() required DateTime dueDate,
    // Categoría del recordatorio, con "Otro" como valor por defecto.
    @Default(ReminderCategory.other) ReminderCategory category,
    // Controla si la notificación está habilitada, `true` por defecto.
    @Default(true) bool isNotificationEnabled,
    // Fecha de creación del recordatorio.
    @TimestampConverter() DateTime? createdAt,
    // Fecha de la última actualización del recordatorio.
    @TimestampConverter() DateTime? updatedAt,
  }) = _Reminder;

  /// Crea un objeto Reminder a partir de un mapa JSON (datos de Firestore).
  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}
