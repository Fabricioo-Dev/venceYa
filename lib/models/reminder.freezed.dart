// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reminder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Reminder _$ReminderFromJson(Map<String, dynamic> json) {
  return _Reminder.fromJson(json);
}

/// @nodoc
mixin _$Reminder {
// ID del documento de Firestore (se asigna después de crearlo).
  String? get id =>
      throw _privateConstructorUsedError; // ID del usuario al que pertenece el recordatorio.
  String get userId =>
      throw _privateConstructorUsedError; // Título principal del recordatorio.
  String get title =>
      throw _privateConstructorUsedError; // Campo opcional para notas o detalles adicionales.
  String? get description =>
      throw _privateConstructorUsedError; // Fecha y hora exactas del vencimiento.
  @TimestampConverter()
  DateTime get dueDate =>
      throw _privateConstructorUsedError; // Categoría del recordatorio, con "Otro" como valor por defecto.
  ReminderCategory get category =>
      throw _privateConstructorUsedError; // Controla si la notificación está habilitada, `true` por defecto.
  bool get isNotificationEnabled =>
      throw _privateConstructorUsedError; // Fecha de creación del recordatorio.
  @TimestampConverter()
  DateTime? get createdAt =>
      throw _privateConstructorUsedError; // Fecha de la última actualización del recordatorio.
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Reminder to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReminderCopyWith<Reminder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReminderCopyWith<$Res> {
  factory $ReminderCopyWith(Reminder value, $Res Function(Reminder) then) =
      _$ReminderCopyWithImpl<$Res, Reminder>;
  @useResult
  $Res call(
      {String? id,
      String userId,
      String title,
      String? description,
      @TimestampConverter() DateTime dueDate,
      ReminderCategory category,
      bool isNotificationEnabled,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class _$ReminderCopyWithImpl<$Res, $Val extends Reminder>
    implements $ReminderCopyWith<$Res> {
  _$ReminderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? dueDate = null,
    Object? category = null,
    Object? isNotificationEnabled = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ReminderCategory,
      isNotificationEnabled: null == isNotificationEnabled
          ? _value.isNotificationEnabled
          : isNotificationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReminderImplCopyWith<$Res>
    implements $ReminderCopyWith<$Res> {
  factory _$$ReminderImplCopyWith(
          _$ReminderImpl value, $Res Function(_$ReminderImpl) then) =
      __$$ReminderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String userId,
      String title,
      String? description,
      @TimestampConverter() DateTime dueDate,
      ReminderCategory category,
      bool isNotificationEnabled,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? updatedAt});
}

/// @nodoc
class __$$ReminderImplCopyWithImpl<$Res>
    extends _$ReminderCopyWithImpl<$Res, _$ReminderImpl>
    implements _$$ReminderImplCopyWith<$Res> {
  __$$ReminderImplCopyWithImpl(
      _$ReminderImpl _value, $Res Function(_$ReminderImpl) _then)
      : super(_value, _then);

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = null,
    Object? title = null,
    Object? description = freezed,
    Object? dueDate = null,
    Object? category = null,
    Object? isNotificationEnabled = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ReminderImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      dueDate: null == dueDate
          ? _value.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ReminderCategory,
      isNotificationEnabled: null == isNotificationEnabled
          ? _value.isNotificationEnabled
          : isNotificationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReminderImpl implements _Reminder {
  const _$ReminderImpl(
      {this.id,
      required this.userId,
      required this.title,
      this.description,
      @TimestampConverter() required this.dueDate,
      this.category = ReminderCategory.other,
      this.isNotificationEnabled = true,
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.updatedAt});

  factory _$ReminderImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReminderImplFromJson(json);

// ID del documento de Firestore (se asigna después de crearlo).
  @override
  final String? id;
// ID del usuario al que pertenece el recordatorio.
  @override
  final String userId;
// Título principal del recordatorio.
  @override
  final String title;
// Campo opcional para notas o detalles adicionales.
  @override
  final String? description;
// Fecha y hora exactas del vencimiento.
  @override
  @TimestampConverter()
  final DateTime dueDate;
// Categoría del recordatorio, con "Otro" como valor por defecto.
  @override
  @JsonKey()
  final ReminderCategory category;
// Controla si la notificación está habilitada, `true` por defecto.
  @override
  @JsonKey()
  final bool isNotificationEnabled;
// Fecha de creación del recordatorio.
  @override
  @TimestampConverter()
  final DateTime? createdAt;
// Fecha de la última actualización del recordatorio.
  @override
  @TimestampConverter()
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Reminder(id: $id, userId: $userId, title: $title, description: $description, dueDate: $dueDate, category: $category, isNotificationEnabled: $isNotificationEnabled, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReminderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isNotificationEnabled, isNotificationEnabled) ||
                other.isNotificationEnabled == isNotificationEnabled) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, title, description,
      dueDate, category, isNotificationEnabled, createdAt, updatedAt);

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReminderImplCopyWith<_$ReminderImpl> get copyWith =>
      __$$ReminderImplCopyWithImpl<_$ReminderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReminderImplToJson(
      this,
    );
  }
}

abstract class _Reminder implements Reminder {
  const factory _Reminder(
      {final String? id,
      required final String userId,
      required final String title,
      final String? description,
      @TimestampConverter() required final DateTime dueDate,
      final ReminderCategory category,
      final bool isNotificationEnabled,
      @TimestampConverter() final DateTime? createdAt,
      @TimestampConverter() final DateTime? updatedAt}) = _$ReminderImpl;

  factory _Reminder.fromJson(Map<String, dynamic> json) =
      _$ReminderImpl.fromJson;

// ID del documento de Firestore (se asigna después de crearlo).
  @override
  String? get id; // ID del usuario al que pertenece el recordatorio.
  @override
  String get userId; // Título principal del recordatorio.
  @override
  String get title; // Campo opcional para notas o detalles adicionales.
  @override
  String? get description; // Fecha y hora exactas del vencimiento.
  @override
  @TimestampConverter()
  DateTime
      get dueDate; // Categoría del recordatorio, con "Otro" como valor por defecto.
  @override
  ReminderCategory
      get category; // Controla si la notificación está habilitada, `true` por defecto.
  @override
  bool get isNotificationEnabled; // Fecha de creación del recordatorio.
  @override
  @TimestampConverter()
  DateTime? get createdAt; // Fecha de la última actualización del recordatorio.
  @override
  @TimestampConverter()
  DateTime? get updatedAt;

  /// Create a copy of Reminder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReminderImplCopyWith<_$ReminderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
