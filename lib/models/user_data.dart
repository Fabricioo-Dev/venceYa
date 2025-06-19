// lib/models/user_data.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reminder.dart';

part 'user_data.freezed.dart';
part 'user_data.g.dart';

@freezed
class UserData with _$UserData {
  const factory UserData({
    required String uid, // ID único de Firebase Auth
    required String email,
    String? displayName, // Nombre para mostrar (ej. de social login)
    String? photoUrl, // URL de la foto de perfil
    String? firstName, // Nombre del usuario
    String? lastName, // Apellido del usuario
    @TimestampConverter() DateTime? lastLogin, // Último inicio de sesión
    @TimestampConverter() DateTime? createdAt, // Fecha de creación del perfil
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
