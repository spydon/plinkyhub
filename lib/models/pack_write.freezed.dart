// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pack_write.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackWrite {

 String get userId; String get name; String get description; bool get isPublic; String? get wavetableId;
/// Create a copy of PackWrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackWriteCopyWith<PackWrite> get copyWith => _$PackWriteCopyWithImpl<PackWrite>(this as PackWrite, _$identity);

  /// Serializes this PackWrite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackWrite&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.wavetableId, wavetableId) || other.wavetableId == wavetableId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,description,isPublic,wavetableId);

@override
String toString() {
  return 'PackWrite(userId: $userId, name: $name, description: $description, isPublic: $isPublic, wavetableId: $wavetableId)';
}


}

/// @nodoc
abstract mixin class $PackWriteCopyWith<$Res>  {
  factory $PackWriteCopyWith(PackWrite value, $Res Function(PackWrite) _then) = _$PackWriteCopyWithImpl;
@useResult
$Res call({
 String userId, String name, String description, bool isPublic, String? wavetableId
});




}
/// @nodoc
class _$PackWriteCopyWithImpl<$Res>
    implements $PackWriteCopyWith<$Res> {
  _$PackWriteCopyWithImpl(this._self, this._then);

  final PackWrite _self;
  final $Res Function(PackWrite) _then;

/// Create a copy of PackWrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? name = null,Object? description = null,Object? isPublic = null,Object? wavetableId = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,wavetableId: freezed == wavetableId ? _self.wavetableId : wavetableId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackWrite].
extension PackWritePatterns on PackWrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackWrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackWrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackWrite value)  $default,){
final _that = this;
switch (_that) {
case _PackWrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackWrite value)?  $default,){
final _that = this;
switch (_that) {
case _PackWrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String name,  String description,  bool isPublic,  String? wavetableId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackWrite() when $default != null:
return $default(_that.userId,_that.name,_that.description,_that.isPublic,_that.wavetableId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String name,  String description,  bool isPublic,  String? wavetableId)  $default,) {final _that = this;
switch (_that) {
case _PackWrite():
return $default(_that.userId,_that.name,_that.description,_that.isPublic,_that.wavetableId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String name,  String description,  bool isPublic,  String? wavetableId)?  $default,) {final _that = this;
switch (_that) {
case _PackWrite() when $default != null:
return $default(_that.userId,_that.name,_that.description,_that.isPublic,_that.wavetableId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackWrite implements PackWrite {
  const _PackWrite({required this.userId, required this.name, this.description = '', this.isPublic = false, this.wavetableId});
  factory _PackWrite.fromJson(Map<String, dynamic> json) => _$PackWriteFromJson(json);

@override final  String userId;
@override final  String name;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isPublic;
@override final  String? wavetableId;

/// Create a copy of PackWrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackWriteCopyWith<_PackWrite> get copyWith => __$PackWriteCopyWithImpl<_PackWrite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackWriteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackWrite&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.wavetableId, wavetableId) || other.wavetableId == wavetableId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,description,isPublic,wavetableId);

@override
String toString() {
  return 'PackWrite(userId: $userId, name: $name, description: $description, isPublic: $isPublic, wavetableId: $wavetableId)';
}


}

/// @nodoc
abstract mixin class _$PackWriteCopyWith<$Res> implements $PackWriteCopyWith<$Res> {
  factory _$PackWriteCopyWith(_PackWrite value, $Res Function(_PackWrite) _then) = __$PackWriteCopyWithImpl;
@override @useResult
$Res call({
 String userId, String name, String description, bool isPublic, String? wavetableId
});




}
/// @nodoc
class __$PackWriteCopyWithImpl<$Res>
    implements _$PackWriteCopyWith<$Res> {
  __$PackWriteCopyWithImpl(this._self, this._then);

  final _PackWrite _self;
  final $Res Function(_PackWrite) _then;

/// Create a copy of PackWrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? name = null,Object? description = null,Object? isPublic = null,Object? wavetableId = freezed,}) {
  return _then(_PackWrite(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,wavetableId: freezed == wavetableId ? _self.wavetableId : wavetableId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
