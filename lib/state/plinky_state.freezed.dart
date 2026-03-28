// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plinky_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlinkyState {

 PlinkyConnectionState get connectionState; Preset? get preset; int get presetNumber; String? get errorMessage;/// ID of the saved cloud preset that was loaded into the editor,
/// used to enable overwriting instead of always saving new.
 String? get sourcePresetId;
/// Create a copy of PlinkyState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlinkyStateCopyWith<PlinkyState> get copyWith => _$PlinkyStateCopyWithImpl<PlinkyState>(this as PlinkyState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlinkyState&&(identical(other.connectionState, connectionState) || other.connectionState == connectionState)&&(identical(other.preset, preset) || other.preset == preset)&&(identical(other.presetNumber, presetNumber) || other.presetNumber == presetNumber)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.sourcePresetId, sourcePresetId) || other.sourcePresetId == sourcePresetId));
}


@override
int get hashCode => Object.hash(runtimeType,connectionState,preset,presetNumber,errorMessage,sourcePresetId);

@override
String toString() {
  return 'PlinkyState(connectionState: $connectionState, preset: $preset, presetNumber: $presetNumber, errorMessage: $errorMessage, sourcePresetId: $sourcePresetId)';
}


}

/// @nodoc
abstract mixin class $PlinkyStateCopyWith<$Res>  {
  factory $PlinkyStateCopyWith(PlinkyState value, $Res Function(PlinkyState) _then) = _$PlinkyStateCopyWithImpl;
@useResult
$Res call({
 PlinkyConnectionState connectionState, Preset? preset, int presetNumber, String? errorMessage, String? sourcePresetId
});




}
/// @nodoc
class _$PlinkyStateCopyWithImpl<$Res>
    implements $PlinkyStateCopyWith<$Res> {
  _$PlinkyStateCopyWithImpl(this._self, this._then);

  final PlinkyState _self;
  final $Res Function(PlinkyState) _then;

/// Create a copy of PlinkyState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? connectionState = null,Object? preset = freezed,Object? presetNumber = null,Object? errorMessage = freezed,Object? sourcePresetId = freezed,}) {
  return _then(_self.copyWith(
connectionState: null == connectionState ? _self.connectionState : connectionState // ignore: cast_nullable_to_non_nullable
as PlinkyConnectionState,preset: freezed == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as Preset?,presetNumber: null == presetNumber ? _self.presetNumber : presetNumber // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,sourcePresetId: freezed == sourcePresetId ? _self.sourcePresetId : sourcePresetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlinkyState].
extension PlinkyStatePatterns on PlinkyState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlinkyState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlinkyState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlinkyState value)  $default,){
final _that = this;
switch (_that) {
case _PlinkyState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlinkyState value)?  $default,){
final _that = this;
switch (_that) {
case _PlinkyState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PlinkyConnectionState connectionState,  Preset? preset,  int presetNumber,  String? errorMessage,  String? sourcePresetId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlinkyState() when $default != null:
return $default(_that.connectionState,_that.preset,_that.presetNumber,_that.errorMessage,_that.sourcePresetId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PlinkyConnectionState connectionState,  Preset? preset,  int presetNumber,  String? errorMessage,  String? sourcePresetId)  $default,) {final _that = this;
switch (_that) {
case _PlinkyState():
return $default(_that.connectionState,_that.preset,_that.presetNumber,_that.errorMessage,_that.sourcePresetId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PlinkyConnectionState connectionState,  Preset? preset,  int presetNumber,  String? errorMessage,  String? sourcePresetId)?  $default,) {final _that = this;
switch (_that) {
case _PlinkyState() when $default != null:
return $default(_that.connectionState,_that.preset,_that.presetNumber,_that.errorMessage,_that.sourcePresetId);case _:
  return null;

}
}

}

/// @nodoc


class _PlinkyState implements PlinkyState {
  const _PlinkyState({this.connectionState = PlinkyConnectionState.disconnected, this.preset, this.presetNumber = 0, this.errorMessage, this.sourcePresetId});
  

@override@JsonKey() final  PlinkyConnectionState connectionState;
@override final  Preset? preset;
@override@JsonKey() final  int presetNumber;
@override final  String? errorMessage;
/// ID of the saved cloud preset that was loaded into the editor,
/// used to enable overwriting instead of always saving new.
@override final  String? sourcePresetId;

/// Create a copy of PlinkyState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlinkyStateCopyWith<_PlinkyState> get copyWith => __$PlinkyStateCopyWithImpl<_PlinkyState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlinkyState&&(identical(other.connectionState, connectionState) || other.connectionState == connectionState)&&(identical(other.preset, preset) || other.preset == preset)&&(identical(other.presetNumber, presetNumber) || other.presetNumber == presetNumber)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.sourcePresetId, sourcePresetId) || other.sourcePresetId == sourcePresetId));
}


@override
int get hashCode => Object.hash(runtimeType,connectionState,preset,presetNumber,errorMessage,sourcePresetId);

@override
String toString() {
  return 'PlinkyState(connectionState: $connectionState, preset: $preset, presetNumber: $presetNumber, errorMessage: $errorMessage, sourcePresetId: $sourcePresetId)';
}


}

/// @nodoc
abstract mixin class _$PlinkyStateCopyWith<$Res> implements $PlinkyStateCopyWith<$Res> {
  factory _$PlinkyStateCopyWith(_PlinkyState value, $Res Function(_PlinkyState) _then) = __$PlinkyStateCopyWithImpl;
@override @useResult
$Res call({
 PlinkyConnectionState connectionState, Preset? preset, int presetNumber, String? errorMessage, String? sourcePresetId
});




}
/// @nodoc
class __$PlinkyStateCopyWithImpl<$Res>
    implements _$PlinkyStateCopyWith<$Res> {
  __$PlinkyStateCopyWithImpl(this._self, this._then);

  final _PlinkyState _self;
  final $Res Function(_PlinkyState) _then;

/// Create a copy of PlinkyState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? connectionState = null,Object? preset = freezed,Object? presetNumber = null,Object? errorMessage = freezed,Object? sourcePresetId = freezed,}) {
  return _then(_PlinkyState(
connectionState: null == connectionState ? _self.connectionState : connectionState // ignore: cast_nullable_to_non_nullable
as PlinkyConnectionState,preset: freezed == preset ? _self.preset : preset // ignore: cast_nullable_to_non_nullable
as Preset?,presetNumber: null == presetNumber ? _self.presetNumber : presetNumber // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,sourcePresetId: freezed == sourcePresetId ? _self.sourcePresetId : sourcePresetId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
