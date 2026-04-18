// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'firmwares_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FirmwaresState {

 List<SavedFirmware> get firmwares; bool get isLoading; String? get errorMessage;
/// Create a copy of FirmwaresState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FirmwaresStateCopyWith<FirmwaresState> get copyWith => _$FirmwaresStateCopyWithImpl<FirmwaresState>(this as FirmwaresState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FirmwaresState&&const DeepCollectionEquality().equals(other.firmwares, firmwares)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(firmwares),isLoading,errorMessage);

@override
String toString() {
  return 'FirmwaresState(firmwares: $firmwares, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $FirmwaresStateCopyWith<$Res>  {
  factory $FirmwaresStateCopyWith(FirmwaresState value, $Res Function(FirmwaresState) _then) = _$FirmwaresStateCopyWithImpl;
@useResult
$Res call({
 List<SavedFirmware> firmwares, bool isLoading, String? errorMessage
});




}
/// @nodoc
class _$FirmwaresStateCopyWithImpl<$Res>
    implements $FirmwaresStateCopyWith<$Res> {
  _$FirmwaresStateCopyWithImpl(this._self, this._then);

  final FirmwaresState _self;
  final $Res Function(FirmwaresState) _then;

/// Create a copy of FirmwaresState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? firmwares = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
firmwares: null == firmwares ? _self.firmwares : firmwares // ignore: cast_nullable_to_non_nullable
as List<SavedFirmware>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FirmwaresState].
extension FirmwaresStatePatterns on FirmwaresState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FirmwaresState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FirmwaresState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FirmwaresState value)  $default,){
final _that = this;
switch (_that) {
case _FirmwaresState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FirmwaresState value)?  $default,){
final _that = this;
switch (_that) {
case _FirmwaresState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<SavedFirmware> firmwares,  bool isLoading,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FirmwaresState() when $default != null:
return $default(_that.firmwares,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<SavedFirmware> firmwares,  bool isLoading,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _FirmwaresState():
return $default(_that.firmwares,_that.isLoading,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<SavedFirmware> firmwares,  bool isLoading,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _FirmwaresState() when $default != null:
return $default(_that.firmwares,_that.isLoading,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _FirmwaresState implements FirmwaresState {
  const _FirmwaresState({final  List<SavedFirmware> firmwares = const [], this.isLoading = false, this.errorMessage}): _firmwares = firmwares;
  

 final  List<SavedFirmware> _firmwares;
@override@JsonKey() List<SavedFirmware> get firmwares {
  if (_firmwares is EqualUnmodifiableListView) return _firmwares;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_firmwares);
}

@override@JsonKey() final  bool isLoading;
@override final  String? errorMessage;

/// Create a copy of FirmwaresState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FirmwaresStateCopyWith<_FirmwaresState> get copyWith => __$FirmwaresStateCopyWithImpl<_FirmwaresState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FirmwaresState&&const DeepCollectionEquality().equals(other._firmwares, _firmwares)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_firmwares),isLoading,errorMessage);

@override
String toString() {
  return 'FirmwaresState(firmwares: $firmwares, isLoading: $isLoading, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$FirmwaresStateCopyWith<$Res> implements $FirmwaresStateCopyWith<$Res> {
  factory _$FirmwaresStateCopyWith(_FirmwaresState value, $Res Function(_FirmwaresState) _then) = __$FirmwaresStateCopyWithImpl;
@override @useResult
$Res call({
 List<SavedFirmware> firmwares, bool isLoading, String? errorMessage
});




}
/// @nodoc
class __$FirmwaresStateCopyWithImpl<$Res>
    implements _$FirmwaresStateCopyWith<$Res> {
  __$FirmwaresStateCopyWithImpl(this._self, this._then);

  final _FirmwaresState _self;
  final $Res Function(_FirmwaresState) _then;

/// Create a copy of FirmwaresState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? firmwares = null,Object? isLoading = null,Object? errorMessage = freezed,}) {
  return _then(_FirmwaresState(
firmwares: null == firmwares ? _self._firmwares : firmwares // ignore: cast_nullable_to_non_nullable
as List<SavedFirmware>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
