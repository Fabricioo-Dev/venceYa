// lib/models/user_data.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reminder.dart'; // Importar TimestampConverter

part 'user_data.freezed.dart';
part 'user_data.g.dart';

@freezed
class UserData with _$UserData {
  const factory UserData({
    required String uid, // Coincide con el UID de Firebase Auth
    required String email,
    String?
        displayName, // Puede seguir siendo útil para nombres de social login
    String? photoUrl,
    String? firstName, // <<-- ¡NUEVO CAMPO!
    String? lastName, // <<-- ¡NUEVO CAMPO!
    @Default(0) int dailyUsageStreak,
    @Default(0) int points,
    @TimestampConverter() DateTime? lastLogin,
    @TimestampConverter() DateTime? createdAt,
  }) = _UserData;

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);
}
