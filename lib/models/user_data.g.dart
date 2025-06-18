// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserDataImpl _$$UserDataImplFromJson(Map<String, dynamic> json) =>
    _$UserDataImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dailyUsageStreak: (json['dailyUsageStreak'] as num?)?.toInt() ?? 0,
      points: (json['points'] as num?)?.toInt() ?? 0,
      lastLogin: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['lastLogin'], const TimestampConverter().fromJson),
      createdAt: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['createdAt'], const TimestampConverter().fromJson),
    );

Map<String, dynamic> _$$UserDataImplToJson(_$UserDataImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dailyUsageStreak': instance.dailyUsageStreak,
      'points': instance.points,
      'lastLogin': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.lastLogin, const TimestampConverter().toJson),
      'createdAt': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.createdAt, const TimestampConverter().toJson),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
