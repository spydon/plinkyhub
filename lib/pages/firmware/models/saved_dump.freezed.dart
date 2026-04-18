// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_dump.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedDump {

 String get id; String get userId; String get title; DateTime get createdAt; DateTime get updatedAt; String? get internalFlashPath; String? get externalFlashPath; String get description; int get internalFlashSize; int get externalFlashSize;@JsonKey(readValue: _readUsername) String get username;
/// Create a copy of SavedDump
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedDumpCopyWith<SavedDump> get copyWith => _$SavedDumpCopyWithImpl<SavedDump>(this as SavedDump, _$identity);

  /// Serializes this SavedDump to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedDump&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.internalFlashPath, internalFlashPath) || other.internalFlashPath == internalFlashPath)&&(identical(other.externalFlashPath, externalFlashPath) || other.externalFlashPath == externalFlashPath)&&(identical(other.description, description) || other.description == description)&&(identical(other.internalFlashSize, internalFlashSize) || other.internalFlashSize == internalFlashSize)&&(identical(other.externalFlashSize, externalFlashSize) || other.externalFlashSize == externalFlashSize)&&(identical(other.username, username) || other.username == username));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,createdAt,updatedAt,internalFlashPath,externalFlashPath,description,internalFlashSize,externalFlashSize,username);

@override
String toString() {
  return 'SavedDump(id: $id, userId: $userId, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, internalFlashPath: $internalFlashPath, externalFlashPath: $externalFlashPath, description: $description, internalFlashSize: $internalFlashSize, externalFlashSize: $externalFlashSize, username: $username)';
}


}

/// @nodoc
abstract mixin class $SavedDumpCopyWith<$Res>  {
  factory $SavedDumpCopyWith(SavedDump value, $Res Function(SavedDump) _then) = _$SavedDumpCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String title, DateTime createdAt, DateTime updatedAt, String? internalFlashPath, String? externalFlashPath, String description, int internalFlashSize, int externalFlashSize,@JsonKey(readValue: _readUsername) String username
});




}
/// @nodoc
class _$SavedDumpCopyWithImpl<$Res>
    implements $SavedDumpCopyWith<$Res> {
  _$SavedDumpCopyWithImpl(this._self, this._then);

  final SavedDump _self;
  final $Res Function(SavedDump) _then;

/// Create a copy of SavedDump
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? createdAt = null,Object? updatedAt = null,Object? internalFlashPath = freezed,Object? externalFlashPath = freezed,Object? description = null,Object? internalFlashSize = null,Object? externalFlashSize = null,Object? username = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,internalFlashPath: freezed == internalFlashPath ? _self.internalFlashPath : internalFlashPath // ignore: cast_nullable_to_non_nullable
as String?,externalFlashPath: freezed == externalFlashPath ? _self.externalFlashPath : externalFlashPath // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,internalFlashSize: null == internalFlashSize ? _self.internalFlashSize : internalFlashSize // ignore: cast_nullable_to_non_nullable
as int,externalFlashSize: null == externalFlashSize ? _self.externalFlashSize : externalFlashSize // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedDump].
extension SavedDumpPatterns on SavedDump {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedDump value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedDump() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedDump value)  $default,){
final _that = this;
switch (_that) {
case _SavedDump():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedDump value)?  $default,){
final _that = this;
switch (_that) {
case _SavedDump() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String title,  DateTime createdAt,  DateTime updatedAt,  String? internalFlashPath,  String? externalFlashPath,  String description,  int internalFlashSize,  int externalFlashSize, @JsonKey(readValue: _readUsername)  String username)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedDump() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.createdAt,_that.updatedAt,_that.internalFlashPath,_that.externalFlashPath,_that.description,_that.internalFlashSize,_that.externalFlashSize,_that.username);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String title,  DateTime createdAt,  DateTime updatedAt,  String? internalFlashPath,  String? externalFlashPath,  String description,  int internalFlashSize,  int externalFlashSize, @JsonKey(readValue: _readUsername)  String username)  $default,) {final _that = this;
switch (_that) {
case _SavedDump():
return $default(_that.id,_that.userId,_that.title,_that.createdAt,_that.updatedAt,_that.internalFlashPath,_that.externalFlashPath,_that.description,_that.internalFlashSize,_that.externalFlashSize,_that.username);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String title,  DateTime createdAt,  DateTime updatedAt,  String? internalFlashPath,  String? externalFlashPath,  String description,  int internalFlashSize,  int externalFlashSize, @JsonKey(readValue: _readUsername)  String username)?  $default,) {final _that = this;
switch (_that) {
case _SavedDump() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.createdAt,_that.updatedAt,_that.internalFlashPath,_that.externalFlashPath,_that.description,_that.internalFlashSize,_that.externalFlashSize,_that.username);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedDump implements SavedDump {
  const _SavedDump({required this.id, required this.userId, required this.title, required this.createdAt, required this.updatedAt, this.internalFlashPath, this.externalFlashPath, this.description = '', this.internalFlashSize = 0, this.externalFlashSize = 0, @JsonKey(readValue: _readUsername) this.username = ''});
  factory _SavedDump.fromJson(Map<String, dynamic> json) => _$SavedDumpFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String title;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? internalFlashPath;
@override final  String? externalFlashPath;
@override@JsonKey() final  String description;
@override@JsonKey() final  int internalFlashSize;
@override@JsonKey() final  int externalFlashSize;
@override@JsonKey(readValue: _readUsername) final  String username;

/// Create a copy of SavedDump
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedDumpCopyWith<_SavedDump> get copyWith => __$SavedDumpCopyWithImpl<_SavedDump>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedDumpToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedDump&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.internalFlashPath, internalFlashPath) || other.internalFlashPath == internalFlashPath)&&(identical(other.externalFlashPath, externalFlashPath) || other.externalFlashPath == externalFlashPath)&&(identical(other.description, description) || other.description == description)&&(identical(other.internalFlashSize, internalFlashSize) || other.internalFlashSize == internalFlashSize)&&(identical(other.externalFlashSize, externalFlashSize) || other.externalFlashSize == externalFlashSize)&&(identical(other.username, username) || other.username == username));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,createdAt,updatedAt,internalFlashPath,externalFlashPath,description,internalFlashSize,externalFlashSize,username);

@override
String toString() {
  return 'SavedDump(id: $id, userId: $userId, title: $title, createdAt: $createdAt, updatedAt: $updatedAt, internalFlashPath: $internalFlashPath, externalFlashPath: $externalFlashPath, description: $description, internalFlashSize: $internalFlashSize, externalFlashSize: $externalFlashSize, username: $username)';
}


}

/// @nodoc
abstract mixin class _$SavedDumpCopyWith<$Res> implements $SavedDumpCopyWith<$Res> {
  factory _$SavedDumpCopyWith(_SavedDump value, $Res Function(_SavedDump) _then) = __$SavedDumpCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String title, DateTime createdAt, DateTime updatedAt, String? internalFlashPath, String? externalFlashPath, String description, int internalFlashSize, int externalFlashSize,@JsonKey(readValue: _readUsername) String username
});




}
/// @nodoc
class __$SavedDumpCopyWithImpl<$Res>
    implements _$SavedDumpCopyWith<$Res> {
  __$SavedDumpCopyWithImpl(this._self, this._then);

  final _SavedDump _self;
  final $Res Function(_SavedDump) _then;

/// Create a copy of SavedDump
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? title = null,Object? createdAt = null,Object? updatedAt = null,Object? internalFlashPath = freezed,Object? externalFlashPath = freezed,Object? description = null,Object? internalFlashSize = null,Object? externalFlashSize = null,Object? username = null,}) {
  return _then(_SavedDump(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,internalFlashPath: freezed == internalFlashPath ? _self.internalFlashPath : internalFlashPath // ignore: cast_nullable_to_non_nullable
as String?,externalFlashPath: freezed == externalFlashPath ? _self.externalFlashPath : externalFlashPath // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,internalFlashSize: null == internalFlashSize ? _self.internalFlashSize : internalFlashSize // ignore: cast_nullable_to_non_nullable
as int,externalFlashSize: null == externalFlashSize ? _self.externalFlashSize : externalFlashSize // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
