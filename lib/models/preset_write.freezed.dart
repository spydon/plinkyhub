// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'preset_write.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PresetWrite {

 String get userId; String get name; String get category; String get presetData; String get description; bool get isPublic; String? get sampleId;
/// Create a copy of PresetWrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresetWriteCopyWith<PresetWrite> get copyWith => _$PresetWriteCopyWithImpl<PresetWrite>(this as PresetWrite, _$identity);

  /// Serializes this PresetWrite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresetWrite&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.presetData, presetData) || other.presetData == presetData)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,category,presetData,description,isPublic,sampleId);

@override
String toString() {
  return 'PresetWrite(userId: $userId, name: $name, category: $category, presetData: $presetData, description: $description, isPublic: $isPublic, sampleId: $sampleId)';
}


}

/// @nodoc
abstract mixin class $PresetWriteCopyWith<$Res>  {
  factory $PresetWriteCopyWith(PresetWrite value, $Res Function(PresetWrite) _then) = _$PresetWriteCopyWithImpl;
@useResult
$Res call({
 String userId, String name, String category, String presetData, String description, bool isPublic, String? sampleId
});




}
/// @nodoc
class _$PresetWriteCopyWithImpl<$Res>
    implements $PresetWriteCopyWith<$Res> {
  _$PresetWriteCopyWithImpl(this._self, this._then);

  final PresetWrite _self;
  final $Res Function(PresetWrite) _then;

/// Create a copy of PresetWrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? name = null,Object? category = null,Object? presetData = null,Object? description = null,Object? isPublic = null,Object? sampleId = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,presetData: null == presetData ? _self.presetData : presetData // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,sampleId: freezed == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PresetWrite].
extension PresetWritePatterns on PresetWrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PresetWrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PresetWrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PresetWrite value)  $default,){
final _that = this;
switch (_that) {
case _PresetWrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PresetWrite value)?  $default,){
final _that = this;
switch (_that) {
case _PresetWrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String name,  String category,  String presetData,  String description,  bool isPublic,  String? sampleId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PresetWrite() when $default != null:
return $default(_that.userId,_that.name,_that.category,_that.presetData,_that.description,_that.isPublic,_that.sampleId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String name,  String category,  String presetData,  String description,  bool isPublic,  String? sampleId)  $default,) {final _that = this;
switch (_that) {
case _PresetWrite():
return $default(_that.userId,_that.name,_that.category,_that.presetData,_that.description,_that.isPublic,_that.sampleId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String name,  String category,  String presetData,  String description,  bool isPublic,  String? sampleId)?  $default,) {final _that = this;
switch (_that) {
case _PresetWrite() when $default != null:
return $default(_that.userId,_that.name,_that.category,_that.presetData,_that.description,_that.isPublic,_that.sampleId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PresetWrite implements PresetWrite {
  const _PresetWrite({required this.userId, required this.name, required this.category, required this.presetData, this.description = '', this.isPublic = false, this.sampleId});
  factory _PresetWrite.fromJson(Map<String, dynamic> json) => _$PresetWriteFromJson(json);

@override final  String userId;
@override final  String name;
@override final  String category;
@override final  String presetData;
@override@JsonKey() final  String description;
@override@JsonKey() final  bool isPublic;
@override final  String? sampleId;

/// Create a copy of PresetWrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PresetWriteCopyWith<_PresetWrite> get copyWith => __$PresetWriteCopyWithImpl<_PresetWrite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PresetWriteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PresetWrite&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.presetData, presetData) || other.presetData == presetData)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPublic, isPublic) || other.isPublic == isPublic)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,name,category,presetData,description,isPublic,sampleId);

@override
String toString() {
  return 'PresetWrite(userId: $userId, name: $name, category: $category, presetData: $presetData, description: $description, isPublic: $isPublic, sampleId: $sampleId)';
}


}

/// @nodoc
abstract mixin class _$PresetWriteCopyWith<$Res> implements $PresetWriteCopyWith<$Res> {
  factory _$PresetWriteCopyWith(_PresetWrite value, $Res Function(_PresetWrite) _then) = __$PresetWriteCopyWithImpl;
@override @useResult
$Res call({
 String userId, String name, String category, String presetData, String description, bool isPublic, String? sampleId
});




}
/// @nodoc
class __$PresetWriteCopyWithImpl<$Res>
    implements _$PresetWriteCopyWith<$Res> {
  __$PresetWriteCopyWithImpl(this._self, this._then);

  final _PresetWrite _self;
  final $Res Function(_PresetWrite) _then;

/// Create a copy of PresetWrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? name = null,Object? category = null,Object? presetData = null,Object? description = null,Object? isPublic = null,Object? sampleId = freezed,}) {
  return _then(_PresetWrite(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,presetData: null == presetData ? _self.presetData : presetData // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,isPublic: null == isPublic ? _self.isPublic : isPublic // ignore: cast_nullable_to_non_nullable
as bool,sampleId: freezed == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
