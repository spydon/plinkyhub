// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wavetable_write.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WavetableWrite {

 String get userId; String get name; String get filePath; String get description; bool get isPublic; String get youtubeUrl; String? get contentHash;
/// Create a copy of WavetableWrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WavetableWriteCopyWith<WavetableWrite> get copyWith => _$WavetableWriteCopyWithImpl<WavetableWrite>(this as WavetableWrite, _$identity);

  /// Serializes this WavetableWrite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WavetableWrite&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.youtubeUrl, youtubeUrl) || other.youtubeUrl == youtubeUrl)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,filePath,description,isPublic,youtubeUrl,contentHash);

@override
String toString() {
  return 'WavetableWrite(userId: $userId, name: $name, filePath: $filePath, description: $description, isPublic: $isPublic, youtubeUrl: $youtubeUrl, contentHash: $contentHash)';
}


}

/// @nodoc
abstract mixin class $WavetableWriteCopyWith<$Res>  {
  factory $WavetableWriteCopyWith(WavetableWrite value, $Res Function(WavetableWrite) _then) = _$WavetableWriteCopyWithImpl;
@useResult
$Res call({
 String userId, String name, String filePath, String description, bool isPublic, String youtubeUrl, String? contentHash
});




}
/// @nodoc
class _$WavetableWriteCopyWithImpl<$Res>
    implements $WavetableWriteCopyWith<$Res> {
  _$WavetableWriteCopyWithImpl(this._self, this._then);

  final WavetableWrite _self;
  final $Res Function(WavetableWrite) _then;

/// Create a copy of WavetableWrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? name = null,Object? filePath = null,Object? description = null,Object? isPublic = null,Object? youtubeUrl = null,Object? contentHash = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,youtubeUrl: null == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WavetableWrite].
extension WavetableWritePatterns on WavetableWrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WavetableWrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WavetableWrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WavetableWrite value)  $default,){
final _that = this;
switch (_that) {
case _WavetableWrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WavetableWrite value)?  $default,){
final _that = this;
switch (_that) {
case _WavetableWrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String name,  String filePath,  String description,  bool isPublic,  String youtubeUrl,  String? contentHash)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WavetableWrite() when $default != null:
return $default(_that.userId,_that.name,_that.filePath,_that.description,_that.isPublic,_that.youtubeUrl,_that.contentHash);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String name,  String filePath,  String description,  bool isPublic,  String youtubeUrl,  String? contentHash)  $default,) {final _that = this;
switch (_that) {
case _WavetableWrite():
return $default(_that.userId,_that.name,_that.filePath,_that.description,_that.isPublic,_that.youtubeUrl,_that.contentHash);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String name,  String filePath,  String description,  bool isPublic,  String youtubeUrl,  String? contentHash)?  $default,) {final _that = this;
switch (_that) {
case _WavetableWrite() when $default != null:
return $default(_that.userId,_that.name,_that.filePath,_that.description,_that.isPublic,_that.youtubeUrl,_that.contentHash);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WavetableWrite implements WavetableWrite {
  const _WavetableWrite({required this.userId, required this.name, required this.filePath, this.description = '', this.isPublic = false, this.youtubeUrl = '', this.contentHash});
  factory _WavetableWrite.fromJson(Map<String, dynamic> json) => _$WavetableWriteFromJson(json);

@override final  String userId;
@override final  String name;
@override final  String filePath;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isPublic;
@override@JsonKey() final  String youtubeUrl;
@override final  String? contentHash;

/// Create a copy of WavetableWrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WavetableWriteCopyWith<_WavetableWrite> get copyWith => __$WavetableWriteCopyWithImpl<_WavetableWrite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WavetableWriteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WavetableWrite&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.youtubeUrl, youtubeUrl) || other.youtubeUrl == youtubeUrl)&&(identical(other.contentHash, contentHash) || other.contentHash == contentHash));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,filePath,description,isPublic,youtubeUrl,contentHash);

@override
String toString() {
  return 'WavetableWrite(userId: $userId, name: $name, filePath: $filePath, description: $description, isPublic: $isPublic, youtubeUrl: $youtubeUrl, contentHash: $contentHash)';
}


}

/// @nodoc
abstract mixin class _$WavetableWriteCopyWith<$Res> implements $WavetableWriteCopyWith<$Res> {
  factory _$WavetableWriteCopyWith(_WavetableWrite value, $Res Function(_WavetableWrite) _then) = __$WavetableWriteCopyWithImpl;
@override @useResult
$Res call({
 String userId, String name, String filePath, String description, bool isPublic, String youtubeUrl, String? contentHash
});




}
/// @nodoc
class __$WavetableWriteCopyWithImpl<$Res>
    implements _$WavetableWriteCopyWith<$Res> {
  __$WavetableWriteCopyWithImpl(this._self, this._then);

  final _WavetableWrite _self;
  final $Res Function(_WavetableWrite) _then;

/// Create a copy of WavetableWrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? name = null,Object? filePath = null,Object? description = null,Object? isPublic = null,Object? youtubeUrl = null,Object? contentHash = freezed,}) {
  return _then(_WavetableWrite(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,filePath: null == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,youtubeUrl: null == youtubeUrl ? _self.youtubeUrl : youtubeUrl // ignore: cast_nullable_to_non_nullable
as String,contentHash: freezed == contentHash ? _self.contentHash : contentHash // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
