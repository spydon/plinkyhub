// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pack_slot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackSlot {

 String get id; String get packId; int get slotNumber; String? get presetId; String? get sampleId;
/// Create a copy of PackSlot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackSlotCopyWith<PackSlot> get copyWith => _$PackSlotCopyWithImpl<PackSlot>(this as PackSlot, _$identity);

  /// Serializes this PackSlot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackSlot&&(identical(other.id, id) || other.id == id)&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.slotNumber, slotNumber) || other.slotNumber == slotNumber)&&(identical(other.presetId, presetId) || other.presetId == presetId)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,packId,slotNumber,presetId,sampleId);

@override
String toString() {
  return 'PackSlot(id: $id, packId: $packId, slotNumber: $slotNumber, presetId: $presetId, sampleId: $sampleId)';
}


}

/// @nodoc
abstract mixin class $PackSlotCopyWith<$Res>  {
  factory $PackSlotCopyWith(PackSlot value, $Res Function(PackSlot) _then) = _$PackSlotCopyWithImpl;
@useResult
$Res call({
 String id, String packId, int slotNumber, String? presetId, String? sampleId
});




}
/// @nodoc
class _$PackSlotCopyWithImpl<$Res>
    implements $PackSlotCopyWith<$Res> {
  _$PackSlotCopyWithImpl(this._self, this._then);

  final PackSlot _self;
  final $Res Function(PackSlot) _then;

/// Create a copy of PackSlot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? packId = null,Object? slotNumber = null,Object? presetId = freezed,Object? sampleId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,slotNumber: null == slotNumber ? _self.slotNumber : slotNumber // ignore: cast_nullable_to_non_nullable
as int,presetId: freezed == presetId ? _self.presetId : presetId // ignore: cast_nullable_to_non_nullable
as String?,sampleId: freezed == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackSlot].
extension PackSlotPatterns on PackSlot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackSlot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackSlot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackSlot value)  $default,){
final _that = this;
switch (_that) {
case _PackSlot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackSlot value)?  $default,){
final _that = this;
switch (_that) {
case _PackSlot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String packId,  int slotNumber,  String? presetId,  String? sampleId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackSlot() when $default != null:
return $default(_that.id,_that.packId,_that.slotNumber,_that.presetId,_that.sampleId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String packId,  int slotNumber,  String? presetId,  String? sampleId)  $default,) {final _that = this;
switch (_that) {
case _PackSlot():
return $default(_that.id,_that.packId,_that.slotNumber,_that.presetId,_that.sampleId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String packId,  int slotNumber,  String? presetId,  String? sampleId)?  $default,) {final _that = this;
switch (_that) {
case _PackSlot() when $default != null:
return $default(_that.id,_that.packId,_that.slotNumber,_that.presetId,_that.sampleId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackSlot implements PackSlot {
  const _PackSlot({required this.id, required this.packId, required this.slotNumber, this.presetId, this.sampleId});
  factory _PackSlot.fromJson(Map<String, dynamic> json) => _$PackSlotFromJson(json);

@override final  String id;
@override final  String packId;
@override final  int slotNumber;
@override final  String? presetId;
@override final  String? sampleId;

/// Create a copy of PackSlot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackSlotCopyWith<_PackSlot> get copyWith => __$PackSlotCopyWithImpl<_PackSlot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackSlotToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackSlot&&(identical(other.id, id) || other.id == id)&&(identical(other.packId, packId) || other.packId == packId)&&(identical(other.slotNumber, slotNumber) || other.slotNumber == slotNumber)&&(identical(other.presetId, presetId) || other.presetId == presetId)&&(identical(other.sampleId, sampleId) || other.sampleId == sampleId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,packId,slotNumber,presetId,sampleId);

@override
String toString() {
  return 'PackSlot(id: $id, packId: $packId, slotNumber: $slotNumber, presetId: $presetId, sampleId: $sampleId)';
}


}

/// @nodoc
abstract mixin class _$PackSlotCopyWith<$Res> implements $PackSlotCopyWith<$Res> {
  factory _$PackSlotCopyWith(_PackSlot value, $Res Function(_PackSlot) _then) = __$PackSlotCopyWithImpl;
@override @useResult
$Res call({
 String id, String packId, int slotNumber, String? presetId, String? sampleId
});




}
/// @nodoc
class __$PackSlotCopyWithImpl<$Res>
    implements _$PackSlotCopyWith<$Res> {
  __$PackSlotCopyWithImpl(this._self, this._then);

  final _PackSlot _self;
  final $Res Function(_PackSlot) _then;

/// Create a copy of PackSlot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? packId = null,Object? slotNumber = null,Object? presetId = freezed,Object? sampleId = freezed,}) {
  return _then(_PackSlot(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,packId: null == packId ? _self.packId : packId // ignore: cast_nullable_to_non_nullable
as String,slotNumber: null == slotNumber ? _self.slotNumber : slotNumber // ignore: cast_nullable_to_non_nullable
as int,presetId: freezed == presetId ? _self.presetId : presetId // ignore: cast_nullable_to_non_nullable
as String?,sampleId: freezed == sampleId ? _self.sampleId : sampleId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
