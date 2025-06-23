// lib/models/reminder.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Estas dos líneas son cruciales para el generador de código 'build_runner'.
// Le dicen a este archivo que es solo una 'parte' de una librería más grande,
// y que las otras partes serán generadas automáticamente en estos archivos.
part 'reminder.freezed.dart'; // Contendrá la lógica de Freezed (copyWith, ==, etc.).
part 'reminder.g.dart'; // Contendrá la lógica de serialización JSON (toJson, fromJson).

// --- CONVERTIDOR DE TIPOS PERSONALIZADO ---
// Firestore guarda las fechas como un objeto `Timestamp`, pero en nuestra app Dart usamos `DateTime`.
// No son compatibles directamente. Esta clase actúa como un "traductor" para que el paquete
// json_serializable sepa cómo convertir entre estos dos tipos.
class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  // Se llama al LEER datos de Firestore. Convierte el `Timestamp` de la base de datos a un `DateTime` de Dart.
  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  // Se llama al ESCRIBIR datos a Firestore. Convierte el `DateTime` de Dart a un `Timestamp` de Firestore.
  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

// --- ENUMERACIONES ---
// Usar `enum` es una buena práctica porque nos da seguridad de tipos.
// En lugar de usar strings como "daily" (que podría escribirse mal como "dialy"),
// usamos valores predefinidos, lo que evita errores.
enum ReminderFrequency { none, daily, weekly, monthly, yearly }

enum ReminderCategory { payments, services, documents, personal, other }

// --- DEFINICIÓN DEL MODELO DE DATOS ---
// La anotación `@freezed` le dice al generador de código que procese esta clase
// para crear automáticamente métodos útiles (copyWith, ==, toString, hashCode)
// y asegurar que la clase sea inmutable (sus propiedades no pueden cambiar después de su creación).
@freezed
class Reminder with _$Reminder {
  const factory Reminder({
    // El ID del documento en Firestore. Es nullable (?) porque cuando CREAMOS un nuevo
    // recordatorio, aún no tiene un ID. Se lo asignamos después de que Firestore lo genera.
    String? id,

    // El ID del usuario al que pertenece este recordatorio. Es 'required' para saber el dueño.
    required String userId,
    required String title,

    // `@TimestampConverter()` le dice a json_serializable que use nuestro "traductor"
    // personalizado para este campo.
    @TimestampConverter() required DateTime dueDate,

    // `@Default(...)` especifica un valor por defecto si no se proporciona uno al crear el objeto.
    // Esto hace que nuestro modelo sea más robusto.
    @Default(ReminderCategory.other) ReminderCategory category,
    @Default(ReminderFrequency.none) ReminderFrequency frequency,
    @Default(true) bool isNotificationEnabled,

    // Las fechas de creación y actualización son opcionales porque podríamos tener
    // datos antiguos en la base de datos que no las tengan.
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? updatedAt,
  }) =
      _Reminder; // `_Reminder` es la implementación real que será generada por Freezed.

  /// Un "factory constructor" que permite crear una instancia de `Reminder`
  /// a partir de un mapa JSON (que es como Firestore nos entrega los datos).
  /// Llama al método `_$ReminderFromJson` que será generado automáticamente
  /// por el paquete `json_serializable`.
  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}
