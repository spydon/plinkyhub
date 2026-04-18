// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_pattern.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedPattern {

 String get id; String get userId; String get name; String get filePath; DateTime get createdAt; DateTime get updatedAt; String get description; bool get isPublic;@JsonKey(readValue: _readUsername) String get username;@JsonKey(readValue: _readStarCount) int get starCount; bool get isStarred; String? get contentHash;
/// Create a copy of SavedPattern
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedPatternCopyWith<SavedPattern> get copyWith => _$SavedPatternCopyWithImpl<SavedPattern>(this as SavedPattern, _$identity);

  /// Serializes this SavedPattern to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedPattern&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.username, username) || other.username == username)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.isStarred, isStarred) || other.isStarred == isStarred)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,filePath,createdAt,updatedAt,description,isPublic,username,starCount,isStarred,contentHash);

@override
String toString() {
  return 'SavedPattern(id: $id, userId: $userId, name: $name, filePath: $filePath, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, isPublic: $isPublic, username: $username, starCount: $starCount, isStarred: $isStarred, contentHash: $contentHash)';
}


}

/// @nodoc
abstract mixin class $SavedPatternCopyWith<$Res>  {
  factory $SavedPatternCopyWith(SavedPattern value, $Res Function(SavedPattern) _then) = _$SavedPatternCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String filePath, DateTime createdAt, DateTime updatedAt, String description, bool isPublic,@JsonKey(readValue: _readUsername) String username,@JsonKey(readValue: _readStarCount) int starCount, bool isStarred, String? contentHash
});




}
/// @nodoc
class _$SavedPatternCopyWithImpl<$Res>
    implements $SavedPatternCopyWith<$Res> {
  _$SavedPatternCopyWithImpl(this._self, this._then);

  final SavedPattern _self;
  final $Res Function(SavedPattern) _then;

/// Create a copy of SavedPattern
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? filePath = null,Object? createdAt = null,Object? updatedAt = null,Object? description = null,Object? isPublic = null,Object? username = null,Object? starCount = null,Object? isStarred = null,Object? contentHash = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,isStarred: null == isStarred ? _self.isStarred : isStarred // ignore: cast_nullable_to_non_nullable
as bool,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedPattern].
extension SavedPatternPatterns on SavedPattern {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedPattern value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedPattern() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedPattern value)  $default,){
final _that = this;
switch (_that) {
case _SavedPattern():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedPattern value)?  $default,){
final _that = this;
switch (_that) {
case _SavedPattern() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String filePath,  DateTime createdAt,  DateTime updatedAt,  String description,  bool isPublic, @JsonKey(readValue: _readUsername)  String username, @JsonKey(readValue: _readStarCount)  int starCount,  bool isStarred,  String? contentHash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedPattern() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.filePath,_that.createdAt,_that.updatedAt,_that.description,_that.isPublic,_that.username,_that.starCount,_that.isStarred,_that.contentHash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String filePath,  DateTime createdAt,  DateTime updatedAt,  String description,  bool isPublic, @JsonKey(readValue: _readUsername)  String username, @JsonKey(readValue: _readStarCount)  int starCount,  bool isStarred,  String? contentHash)  $default,) {final _that = this;
switch (_that) {
case _SavedPattern():
return $default(_that.id,_that.userId,_that.name,_that.filePath,_that.createdAt,_that.updatedAt,_that.description,_that.isPublic,_that.username,_that.starCount,_that.isStarred,_that.contentHash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String filePath,  DateTime createdAt,  DateTime updatedAt,  String description,  bool isPublic, @JsonKey(readValue: _readUsername)  String username, @JsonKey(readValue: _readStarCount)  int starCount,  bool isStarred,  String? contentHash)?  $default,) {final _that = this;
switch (_that) {
case _SavedPattern() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.filePath,_that.createdAt,_that.updatedAt,_that.description,_that.isPublic,_that.username,_that.starCount,_that.isStarred,_that.contentHash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedPattern implements SavedPattern {
  const _SavedPattern({required this.id, required this.userId, required this.name, required this.filePath, required this.createdAt, required this.updatedAt, this.description = '', this.isPublic = false, @JsonKey(readValue: _readUsername) this.username = '', @JsonKey(readValue: _readStarCount) this.starCount = 0, this.isStarred = false, this.contentHash});
  factory _SavedPattern.fromJson(Map<String, dynamic> json) => _$SavedPatternFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String filePath;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isPublic;
@override@JsonKey(readValue: _readUsername) final  String username;
@override@JsonKey(readValue: _readStarCount) final  int starCount;
@override@JsonKey() final  bool isStarred;
@override final  String? contentHash;

/// Create a copy of SavedPattern
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedPatternCopyWith<_SavedPattern> get copyWith => __$SavedPatternCopyWithImpl<_SavedPattern>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedPatternToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedPattern&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.username, username) || other.username == username)&&(identical(other.starCount, starCount) || other.starCount == starCount)&&(identical(other.isStarred, isStarred) || other.isStarred == isStarred)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,filePath,createdAt,updatedAt,description,isPublic,username,starCount,isStarred,contentHash);

@override
String toString() {
  return 'SavedPattern(id: $id, userId: $userId, name: $name, filePath: $filePath, createdAt: $createdAt, updatedAt: $updatedAt, description: $description, isPublic: $isPublic, username: $username, starCount: $starCount, isStarred: $isStarred, contentHash: $contentHash)';
}


}

/// @nodoc
abstract mixin class _$SavedPatternCopyWith<$Res> implements $SavedPatternCopyWith<$Res> {
  factory _$SavedPatternCopyWith(_SavedPattern value, $Res Function(_SavedPattern) _then) = __$SavedPatternCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String filePath, DateTime createdAt, DateTime updatedAt, String description, bool isPublic,@JsonKey(readValue: _readUsername) String username,@JsonKey(readValue: _readStarCount) int starCount, bool isStarred, String? contentHash
});




}
/// @nodoc
class __$SavedPatternCopyWithImpl<$Res>
    implements _$SavedPatternCopyWith<$Res> {
  __$SavedPatternCopyWithImpl(this._self, this._then);

  final _SavedPattern _self;
  final $Res Function(_SavedPattern) _then;

/// Create a copy of SavedPattern
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? filePath = null,Object? createdAt = null,Object? updatedAt = null,Object? description = null,Object? isPublic = null,Object? username = null,Object? starCount = null,Object? isStarred = null,Object? contentHash = freezed,}) {
  return _then(_SavedPattern(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,starCount: null == starCount ? _self.starCount : starCount // ignore: cast_nullable_to_non_nullable
as int,isStarred: null == isStarred ? _self.isStarred : isStarred // ignore: cast_nullable_to_non_nullable
as bool,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
