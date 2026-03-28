// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pack_slot_write.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackSlotWrite {

 String get packId; int get slotNumber; String? get presetId; String? get sampleId;
/// Create a copy of PackSlotWrite
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackSlotWriteCopyWith<PackSlotWrite> get copyWith => _$PackSlotWriteCopyWithImpl<PackSlotWrite>(this as PackSlotWrite, _$identity);

  /// Serializes this PackSlotWrite to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackSlotWrite&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.slotNumber, slotNumber) || other.slotNumber == slotNumber)&&(identical(other.presetId, presetId) || other.presetId == presetId)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packId,slotNumber,presetId,sampleId);

@override
String toString() {
  return 'PackSlotWrite(packId: $packId, slotNumber: $slotNumber, presetId: $presetId, sampleId: $sampleId)';
}


}

/// @nodoc
abstract mixin class $PackSlotWriteCopyWith<$Res>  {
  factory $PackSlotWriteCopyWith(PackSlotWrite value, $Res Function(PackSlotWrite) _then) = _$PackSlotWriteCopyWithImpl;
@useResult
$Res call({
 String packId, int slotNumber, String? presetId, String? sampleId
});




}
/// @nodoc
class _$PackSlotWriteCopyWithImpl<$Res>
    implements $PackSlotWriteCopyWith<$Res> {
  _$PackSlotWriteCopyWithImpl(this._self, this._then);

  final PackSlotWrite _self;
  final $Res Function(PackSlotWrite) _then;

/// Create a copy of PackSlotWrite
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? packId = null,Object? slotNumber = null,Object? presetId = freezed,Object? sampleId = freezed,}) {
  return _then(_self.copyWith(
packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,slotNumber: null == slotNumber ? _self.slotNumber : slotNumber // ignore: cast_nullable_to_non_nullable
as int,presetId: freezed == presetId ? _self.presetId : presetId // ignore: cast_nullable_to_non_nullable
as String?,sampleId: freezed == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackSlotWrite].
extension PackSlotWritePatterns on PackSlotWrite {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackSlotWrite value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackSlotWrite() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackSlotWrite value)  $default,){
final _that = this;
switch (_that) {
case _PackSlotWrite():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackSlotWrite value)?  $default,){
final _that = this;
switch (_that) {
case _PackSlotWrite() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String packId,  int slotNumber,  String? presetId,  String? sampleId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackSlotWrite() when $default != null:
return $default(_that.packId,_that.slotNumber,_that.presetId,_that.sampleId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String packId,  int slotNumber,  String? presetId,  String? sampleId)  $default,) {final _that = this;
switch (_that) {
case _PackSlotWrite():
return $default(_that.packId,_that.slotNumber,_that.presetId,_that.sampleId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String packId,  int slotNumber,  String? presetId,  String? sampleId)?  $default,) {final _that = this;
switch (_that) {
case _PackSlotWrite() when $default != null:
return $default(_that.packId,_that.slotNumber,_that.presetId,_that.sampleId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackSlotWrite implements PackSlotWrite {
  const _PackSlotWrite({required this.packId, required this.slotNumber, this.presetId, this.sampleId});
  factory _PackSlotWrite.fromJson(Map<String, dynamic> json) => _$PackSlotWriteFromJson(json);

@override final  String packId;
@override final  int slotNumber;
@override final  String? presetId;
@override final  String? sampleId;

/// Create a copy of PackSlotWrite
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackSlotWriteCopyWith<_PackSlotWrite> get copyWith => __$PackSlotWriteCopyWithImpl<_PackSlotWrite>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackSlotWriteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackSlotWrite&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.slotNumber, slotNumber) || other.slotNumber == slotNumber)&&(identical(other.presetId, presetId) || other.presetId == presetId)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,packId,slotNumber,presetId,sampleId);

@override
String toString() {
  return 'PackSlotWrite(packId: $packId, slotNumber: $slotNumber, presetId: $presetId, sampleId: $sampleId)';
}


}

/// @nodoc
abstract mixin class _$PackSlotWriteCopyWith<$Res> implements $PackSlotWriteCopyWith<$Res> {
  factory _$PackSlotWriteCopyWith(_PackSlotWrite value, $Res Function(_PackSlotWrite) _then) = __$PackSlotWriteCopyWithImpl;
@override @useResult
$Res call({
 String packId, int slotNumber, String? presetId, String? sampleId
});




}
/// @nodoc
class __$PackSlotWriteCopyWithImpl<$Res>
    implements _$PackSlotWriteCopyWith<$Res> {
  __$PackSlotWriteCopyWithImpl(this._self, this._then);

  final _PackSlotWrite _self;
  final $Res Function(_PackSlotWrite) _then;

/// Create a copy of PackSlotWrite
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? packId = null,Object? slotNumber = null,Object? presetId = freezed,Object? sampleId = freezed,}) {
  return _then(_PackSlotWrite(
packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,slotNumber: null == slotNumber ? _self.slotNumber : slotNumber // ignore: cast_nullable_to_non_nullable
as int,presetId: freezed == presetId ? _self.presetId : presetId // ignore: cast_nullable_to_non_nullable
as String?,sampleId: freezed == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
