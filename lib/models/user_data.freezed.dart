// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserData _$UserDataFromJson(Map<String, dynamic> json) {
  return _UserData.fromJson(json);
}

/// @nodoc
mixin _$UserData {
  String get uid =>
      throw _privateConstructorUsedError; // Coincide con el UID de Firebase Auth
  String get email => throw _privateConstructorUsedError;
  String? get displayName =>
      throw _privateConstructorUsedError; // Puede seguir siendo útil para nombres de social login
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get firstName =>
      throw _privateConstructorUsedError; // <<-- ¡NUEVO CAMPO!
  String? get lastName =>
      throw _privateConstructorUsedError; // <<-- ¡NUEVO CAMPO!
  int get dailyUsageStreak => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastLogin => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this UserData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserDataCopyWith<UserData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserDataCopyWith<$Res> {
  factory $UserDataCopyWith(UserData value, $Res Function(UserData) then) =
      _$UserDataCopyWithImpl<$Res, UserData>;
  @useResult
  $Res call(
      {String uid,
      String email,
      String? displayName,
      String? photoUrl,
      String? firstName,
      String? lastName,
      int dailyUsageStreak,
      int points,
      @TimestampConverter() DateTime? lastLogin,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class _$UserDataCopyWithImpl<$Res, $Val extends UserData>
    implements $UserDataCopyWith<$Res> {
  _$UserDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? dailyUsageStreak = null,
    Object? points = null,
    Object? lastLogin = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      dailyUsageStreak: null == dailyUsageStreak
          ? _value.dailyUsageStreak
          : dailyUsageStreak // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      lastLogin: freezed == lastLogin
          ? _value.lastLogin
          : lastLogin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserDataImplCopyWith<$Res>
    implements $UserDataCopyWith<$Res> {
  factory _$$UserDataImplCopyWith(
          _$UserDataImpl value, $Res Function(_$UserDataImpl) then) =
      __$$UserDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String email,
      String? displayName,
      String? photoUrl,
      String? firstName,
      String? lastName,
      int dailyUsageStreak,
      int points,
      @TimestampConverter() DateTime? lastLogin,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class __$$UserDataImplCopyWithImpl<$Res>
    extends _$UserDataCopyWithImpl<$Res, _$UserDataImpl>
    implements _$$UserDataImplCopyWith<$Res> {
  __$$UserDataImplCopyWithImpl(
      _$UserDataImpl _value, $Res Function(_$UserDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? dailyUsageStreak = null,
    Object? points = null,
    Object? lastLogin = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$UserDataImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      dailyUsageStreak: null == dailyUsageStreak
          ? _value.dailyUsageStreak
          : dailyUsageStreak // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      lastLogin: freezed == lastLogin
          ? _value.lastLogin
          : lastLogin // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserDataImpl implements _UserData {
  const _$UserDataImpl(
      {required this.uid,
      required this.email,
      this.displayName,
      this.photoUrl,
      this.firstName,
      this.lastName,
      this.dailyUsageStreak = 0,
      this.points = 0,
      @TimestampConverter() this.lastLogin,
      @TimestampConverter() this.createdAt});

  factory _$UserDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserDataImplFromJson(json);

  @override
  final String uid;
// Coincide con el UID de Firebase Auth
  @override
  final String email;
  @override
  final String? displayName;
// Puede seguir siendo útil para nombres de social login
  @override
  final String? photoUrl;
  @override
  final String? firstName;
// <<-- ¡NUEVO CAMPO!
  @override
  final String? lastName;
// <<-- ¡NUEVO CAMPO!
  @override
  @JsonKey()
  final int dailyUsageStreak;
  @override
  @JsonKey()
  final int points;
  @override
  @TimestampConverter()
  final DateTime? lastLogin;
  @override
  @TimestampConverter()
  final DateTime? createdAt;

  @override
  String toString() {
    return 'UserData(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, firstName: $firstName, lastName: $lastName, dailyUsageStreak: $dailyUsageStreak, points: $points, lastLogin: $lastLogin, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserDataImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.dailyUsageStreak, dailyUsageStreak) ||
                other.dailyUsageStreak == dailyUsageStreak) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.lastLogin, lastLogin) ||
                other.lastLogin == lastLogin) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      email,
      displayName,
      photoUrl,
      firstName,
      lastName,
      dailyUsageStreak,
      points,
      lastLogin,
      createdAt);

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserDataImplCopyWith<_$UserDataImpl> get copyWith =>
      __$$UserDataImplCopyWithImpl<_$UserDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserDataImplToJson(
      this,
    );
  }
}

abstract class _UserData implements UserData {
  const factory _UserData(
      {required final String uid,
      required final String email,
      final String? displayName,
      final String? photoUrl,
      final String? firstName,
      final String? lastName,
      final int dailyUsageStreak,
      final int points,
      @TimestampConverter() final DateTime? lastLogin,
      @TimestampConverter() final DateTime? createdAt}) = _$UserDataImpl;

  factory _UserData.fromJson(Map<String, dynamic> json) =
      _$UserDataImpl.fromJson;

  @override
  String get uid; // Coincide con el UID de Firebase Auth
  @override
  String get email;
  @override
  String?
      get displayName; // Puede seguir siendo útil para nombres de social login
  @override
  String? get photoUrl;
  @override
  String? get firstName; // <<-- ¡NUEVO CAMPO!
  @override
  String? get lastName; // <<-- ¡NUEVO CAMPO!
  @override
  int get dailyUsageStreak;
  @override
  int get points;
  @override
  @TimestampConverter()
  DateTime? get lastLogin;
  @override
  @TimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of UserData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserDataImplCopyWith<_$UserDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
