// lib/models/reminder.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

// Helper para convertir Timestamp de Firestore a DateTime y viceversa
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

// Enum para la frecuencia del recordatorio
enum ReminderFrequency { none, daily, weekly, monthly, yearly }

// Enum para la categoría del recordatorio
enum ReminderCategory { payments, services, documents, personal, other }

@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    String? id, // ID del documento de Firestore, opcional en la creación
    required String userId, // ID del usuario propietario
    required String title,
    @TimestampConverter() required DateTime dueDate,
    @Default(ReminderCategory.other) ReminderCategory category,
    @Default(ReminderFrequency.none) ReminderFrequency frequency,
    @Default(true) bool isNotificationEnabled,
    @TimestampConverter()
    DateTime? createdAt, // Se establecerá en el servidor o cliente
    @TimestampConverter()
    DateTime? updatedAt, // Se establecerá en el servidor o cliente
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}
