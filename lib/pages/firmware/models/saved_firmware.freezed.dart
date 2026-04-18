// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_firmware.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedFirmware {

 String get id; String get userId; String get name; String get version; String get filePath; DateTime get createdAt; DateTime get updatedAt; String get description; bool get isBeta; bool get isPinned;@JsonKey(readValue: _readUsername) String get username;
/// Create a copy of SavedFirmware
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedFirmwareCopyWith<SavedFirmware> get copyWith => _$SavedFirmwareCopyWithImpl<SavedFirmware>(this as SavedFirmware, _$identity);

  /// Serializes this SavedFirmware to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedFirmware&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.isBeta, isBeta) || other.isBeta == isBeta)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.username, username) || other.username == username));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,version,filePath,createdAt,updatedAt,description,isBeta,isPinned,username);

@override
String toString() {
  return 'SavedFirmware(id: $id, userId: $userId, name: $name, version: $version, filePath: $filePath, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, isBeta: $isBeta, isPinned: $isPinned, username: $username)';
}


}

/// @nodoc
abstract mixin class $SavedFirmwareCopyWith<$Res>  {
  factory $SavedFirmwareCopyWith(SavedFirmware value, $Res Function(SavedFirmware) _then) = _$SavedFirmwareCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String version, String filePath, DateTime createdAt, DateTime updatedAt, String description, bool isBeta, bool isPinned,@JsonKey(readValue: _readUsername) String username
});




}
/// @nodoc
class _$SavedFirmwareCopyWithImpl<$Res>
    implements $SavedFirmwareCopyWith<$Res> {
  _$SavedFirmwareCopyWithImpl(this._self, this._then);

  final SavedFirmware _self;
  final $Res Function(SavedFirmware) _then;

/// Create a copy of SavedFirmware
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? version = null,Object? filePath = null,Object? createdAt = null,Object? updatedAt = null,Object? description = null,Object? isBeta = null,Object? isPinned = null,Object? username = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isBeta: null == isBeta ? _self.isBeta : isBeta // ignore: cast_nullable_to_non_nullable
as bool,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedFirmware].
extension SavedFirmwarePatterns on SavedFirmware {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedFirmware value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedFirmware() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedFirmware value)  $default,){
final _that = this;
switch (_that) {
case _SavedFirmware():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedFirmware value)?  $default,){
final _that = this;
switch (_that) {
case _SavedFirmware() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String version,  String filePath,  DateTime createdAt,  DateTime updatedAt,  String description,  bool isBeta,  bool isPinned, @JsonKey(readValue: _readUsername)  String username)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedFirmware() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.version,_that.filePath,_that.createdAt,_that.updatedAt,_that.description,_that.isBeta,_that.isPinned,_that.username);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String version,  String filePath,  DateTime createdAt,  DateTime updatedAt,  String description,  bool isBeta,  bool isPinned, @JsonKey(readValue: _readUsername)  String username)  $default,) {final _that = this;
switch (_that) {
case _SavedFirmware():
return $default(_that.id,_that.userId,_that.name,_that.version,_that.filePath,_that.createdAt,_that.updatedAt,_that.description,_that.isBeta,_that.isPinned,_that.username);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String version,  String filePath,  DateTime createdAt,  DateTime updatedAt,  String description,  bool isBeta,  bool isPinned, @JsonKey(readValue: _readUsername)  String username)?  $default,) {final _that = this;
switch (_that) {
case _SavedFirmware() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.version,_that.filePath,_that.createdAt,_that.updatedAt,_that.description,_that.isBeta,_that.isPinned,_that.username);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedFirmware implements SavedFirmware {
  const _SavedFirmware({required this.id, required this.userId, required this.name, required this.version, required this.filePath, required this.createdAt, required this.updatedAt, this.description = '', this.isBeta = false, this.isPinned = false, @JsonKey(readValue: _readUsername) this.username = ''});
  factory _SavedFirmware.fromJson(Map<String, dynamic> json) => _$SavedFirmwareFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String version;
@override final  String filePath;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isBeta;
@override@JsonKey() final  bool isPinned;
@override@JsonKey(readValue: _readUsername) final  String username;

/// Create a copy of SavedFirmware
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedFirmwareCopyWith<_SavedFirmware> get copyWith => __$SavedFirmwareCopyWithImpl<_SavedFirmware>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedFirmwareToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedFirmware&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.version, version) || other.version == version)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.isBeta, isBeta) || other.isBeta == isBeta)&&(identical(other.isPinned, isPinned) || other.isPinned == isPinned)&&(identical(other.username, username) || other.username == username));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,version,filePath,createdAt,updatedAt,description,isBeta,isPinned,username);

@override
String toString() {
  return 'SavedFirmware(id: $id, userId: $userId, name: $name, version: $version, filePath: $filePath, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, isBeta: $isBeta, isPinned: $isPinned, username: $username)';
}


}

/// @nodoc
abstract mixin class _$SavedFirmwareCopyWith<$Res> implements $SavedFirmwareCopyWith<$Res> {
  factory _$SavedFirmwareCopyWith(_SavedFirmware value, $Res Function(_SavedFirmware) _then) = __$SavedFirmwareCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String version, String filePath, DateTime createdAt, DateTime updatedAt, String description, bool isBeta, bool isPinned,@JsonKey(readValue: _readUsername) String username
});




}
/// @nodoc
class __$SavedFirmwareCopyWithImpl<$Res>
    implements _$SavedFirmwareCopyWith<$Res> {
  __$SavedFirmwareCopyWithImpl(this._self, this._then);

  final _SavedFirmware _self;
  final $Res Function(_SavedFirmware) _then;

/// Create a copy of SavedFirmware
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? version = null,Object? filePath = null,Object? createdAt = null,Object? updatedAt = null,Object? description = null,Object? isBeta = null,Object? isPinned = null,Object? username = null,}) {
  return _then(_SavedFirmware(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isBeta: null == isBeta ? _self.isBeta : isBeta // ignore: cast_nullable_to_non_nullable
as bool,isPinned: null == isPinned ? _self.isPinned : isPinned // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
