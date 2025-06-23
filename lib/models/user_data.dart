// lib/models/user_data.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Importamos el modelo de Reminder, no porque lo necesitemos directamente,
// sino para REUTILIZAR el `TimestampConverter` que definimos allí. ¡Es una buena práctica!
import 'reminder.dart';

// Líneas que conectan este archivo con los archivos que generará `build_runner`.
part 'user_data.freezed.dart';
part 'user_data.g.dart';

// --- DEFINICIÓN DEL MODELO DE DATOS DEL USUARIO ---
// La anotación `@freezed` instruye al generador de código para que cree una clase
// de datos inmutable, con métodos `copyWith`, `==`, etc., ahorrándonos mucho trabajo.
@freezed
class UserData with _$UserData {
  const factory UserData({
    // El ID único del usuario, que viene de Firebase Authentication. Es el identificador principal.
    required String uid,
    required String email,

    // Todos los siguientes campos son opcionales (`?`) porque un usuario puede
    // no tenerlos todos. Por ejemplo, un usuario registrado por email no tendrá `photoUrl`
    // al principio, y un usuario de Google podría no tener `firstName`.

    // Nombre para mostrar, usualmente proporcionado por un proveedor social como Google.
    String? displayName,

    // URL de la foto de perfil, también usualmente de un proveedor social.
    String? photoUrl,

    // Nombre del usuario, proporcionado en el formulario de registro manual.
    String? firstName,

    // Apellido del usuario, proporcionado en el formulario de registro manual.
    String? lastName,

    // La última vez que el usuario inició sesión. Usamos nuestro convertidor reutilizado.
    @TimestampConverter() DateTime? lastLogin,

    // La fecha en que el perfil del usuario fue creado en nuestra base de datos.
    @TimestampConverter() DateTime? createdAt,
  }) = _UserData; // La implementación real que será generada por Freezed.

  /// El factory constructor que permite crear una instancia de `UserData`
  /// a partir de un mapa JSON (los datos que vienen de Firestore).
  /// Llama al método `_$UserDataFromJson` que será generado automáticamente.
  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
