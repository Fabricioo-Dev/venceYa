// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReminderImpl _$$ReminderImplFromJson(Map<String, dynamic> json) =>
    _$ReminderImpl(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      dueDate:
          const TimestampConverter().fromJson(json['dueDate'] as Timestamp),
      category:
          $enumDecodeNullable(_$ReminderCategoryEnumMap, json['category']) ??
              ReminderCategory.other,
      isNotificationEnabled: json['isNotificationEnabled'] as bool? ?? true,
      createdAt: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['createdAt'], const TimestampConverter().fromJson),
      updatedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['updatedAt'], const TimestampConverter().fromJson),
    );

Map<String, dynamic> _$$ReminderImplToJson(_$ReminderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'dueDate': const TimestampConverter().toJson(instance.dueDate),
      'category': _$ReminderCategoryEnumMap[instance.category]!,
      'isNotificationEnabled': instance.isNotificationEnabled,
      'createdAt': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.createdAt, const TimestampConverter().toJson),
      'updatedAt': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.updatedAt, const TimestampConverter().toJson),
    };

const _$ReminderCategoryEnumMap = {
  ReminderCategory.payments: 'payments',
  ReminderCategory.services: 'services',
  ReminderCategory.documents: 'documents',
  ReminderCategory.personal: 'personal',
  ReminderCategory.other: 'other',
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
