// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patch_write.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PatchWrite {

 String get userId; String get name; String get category; String get patchData; String get description; bool get isPublic; String? get sampleId;
/// Create a copy of PatchWrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatchWriteCopyWith<PatchWrite> get copyWith => _$PatchWriteCopyWithImpl<PatchWrite>(this as PatchWrite, _$identity);

  /// Serializes this PatchWrite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatchWrite&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.patchData, patchData) || other.patchData == patchData)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,category,patchData,description,isPublic,sampleId);

@override
String toString() {
  return 'PatchWrite(userId: $userId, name: $name, category: $category, patchData: $patchData, description: $description, isPublic: $isPublic, sampleId: $sampleId)';
}


}

/// @nodoc
abstract mixin class $PatchWriteCopyWith<$Res>  {
  factory $PatchWriteCopyWith(PatchWrite value, $Res Function(PatchWrite) _then) = _$PatchWriteCopyWithImpl;
@useResult
$Res call({
 String userId, String name, String category, String patchData, String description, bool isPublic, String? sampleId
});




}
/// @nodoc
class _$PatchWriteCopyWithImpl<$Res>
    implements $PatchWriteCopyWith<$Res> {
  _$PatchWriteCopyWithImpl(this._self, this._then);

  final PatchWrite _self;
  final $Res Function(PatchWrite) _then;

/// Create a copy of PatchWrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? name = null,Object? category = null,Object? patchData = null,Object? description = null,Object? isPublic = null,Object? sampleId = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,patchData: null == patchData ? _self.patchData : patchData // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,sampleId: freezed == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PatchWrite].
extension PatchWritePatterns on PatchWrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatchWrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatchWrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatchWrite value)  $default,){
final _that = this;
switch (_that) {
case _PatchWrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatchWrite value)?  $default,){
final _that = this;
switch (_that) {
case _PatchWrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String name,  String category,  String patchData,  String description,  bool isPublic,  String? sampleId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatchWrite() when $default != null:
return $default(_that.userId,_that.name,_that.category,_that.patchData,_that.description,_that.isPublic,_that.sampleId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String name,  String category,  String patchData,  String description,  bool isPublic,  String? sampleId)  $default,) {final _that = this;
switch (_that) {
case _PatchWrite():
return $default(_that.userId,_that.name,_that.category,_that.patchData,_that.description,_that.isPublic,_that.sampleId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String name,  String category,  String patchData,  String description,  bool isPublic,  String? sampleId)?  $default,) {final _that = this;
switch (_that) {
case _PatchWrite() when $default != null:
return $default(_that.userId,_that.name,_that.category,_that.patchData,_that.description,_that.isPublic,_that.sampleId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatchWrite implements PatchWrite {
  const _PatchWrite({required this.userId, required this.name, required this.category, required this.patchData, this.description = '', this.isPublic = false, this.sampleId});
  factory _PatchWrite.fromJson(Map<String, dynamic> json) => _$PatchWriteFromJson(json);

@override final  String userId;
@override final  String name;
@override final  String category;
@override final  String patchData;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isPublic;
@override final  String? sampleId;

/// Create a copy of PatchWrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatchWriteCopyWith<_PatchWrite> get copyWith => __$PatchWriteCopyWithImpl<_PatchWrite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatchWriteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatchWrite&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.patchData, patchData) || other.patchData == patchData)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,category,patchData,description,isPublic,sampleId);

@override
String toString() {
  return 'PatchWrite(userId: $userId, name: $name, category: $category, patchData: $patchData, description: $description, isPublic: $isPublic, sampleId: $sampleId)';
}


}

/// @nodoc
abstract mixin class _$PatchWriteCopyWith<$Res> implements $PatchWriteCopyWith<$Res> {
  factory _$PatchWriteCopyWith(_PatchWrite value, $Res Function(_PatchWrite) _then) = __$PatchWriteCopyWithImpl;
@override @useResult
$Res call({
 String userId, String name, String category, String patchData, String description, bool isPublic, String? sampleId
});




}
/// @nodoc
class __$PatchWriteCopyWithImpl<$Res>
    implements _$PatchWriteCopyWith<$Res> {
  __$PatchWriteCopyWithImpl(this._self, this._then);

  final _PatchWrite _self;
  final $Res Function(_PatchWrite) _then;

/// Create a copy of PatchWrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? name = null,Object? category = null,Object? patchData = null,Object? description = null,Object? isPublic = null,Object? sampleId = freezed,}) {
  return _then(_PatchWrite(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,patchData: null == patchData ? _self.patchData : patchData // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,sampleId: freezed == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
