// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'midi_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MidiState {

 bool get isConnected; Map<int, ActiveNote> get activeNotes;
/// Create a copy of MidiState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MidiStateCopyWith<MidiState> get copyWith => _$MidiStateCopyWithImpl<MidiState>(this as MidiState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MidiState&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&const DeepCollectionEquality().equals(other.activeNotes, activeNotes));
}


@override
int get hashCode => Object.hash(runtimeType,isConnected,const DeepCollectionEquality().hash(activeNotes));

@override
String toString() {
  return 'MidiState(isConnected: $isConnected, activeNotes: $activeNotes)';
}


}

/// @nodoc
abstract mixin class $MidiStateCopyWith<$Res>  {
  factory $MidiStateCopyWith(MidiState value, $Res Function(MidiState) _then) = _$MidiStateCopyWithImpl;
@useResult
$Res call({
 bool isConnected, Map<int, ActiveNote> activeNotes
});




}
/// @nodoc
class _$MidiStateCopyWithImpl<$Res>
    implements $MidiStateCopyWith<$Res> {
  _$MidiStateCopyWithImpl(this._self, this._then);

  final MidiState _self;
  final $Res Function(MidiState) _then;

/// Create a copy of MidiState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isConnected = null,Object? activeNotes = null,}) {
  return _then(_self.copyWith(
isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,activeNotes: null == activeNotes ? _self.activeNotes : activeNotes // ignore: cast_nullable_to_non_nullable
as Map<int, ActiveNote>,
  ));
}

}


/// Adds pattern-matching-related methods to [MidiState].
extension MidiStatePatterns on MidiState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MidiState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MidiState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MidiState value)  $default,){
final _that = this;
switch (_that) {
case _MidiState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MidiState value)?  $default,){
final _that = this;
switch (_that) {
case _MidiState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isConnected,  Map<int, ActiveNote> activeNotes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MidiState() when $default != null:
return $default(_that.isConnected,_that.activeNotes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isConnected,  Map<int, ActiveNote> activeNotes)  $default,) {final _that = this;
switch (_that) {
case _MidiState():
return $default(_that.isConnected,_that.activeNotes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isConnected,  Map<int, ActiveNote> activeNotes)?  $default,) {final _that = this;
switch (_that) {
case _MidiState() when $default != null:
return $default(_that.isConnected,_that.activeNotes);case _:
  return null;

}
}

}

/// @nodoc


class _MidiState implements MidiState {
  const _MidiState({this.isConnected = false, final  Map<int, ActiveNote> activeNotes = const {}}): _activeNotes = activeNotes;
  

@override@JsonKey() final  bool isConnected;
 final  Map<int, ActiveNote> _activeNotes;
@override@JsonKey() Map<int, ActiveNote> get activeNotes {
  if (_activeNotes is EqualUnmodifiableMapView) return _activeNotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_activeNotes);
}


/// Create a copy of MidiState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MidiStateCopyWith<_MidiState> get copyWith => __$MidiStateCopyWithImpl<_MidiState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MidiState&&(identical(other.isConnected, isConnected) || other.isConnected == isConnected)&&const DeepCollectionEquality().equals(other._activeNotes, _activeNotes));
}


@override
int get hashCode => Object.hash(runtimeType,isConnected,const DeepCollectionEquality().hash(_activeNotes));

@override
String toString() {
  return 'MidiState(isConnected: $isConnected, activeNotes: $activeNotes)';
}


}

/// @nodoc
abstract mixin class _$MidiStateCopyWith<$Res> implements $MidiStateCopyWith<$Res> {
  factory _$MidiStateCopyWith(_MidiState value, $Res Function(_MidiState) _then) = __$MidiStateCopyWithImpl;
@override @useResult
$Res call({
 bool isConnected, Map<int, ActiveNote> activeNotes
});




}
/// @nodoc
class __$MidiStateCopyWithImpl<$Res>
    implements _$MidiStateCopyWith<$Res> {
  __$MidiStateCopyWithImpl(this._self, this._then);

  final _MidiState _self;
  final $Res Function(_MidiState) _then;

/// Create a copy of MidiState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isConnected = null,Object? activeNotes = null,}) {
  return _then(_MidiState(
isConnected: null == isConnected ? _self.isConnected : isConnected // ignore: cast_nullable_to_non_nullable
as bool,activeNotes: null == activeNotes ? _self._activeNotes : activeNotes // ignore: cast_nullable_to_non_nullable
as Map<int, ActiveNote>,
  ));
}


}

// dart format on
