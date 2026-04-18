// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pattern_playback_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PatternPlaybackState {

 bool get isPlaying; String? get currentPatternId; int get currentStep; int? get presetSlot; double get beatsPerMinute;
/// Create a copy of PatternPlaybackState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatternPlaybackStateCopyWith<PatternPlaybackState> get copyWith => _$PatternPlaybackStateCopyWithImpl<PatternPlaybackState>(this as PatternPlaybackState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatternPlaybackState&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.currentPatternId, currentPatternId) || other.currentPatternId == currentPatternId)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.presetSlot, presetSlot) || other.presetSlot == presetSlot)&&(identical(other.beatsPerMinute, beatsPerMinute) || other.beatsPerMinute == beatsPerMinute));
}


@override
int get hashCode => Object.hash(runtimeType,isPlaying,currentPatternId,currentStep,presetSlot,beatsPerMinute);

@override
String toString() {
  return 'PatternPlaybackState(isPlaying: $isPlaying, currentPatternId: $currentPatternId, currentStep: $currentStep, presetSlot: $presetSlot, beatsPerMinute: $beatsPerMinute)';
}


}

/// @nodoc
abstract mixin class $PatternPlaybackStateCopyWith<$Res>  {
  factory $PatternPlaybackStateCopyWith(PatternPlaybackState value, $Res Function(PatternPlaybackState) _then) = _$PatternPlaybackStateCopyWithImpl;
@useResult
$Res call({
 bool isPlaying, String? currentPatternId, int currentStep, int? presetSlot, double beatsPerMinute
});




}
/// @nodoc
class _$PatternPlaybackStateCopyWithImpl<$Res>
    implements $PatternPlaybackStateCopyWith<$Res> {
  _$PatternPlaybackStateCopyWithImpl(this._self, this._then);

  final PatternPlaybackState _self;
  final $Res Function(PatternPlaybackState) _then;

/// Create a copy of PatternPlaybackState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isPlaying = null,Object? currentPatternId = freezed,Object? currentStep = null,Object? presetSlot = freezed,Object? beatsPerMinute = null,}) {
  return _then(_self.copyWith(
isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,currentPatternId: freezed == currentPatternId ? _self.currentPatternId : currentPatternId // ignore: cast_nullable_to_non_nullable
as String?,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,presetSlot: freezed == presetSlot ? _self.presetSlot : presetSlot // ignore: cast_nullable_to_non_nullable
as int?,beatsPerMinute: null == beatsPerMinute ? _self.beatsPerMinute : beatsPerMinute // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [PatternPlaybackState].
extension PatternPlaybackStatePatterns on PatternPlaybackState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatternPlaybackState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatternPlaybackState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatternPlaybackState value)  $default,){
final _that = this;
switch (_that) {
case _PatternPlaybackState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatternPlaybackState value)?  $default,){
final _that = this;
switch (_that) {
case _PatternPlaybackState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isPlaying,  String? currentPatternId,  int currentStep,  int? presetSlot,  double beatsPerMinute)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatternPlaybackState() when $default != null:
return $default(_that.isPlaying,_that.currentPatternId,_that.currentStep,_that.presetSlot,_that.beatsPerMinute);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isPlaying,  String? currentPatternId,  int currentStep,  int? presetSlot,  double beatsPerMinute)  $default,) {final _that = this;
switch (_that) {
case _PatternPlaybackState():
return $default(_that.isPlaying,_that.currentPatternId,_that.currentStep,_that.presetSlot,_that.beatsPerMinute);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isPlaying,  String? currentPatternId,  int currentStep,  int? presetSlot,  double beatsPerMinute)?  $default,) {final _that = this;
switch (_that) {
case _PatternPlaybackState() when $default != null:
return $default(_that.isPlaying,_that.currentPatternId,_that.currentStep,_that.presetSlot,_that.beatsPerMinute);case _:
  return null;

}
}

}

/// @nodoc


class _PatternPlaybackState implements PatternPlaybackState {
  const _PatternPlaybackState({this.isPlaying = false, this.currentPatternId, this.currentStep = 0, this.presetSlot, this.beatsPerMinute = 80});
  

@override@JsonKey() final  bool isPlaying;
@override final  String? currentPatternId;
@override@JsonKey() final  int currentStep;
@override final  int? presetSlot;
@override@JsonKey() final  double beatsPerMinute;

/// Create a copy of PatternPlaybackState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatternPlaybackStateCopyWith<_PatternPlaybackState> get copyWith => __$PatternPlaybackStateCopyWithImpl<_PatternPlaybackState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatternPlaybackState&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying)&&(identical(other.currentPatternId, currentPatternId) || other.currentPatternId == currentPatternId)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.presetSlot, presetSlot) || other.presetSlot == presetSlot)&&(identical(other.beatsPerMinute, beatsPerMinute) || other.beatsPerMinute == beatsPerMinute));
}


@override
int get hashCode => Object.hash(runtimeType,isPlaying,currentPatternId,currentStep,presetSlot,beatsPerMinute);

@override
String toString() {
  return 'PatternPlaybackState(isPlaying: $isPlaying, currentPatternId: $currentPatternId, currentStep: $currentStep, presetSlot: $presetSlot, beatsPerMinute: $beatsPerMinute)';
}


}

/// @nodoc
abstract mixin class _$PatternPlaybackStateCopyWith<$Res> implements $PatternPlaybackStateCopyWith<$Res> {
  factory _$PatternPlaybackStateCopyWith(_PatternPlaybackState value, $Res Function(_PatternPlaybackState) _then) = __$PatternPlaybackStateCopyWithImpl;
@override @useResult
$Res call({
 bool isPlaying, String? currentPatternId, int currentStep, int? presetSlot, double beatsPerMinute
});




}
/// @nodoc
class __$PatternPlaybackStateCopyWithImpl<$Res>
    implements _$PatternPlaybackStateCopyWith<$Res> {
  __$PatternPlaybackStateCopyWithImpl(this._self, this._then);

  final _PatternPlaybackState _self;
  final $Res Function(_PatternPlaybackState) _then;

/// Create a copy of PatternPlaybackState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isPlaying = null,Object? currentPatternId = freezed,Object? currentStep = null,Object? presetSlot = freezed,Object? beatsPerMinute = null,}) {
  return _then(_PatternPlaybackState(
isPlaying: null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,currentPatternId: freezed == currentPatternId ? _self.currentPatternId : currentPatternId // ignore: cast_nullable_to_non_nullable
as String?,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as int,presetSlot: freezed == presetSlot ? _self.presetSlot : presetSlot // ignore: cast_nullable_to_non_nullable
as int?,beatsPerMinute: null == beatsPerMinute ? _self.beatsPerMinute : beatsPerMinute // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
