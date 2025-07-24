// lib/models/user_data.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Se importa para reutilizar el conversor de Timestamp definido en el modelo Reminder.
import 'package:venceya/models/reminder.dart';

// Archivos generados por `build_runner` para Freezed y JsonSerializable.
part 'user_data.freezed.dart';
part 'user_data.g.dart';

/// Modelo de datos inmutable para el usuario.
///
/// `@freezed` genera automáticamente métodos como `copyWith`, `==` y `toString`,
/// lo que asegura un modelo de datos robusto y sin código repetitivo.
@freezed
class UserData with _$UserData {
  const factory UserData({
    // ID único de Firebase Authentication. Es el campo principal.
    required String uid,
    required String email,

    // Campos opcionales que pueden venir de proveedores de auth o del registro.
    String? displayName,
    String? photoUrl,
    String? firstName,
    String? lastName,

    // Se usa un conversor para transformar el `Timestamp` de Firestore a `DateTime` de Dart.
    @TimestampConverter() DateTime? lastLogin,
    @TimestampConverter() DateTime? createdAt,
  }) = _UserData;

  /// Constructor factory para crear una instancia de `UserData` desde un mapa JSON.
  /// Esencial para leer los datos que vienen de Firestore.
  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
